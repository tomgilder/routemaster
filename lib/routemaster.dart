library routemaster;

export 'src/parser.dart';
export 'src/route_info.dart';
export 'src/plans/standard.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';
import 'src/plans/standard.dart';
import 'src/route_dart.dart';
import 'src/trie_router/trie_router.dart';
import 'src/query_parser.dart';
import 'src/route_info.dart';

part 'src/plans/stack.dart';
part 'src/plans/tab_plan.dart';

typedef Widget RoutemasterBuilder(
  BuildContext context,
  Routemaster routemaster,
);

class Routemaster extends RouterDelegate<RouteData>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteData> {
  final RoutemasterBuilder? builder;
  final String defaultPath;
  late TrieRouter _router;
  _StackRouteState? _stack;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  List<RoutePlan>? _plans;
  List<RoutePlan>? get plans => _plans;
  set plans(List<RoutePlan>? newPlans) {
    if (_plans != newPlans) {
      _plans = newPlans;
      _stack = null;
      _initRoutes();
    }
  }

  Routemaster({
    List<RoutePlan>? plans,
    this.builder,
    this.defaultPath = '/',
    GlobalKey<NavigatorState>? navigatorKey,
  })  : _plans = plans,
        this.navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {
    if (_plans != null) {
      _initRoutes();
    }
  }

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
              pages: buildPages(),
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

    return RouteData(
      _stack!.getCurrentRouteStates().last.routeInfo.path,
    );
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
        _stack!._setRouteStates(states);
      }
    }

    return SynchronousFuture(null);
  }

  /// Generates all pages and sub-pages.
  List<Page> buildPages() {
    assert(_stack != null,
        "Stack must have been created when buildPages() is called");
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

    _stack!._setRouteStates(states);
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

  void _initRoutes() {
    if (plans == null) {
      return;
    }

    _router = TrieRouter()..addAll(plans!);

    final routeStates = _createAllStates('/');
    if (routeStates == null) {
      throw "Failed to create initial state";
    }

    _stack = _StackRouteState(delegate: this, routes: routeStates.toList());
  }

  void _markNeedsUpdate() {
    notifyListeners();
  }

  List<RouteState>? _createAllStates(String requestedPath) {
    final routerResult = _router.getAll(requestedPath);
    if (routerResult == null) {
      print(
        "Router couldn't find a match for path '$requestedPath', returning default of '$defaultPath'",
      );
      return [_getRoute(defaultPath)!];
    }

    final lastPlan = routerResult.last.value;
    if (lastPlan is RedirectPlan) {
      // TODO: We're only looking to see if the LAST plan is a redirect
      // ...what if others are also a redirect?
      final redirectPath = (lastPlan as RedirectPlan).redirectPath;
      print("Redirecting from '$requestedPath' to '$redirectPath'");
      return _createAllStates(redirectPath);
    }

    final queryParameters = QueryParser.parseQueryParameters(requestedPath);
    final currentRoutes = _stack?.getCurrentRouteStates().toList();

    var result = <RouteState>[];

    for (final routerData in routerResult.reversed) {
      final state = _getOrCreateRouteState(
        currentRoutes,
        routerData,
        queryParameters,
      );

      if (state == null) {
        return null;
      }

      if (result.isNotEmpty && state.maybeSetRouteStates(result)) {
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
  RouteState? _getOrCreateRouteState(
    List<RouteState>? currentRoutes,
    RouterResult routerResult,
    Map<String, String> queryParameters,
  ) {
    final routeInfo = RouteInfo(routerResult, queryParameters);

    if (currentRoutes != null) {
      final currentState = currentRoutes.firstWhereOrNull(
        ((element) => element.routeInfo == routeInfo),
      );

      if (currentState != null) {
        return currentState;
      }
    }

    return _createState(routerResult, routeInfo);
  }

  /// Try to get the route for [requestedPath]. If no match, returns default path.
  /// Returns null if validation fails.
  RouteState? _getRoute(String requestedPath) {
    final routerResult = _router.get(requestedPath);
    if (routerResult == null) {
      print(
        "Router couldn't find a match for path '$requestedPath', returning default of '$defaultPath'",
      );
      return _getRoute(defaultPath);
    }

    final queryParameters = QueryParser.parseQueryParameters(requestedPath);
    return _createState(
      routerResult,
      RouteInfo(routerResult, queryParameters),
    );
  }

  RouteState? _createState(RouterResult routerResult, RouteInfo routeInfo) {
    if (routerResult.value.validate != null &&
        !routerResult.value.validate!(routeInfo)) {
      print("Validation failed for '${routeInfo.path}'");
      routerResult.value.onValidationFailed!(this, routeInfo);
      return null;
    }

    return routerResult.value.createState(this, routeInfo);
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
