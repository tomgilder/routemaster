import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class _RouteWidget<T> extends InheritedWidget {
  final T route;

  _RouteWidget({
    required this.route,
    required Widget child,
  })   : assert(route != null),
        super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class StackRouteElement extends MultiPageRouteElement {
  final RoutemasterDelegate delegate;
  late List<RoutemasterElement?> routes;
  List<Page>? pages;

  StackRouteElement({
    required this.delegate,
    List<RoutemasterElement?>? routes,
  }) {
    if (routes != null) {
      setRoutes(routes);
    }
  }

  static StackRouteElement of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_RouteWidget<StackRouteElement>>()!
        .route;
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
    if (routes.last!.maybePop()) {
      return;
    }

    if (routes.length > 1) {
      routes.removeLast();
    }

    delegate.markNeedsUpdate();
  }

  @override
  void push(RoutemasterElement route) {
    if (routes.last!.maybePush(route)) {
      return;
    }

    routes.add(route);
    delegate.markNeedsUpdate();
  }

  @override
  List<Page> createPages() {
    assert(routes.isNotEmpty, "Can't generate pages with no routes");

    final pages = routes.map(
      (data) {
        if (data is SinglePageRouteElement) {
          return data.createPage();
        }

        throw "Not a SinglePageRoute";
      },
    ).toList();

    assert(pages.isNotEmpty, "Returned pages list must not be empty");

    return [
      MaterialPage<dynamic>(
        name: "Wrapper for '${this.routeInfo.path}'",
        child: Builder(
          builder: (context) {
            return _RouteWidget<StackRouteElement>(
              route: this,
              child: Navigator(
                pages: pages,
                onPopPage: this.onPopPage,
              ),
            );
          },
        ),
      )
    ];
  }

  @override
  RoutemasterElement get currentRoute => routes.last!.currentRoute;

  @override
  void setRoutes(Iterable<RoutemasterElement?> newRoutes) {
    int i = 0;

    final elements = <RoutemasterElement?>[];

    for (final element in newRoutes) {
      final bool hasMoreRoutes = i < newRoutes.length - 1;
      elements.add(element);

      if (hasMoreRoutes && element!.maybeSetRoutes(newRoutes.skip(i + 1))) {
        // Route has handled all of the rest of routes
        // Our job here is done
        // final newRouteList = newRoutes.take(i + 1).toList();
        assert(elements.isNotEmpty, "New route list cannot be empty");
        print("StackRoute.setRoutes: adding $i routes");
        this.routes = elements;
        return;
      }

      i++;
    }

    this.routes = elements;
  }

  bool maybeSetRoutes(Iterable<RoutemasterElement?> routes) {
    this.routes = routes.toList();
    delegate.markNeedsUpdate();
    return true;
  }

  @override
  RouteInfo get routeInfo => this.routes.last!.routeInfo;

  @override
  bool maybePush(RoutemasterElement route) {
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
