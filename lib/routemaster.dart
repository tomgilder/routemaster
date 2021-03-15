library routemaster;

export 'src/parser.dart';
export 'src/route_info.dart';
export 'src/pages/guard.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';
import 'src/pages/guard.dart';
import 'src/route_dart.dart';
import 'src/trie_router/trie_router.dart';
import 'src/route_info.dart';

part 'src/pages/stack.dart';
part 'src/pages/tab_pages.dart';
part 'src/pages/standard.dart';

typedef Widget RoutemasterBuilder(
  BuildContext context,
  Routemaster routemaster,
);

typedef Page PageBuilder(RouteInfo info);

typedef void UnknownRouteCallback(Routemaster routemaster, String route);

/// An abstract class that can provide a map of routes
abstract class RouteConfig {
  Map<String, PageBuilder> get routes;

  void onUnknownRoute(Routemaster routemaster, String route) {
    routemaster.setLocation('/');
  }
}

/// A standard simple routing table which takes a map of routes.
@immutable
class RouteMap extends RouteConfig {
  /// A map of paths and [PageBuilder] delegates that return [Page] objects to
  /// build.
  final Map<String, PageBuilder> routes;

  final UnknownRouteCallback? _onUnknownRoute;

  RouteMap({
    required this.routes,
    UnknownRouteCallback? onUnknownRoute,
  }) : _onUnknownRoute = onUnknownRoute;

  @override
  void onUnknownRoute(Routemaster routemaster, String route) {
    if (_onUnknownRoute != null) {
      _onUnknownRoute!(routemaster, route);
    } else {
      super.onUnknownRoute(routemaster, route);
    }
  }
}

class Routemaster extends RouterDelegate<RouteData> with ChangeNotifier {
  /// Used to override how the [Navigator] builds.
  final RoutemasterBuilder? builder;

  late TrieRouter _router;
  _StackPageState? _stack;
  RouteConfig? _routeMap;
  GlobalKey<NavigatorState> _navigatorKey;

  // TODO: Could this have a better name?
  // Options: mapBuilder, builder, routeMapBuilder
  final RouteConfig Function(BuildContext context) routesBuilder;

  Routemaster({
    required this.routesBuilder,
    this.builder,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : _navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {}

  static Routemaster of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_RoutemasterWidget>()!
        .delegate;
  }

  /// Pop the top-most path from the router.
  void pop() {
    _stack!.pop();
    _markNeedsUpdate();
  }

  @override
  Future<bool> popRoute() {
    final NavigatorState? navigator = _navigatorKey.currentState;
    if (navigator == null) return SynchronousFuture<bool>(false);
    return navigator.maybePop();
  }

  /// Passed to [Navigator] widgets, called when the navigator requests that it
  /// wants to pop a page.
  bool onPopPage(Route<dynamic> route, dynamic result) {
    return _stack!.onPopPage(route, result);
  }

  /// Add [path] to the end of the current path.
  void pushNamed(String path, {Map<String, String>? queryParameters}) {
    setLocation(
      join(currentConfiguration!.routeString, path),
      queryParameters: queryParameters,
    );
  }

  /// Replace the entire route with the path from [path].
  void setLocation(String path, {Map<String, String>? queryParameters}) {
    if (queryParameters != null) {
      path = Uri(
        path: path,
        queryParameters: queryParameters,
      ).toString();
    }

    if (_isBuilding) {
      // About to build pages, process request now
      _processNavigation(path);
    } else {
      // Schedule request for next build. This makes sure the routing table is
      // updated before processing the new path.
      _pendingNavigation = path;
      notifyListeners();
    }
  }

  String? _pendingNavigation;
  bool _isBuilding = false;

  void _processPendingNavigation() {
    if (_pendingNavigation != null) {
      _processNavigation(_pendingNavigation!);
      _pendingNavigation = null;
    }
  }

  void _processNavigation(String path) {
    final states = _createAllStates(path);
    if (states == null) {
      return;
    }

    _stack!._setPageStates(states);
  }

  @override
  Widget build(BuildContext context) {
    return _DependencyTracker(
      delegate: this,
      builder: (context) {
        _isBuilding = true;
        _processPendingNavigation();
        _isBuilding = false;

        return _RoutemasterWidget(
          child: builder != null
              ? builder!(context, this)
              : Navigator(
                  pages: createPages(context),
                  onPopPage: onPopPage,
                  key: _navigatorKey,
                ),
          delegate: this,
        );
      },
    );
  }

  // Returns a [RouteData] that matches the current route state.
  // This is used to update a browser's current URL.
  @override
  RouteData? get currentConfiguration {
    if (_stack == null) {
      return null;
    }

    final path = _stack!.getCurrentPageStates().last.routeInfo.path;
    return RouteData(path);
  }

  // Called when a new URL is set. The RouteInformationParser will parse the
  // URL, and return a new [RouteData], that gets passed this this method.
  //
  // This method then modifies the state based on that information.
  @override
  Future<void> setNewRoutePath(RouteData routeData) {
    if (currentConfiguration != routeData) {
      final states = _createAllStates(routeData.routeString);
      if (states != null) {
        _stack!._setPageStates(states);
      }
    }

    return SynchronousFuture(null);
  }

  /// This delegate maintains state by using a `StatefulWidget` inserted in the
  /// widget tree. This means it can maintain state if the delegate is rebuilt
  /// in the same tree location.
  ///
  /// TODO: Should this reuse more data for performance?
  void _didUpdateWidget(Routemaster oldDelegate) {
    final oldConfiguration = oldDelegate.currentConfiguration;

    if (oldConfiguration != null) {
      _oldConfiguration = oldDelegate.currentConfiguration;
    }

    _navigatorKey = oldDelegate._navigatorKey;
  }

  void _rebuildRouter(BuildContext context) {
    final routeMap = routesBuilder(context);

    _router = TrieRouter()..addAll(routeMap.routes);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      notifyListeners();
    });

