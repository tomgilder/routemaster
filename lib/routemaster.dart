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
import 'src/query_parser.dart';
import 'src/route_info.dart';

part 'src/pages/stack.dart';
part 'src/pages/tab_pages.dart';
part 'src/pages/standard.dart';

typedef Widget RoutemasterBuilder(
  BuildContext context,
  Routemaster routemaster,
);

typedef Page PageBuilder(RouteInfo info);

@immutable
class RouteMap {
  /// A map of paths and [PageBuilder] delegates that return [Page] objects to
  /// build.
  final Map<String, PageBuilder> routes;

  /// The default fallback path, if the user tries to go to a page that doesn't
  /// exist. Defaults to '/'.
  final String defaultPath;

  const RouteMap({
    required this.routes,
    this.defaultPath = '/',
  });
}

class Routemaster extends RouterDelegate<RouteData>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteData> {
  /// Used to override how the [Navigator] builds.
  final RoutemasterBuilder? builder;

  late TrieRouter _router;
  _StackPageState? _stack;
  RouteMap? _routeMap;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final RouteMap Function(BuildContext context) routeBuilder;

  Routemaster({
    required this.routeBuilder,
    this.builder,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : this.navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {}

  static Routemaster of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_RoutemasterWidget>()!
        .delegate;
  }

  @override
  Widget build(BuildContext context) {
    return _RoutemasterWidget(
      child: builder != null
          ? builder!(context, this)
          : Navigator(
              pages: createPages(context),
              onPopPage: onPopPage,
              key: navigatorKey,
            ),
      delegate: this,
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
    print("Path is: '$path'");
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

  void _initRoutes(BuildContext context) {
    final routeMap = routeBuilder(context);

    if (_routeMap != routeMap) {
      // TODO: Could this be more efficent and not rebuild the entire router
      // and base stack when the route map changes?
      _routeMap = routeMap;
      final currentRouteString = currentConfiguration?.routeString;

      _router = TrieRouter()..addAll(routeMap.routes);

      final pageStates = _createAllStates(currentRouteString ?? '/');
      if (pageStates == null) {
        throw "Failed to create initial state";
      }

      _stack = _StackPageState(delegate: this, routes: pageStates.toList());

      // If URL has changed during this build, schedule a notification
      if (currentRouteString != currentConfiguration?.routeString) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
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

  /// Add [path] to the end of the current path.
  void pushNamed(String path) {
    replaceNamed(
      join(currentConfiguration!.routeString, path),
    );
  }

  /// Replace the entire route with the path from [path].
  void replaceNamed(String path) {
    final states = _createAllStates(path);
    if (states == null) {
      return;
    }

    _stack!._setPageStates(states);
    _markNeedsUpdate();
  }

  /// Passed to [Navigator] widgets, called when the navigator requests that it
  /// wants to pop a page.
  bool onPopPage(Route<dynamic> route, dynamic result) {
    return _stack!.onPopPage(route, result);
  }

  /// Pop the top-most path from the router.
  void pop() {
    _stack!.pop();
    _markNeedsUpdate();
  }

  void _markNeedsUpdate() {
    notifyListeners();
  }

  List<PageState>? _createAllStates(String requestedPath) {
    final routerResult = _router.getAll(requestedPath);

    if (routerResult == null) {
      print(
        "Router couldn't find a match for path '$requestedPath', returning default of '${_routeMap!.defaultPath}'",
      );
      return [_getRoute(_routeMap!.defaultPath)!];
    }

    final queryParameters = QueryParser.parseQueryParameters(requestedPath);
    final currentRoutes = _stack?.getCurrentPageStates().toList();

    var result = <PageState>[];

    for (final routerData in routerResult.reversed) {
      final state = _getOrCreatePageState(
        currentRoutes,
        routerData,
        queryParameters,
      );

      if (state == null) {
        return null;
      }

      if (result.isNotEmpty && state.maybeSetPageStates(result)) {
        result = [state];
      } else {
        result.insert(0, state);
      }
    }

    assert(result.isNotEmpty, "_createAllStates can't return empty list");
    return result;
  }

  /// If there's a current route matching the path in the tree, return it.
  /// Otherwise create a new one. This could possibly be made more efficient
  /// By using a map rather than iterating over all currentRoutes.
  PageState? _getOrCreatePageState(
    List<PageState>? currentRoutes,
    RouterResult routerResult,
    Map<String, String> queryParameters,
  ) {
    final routeInfo = RouteInfo(routerResult, queryParameters);

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
        "Router couldn't find a match for path '$requestedPath', returning default of '${_routeMap!.defaultPath}'",
      );
      return _getRoute(_routeMap!.defaultPath);
    }

    final queryParameters = QueryParser.parseQueryParameters(requestedPath);
    final routeInfo = RouteInfo(routerResult, queryParameters);

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
