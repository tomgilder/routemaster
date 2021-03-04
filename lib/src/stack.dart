part of '../routemaster.dart';

/// The state of a stack of routes.
///
/// TODO: This is currently private. Is there any reason it should be exposed?
class _StackRouteState extends MultiPageRouteState {
  final Routemaster delegate;

  // TODO: This should probably be non-nullable
  late List<RouteState?> _routes;

  _StackRouteState({
    required this.delegate,
    required List<RouteState?> routes,
  }) {
    _setRoutes(routes);
  }

  bool onPopPage(Route<dynamic> route, dynamic result) {
    if (route.didPop(result)) {
      pop();

      return true;
    }

    return false;
  }

  @override
  void pop() {
    if (_routes.last!.maybePop()) {
      return;
    }

    if (_routes.length > 1) {
      _routes.removeLast();
    }

    delegate._markNeedsUpdate();
  }

  @override
  void push(RouteState route) {
    if (_routes.last!.maybePush(route)) {
      return;
    }

    _routes.add(route);
    delegate._markNeedsUpdate();
  }

  @override
  List<Page> createPages() {
    assert(_routes.isNotEmpty, "Can't generate pages with no routes");

    final pages = _routes.map(
      (data) {
        if (data is SinglePageRouteState) {
          return data.createPage();
        }

        throw "Not a SinglePageRoute";
      },
    ).toList();

    assert(pages.isNotEmpty, "Returned pages list must not be empty");

    return pages;

    // TODO: This is probably a bad idea, but we could allow descendent widgets
    // to directly access this stack. Needs thinking about. Commented out for now.
    //
    // static StackPlanElement of(BuildContext context) {
    //   return context
    //       .dependOnInheritedWidgetOfExactType<_RouteWidget<StackPlanElement>>()!
    //       .route;
    // }
    //
    // return [
    //   MaterialPage<dynamic>(
    //     name: "Wrapper for '${this.routeInfo.path}'",
    //     child: Builder(
    //       builder: (context) {
    //         return _RouteWidget<StackPlanElement>(
    //           route: this,
    //           child: Navigator(
    //             pages: pages,
    //             onPopPage: this.onPopPage,
    //           ),
    //         );
    //       },
    //     ),
    //   )
    // ];
  }

  @override
  RouteState get currentRoute => _routes.last!.currentRoute;

  @override
  void _setRoutes(Iterable<RouteState?> newRoutes) {
    int i = 0;

    final elements = <RouteState?>[];

    for (final element in newRoutes) {
      final bool hasMoreRoutes = i < newRoutes.length - 1;
      elements.add(element);

      if (hasMoreRoutes && element!.maybeSetRoutes(newRoutes.skip(i + 1))) {
        // Route has handled all of the rest of routes
        // Our job here is done
        assert(elements.isNotEmpty, "New route list cannot be empty");
        print("StackRoute.setRoutes: adding $i routes");
        this._routes = elements;
        return;
      }

      i++;
    }

    this._routes = elements;
  }

  bool maybeSetRoutes(Iterable<RouteState?> routes) {
    this._routes = routes.toList();
    delegate._markNeedsUpdate();
    return true;
  }

  @override
  RouteInfo get routeInfo => this._routes.last!.routeInfo;

  @override
  bool maybePush(RouteState route) {
    push(route);
    return true;
  }

  @override
  bool maybePop() {
    if (_routes.last!.maybePop()) {
      return true;
    }

    if (_routes.length > 1) {
      pop();
      return true;
    }

    return false;
  }
}