    _routeMap = routeMap;
  }

  RouteData? _oldConfiguration;

  void _initRoutes(BuildContext context) {
    if (_routeMap == null) {
      _rebuildRouter(context);
    }

    if (_stack == null) {
      final pageStates = _createAllStates(_oldConfiguration?.routeString ??
          currentConfiguration?.routeString ??
          '/');
      if (pageStates == null) {
        throw "Failed to create initial state";
      }

      _stack = _StackPageState(delegate: this, routes: pageStates.toList());
    }
  }

  /// Generates all pages and sub-pages.
  List<Page> createPages(BuildContext context) {
    _initRoutes(context);

    assert(_stack != null,
        "Stack must have been created when createPages() is called");
    final pages = _stack!.createPages();
    assert(pages.isNotEmpty, "Returned pages list must not be empty");
    return pages;
  }

  void _markNeedsUpdate() {
    notifyListeners();
  }

  List<PageState>? _createAllStates(String requestedPath) {
    final routerResult = _router.getAll(requestedPath);

    if (routerResult == null) {
      print(
        "Router couldn't find a match for path '$requestedPath''",
      );

      _routeMap!.onUnknownRoute(this, requestedPath);
      return null;
    }

    final currentRoutes = _stack?.getCurrentPageStates().toList();

    var result = <PageState>[];

    int i = 0;
    for (final routerData in routerResult.reversed) {
      final routeInfo = RouteInfo(
        routerData,
        // Only the last route gets query parameters
        i == 0 ? requestedPath : routerData.pathSegment,
      );

      final state = _getOrCreatePageState(routeInfo, currentRoutes, routerData);

      if (state == null) {
        return null;
      }

      if (result.isNotEmpty && state.maybeSetPageStates(result)) {
        result = [state];
      } else {
        result.insert(0, state);
      }

      i++;
    }

    assert(result.isNotEmpty, "_createAllStates can't return empty list");
    return result;
  }

  /// If there's a current route matching the path in the tree, return it.
  /// Otherwise create a new one. This could possibly be made more efficient
  /// By using a map rather than iterating over all currentRoutes.
  PageState? _getOrCreatePageState(
    RouteInfo routeInfo,
    List<PageState>? currentRoutes,
    RouterResult routerResult,
  ) {
    if (currentRoutes != null) {
      print(
          " - Trying to find match for state matching '${routeInfo.path}'...");
      final currentState = currentRoutes.firstWhereOrNull(
        ((element) => element.routeInfo == routeInfo),
      );

      if (currentState != null) {
        print(" - Found match for state");
        return currentState;
      }

      print(" - No match for state, will need to create it");
    }

    return _createState(routerResult, routeInfo);
  }

  /// Try to get the route for [requestedPath]. If no match, returns default path.
  /// Returns null if validation fails.
  PageState? _getRoute(String requestedPath) {
    final routerResult = _router.get(requestedPath);
    if (routerResult == null) {
      print(
        "Router couldn't find a match for path '$requestedPath'",
      );

      _routeMap!.onUnknownRoute(this, requestedPath);
      return null;
    }

    final routeInfo = RouteInfo(routerResult, requestedPath);
    return _createState(routerResult, routeInfo);
  }

  PageState? _createState(RouterResult routerResult, RouteInfo routeInfo) {
    var page = routerResult.builder(routeInfo);

    if (page is GuardedPage) {
      if (page.validate != null && !page.validate!(routeInfo)) {
        print("Validation failed for '${routeInfo.path}'");
        page.onValidationFailed!(this, routeInfo);
        return null;
      }

      page = page.child;
    }

    if (page is StatefulPage) {
      return page.createState(this, routeInfo);
    }

    assert(page is! ProxyPage, "ProxyPage has not been unwrapped");

    // Page is just a standard Flutter page, create a wrapper for it
    return _StatelessPage(routeInfo, page);
  }
}

/// Used internally so descendent widgets can use `Routemaster.of(context)`.
class _RoutemasterWidget extends InheritedWidget {
  final Routemaster delegate;

  const _RoutemasterWidget({
    required Widget child,
    required this.delegate,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant _RoutemasterWidget oldWidget) {
    return delegate != oldWidget.delegate;
  }
}

/// Widget to trigger router rebuild when dependencies change
class _DependencyTracker extends StatefulWidget {
  final Routemaster delegate;
  final Widget Function(BuildContext context) builder;

  _DependencyTracker({
    required this.delegate,
    required this.builder,
  });

  @override
  _DependencyTrackerState createState() => _DependencyTrackerState();
}

class _DependencyTrackerState extends State<_DependencyTracker> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  @override
  void didUpdateWidget(_DependencyTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.delegate._didUpdateWidget(oldWidget.delegate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.delegate._rebuildRouter(this.context);
  }
}
