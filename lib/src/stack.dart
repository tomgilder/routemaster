part of '../routemaster.dart';

/// The state of a stack of routes.
class StackRouteState extends MultiPageRouteState {
  final Routemaster delegate;
  late List<RouteState?> routes;
  List<Page>? pages;

  StackRouteState({
    required this.delegate,
    List<RouteState?>? routes,
  }) {
    if (routes != null) {
      setRoutes(routes);
    }
  }

  // static StackPlanElement of(BuildContext context) {
  //   return context
  //       .dependOnInheritedWidgetOfExactType<_RouteWidget<StackPlanElement>>()!
  //       .route;
  // }

  bool onPopPage(Route<dynamic> route, dynamic result) {
    if (route.didPop(result)) {
      pop();

      return true;
    }

    return false;
  }

  @override
  void pop() {
    if (routes.last!.maybePop()) {
      return;
    }

    if (routes.length > 1) {
      routes.removeLast();
    }

    delegate._markNeedsUpdate();
  }

  @override
  void push(RouteState route) {
    if (routes.last!.maybePush(route)) {
      return;
    }

    routes.add(route);
    delegate._markNeedsUpdate();
  }

  @override
  List<Page> createPages() {
    assert(routes.isNotEmpty, "Can't generate pages with no routes");

    final pages = routes.map(
      (data) {
        if (data is SinglePageRouteState) {
          return data.createPage();
        }

        throw "Not a SinglePageRoute";
      },
    ).toList();

    assert(pages.isNotEmpty, "Returned pages list must not be empty");

    return pages;
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
  RouteState get currentRoute => routes.last!.currentRoute;

  @override
  void setRoutes(Iterable<RouteState?> newRoutes) {
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
        this.routes = elements;
        return;
      }

      i++;
    }

    this.routes = elements;
  }

  bool maybeSetRoutes(Iterable<RouteState?> routes) {
    this.routes = routes.toList();
    delegate._markNeedsUpdate();
    return true;
  }

  @override
  RouteInfo get routeInfo => this.routes.last!.routeInfo;

  @override
  bool maybePush(RouteState route) {
    push(route);
    return true;
  }

  @override
  bool maybePop() {
    if (routes.last!.maybePop()) {
      return true;
    }

    if (routes.length > 1) {
      pop();
      return true;
    }

    return false;
  }
}
