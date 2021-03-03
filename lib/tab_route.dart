import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'routemaster.dart';

// TODO: This might be better called 'IndexedRoute' as it could be used for
// something other than tab bars

class TabRoute extends RoutemasterRoute {
  final String pathTemplate;
  final Widget Function(RouteInfo info, TabRouteElement tabRoute) builder;
  final List<String> paths;

  TabRoute(
    this.pathTemplate,
    this.builder, {
    @required this.paths,
  })  : assert(pathTemplate != null),
        assert(builder != null);

  @override
  RoutemasterElement createElement(
      RoutemasterDelegate delegate, RouteInfo routeInfo) {
    return TabRouteElement(this, delegate, routeInfo);
  }
}

class TabRouteElement extends SinglePageRouteElement {
  final TabRoute tabRoute;
  final RoutemasterDelegate delegate;
  final RouteInfo routeInfo;

  TabRouteElement(
    this.tabRoute,
    this.delegate,
    this.routeInfo,
  ) {
    routes = tabRoute.paths.map((path) {
      final elements = delegate.getAllRoutes(path).skip(1).toList();
      return StackRouteElement(delegate: delegate, routes: elements);
    }).toList();
  }

  int index = 0;

  List<StackRouteElement> routes;

  int getIndexForPath(String path) {
    assert(path != null);

    int i = 0;
    for (String initialPath in tabRoute.paths) {
      if (path.startsWith(initialPath)) {
        return i;
      }
      i++;
    }

    return null;
  }

  static TabRoute of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_TabRouteWidget>().route;
  }

  void setNewPath(List<RoutemasterElement> newRoutes) {
    assert(newRoutes != null);

    final tabIndex = getIndexForPath(newRoutes[0].routeInfo.path);
    print('setNewRoutePath: setting tabIndex = $tabIndex');
    index = tabIndex;
    routes[tabIndex].setRoutes(newRoutes);
    delegate.markNeedsUpdate();
  }

  @override
  RoutemasterElement get currentRoute => routes[index].currentRoute;

  void didSwitchTab(int index) {
    assert(index != null);

    this.index = index;
    delegate.markNeedsUpdate();
  }

  @override
  Page createPage() {
    return MaterialPage<dynamic>(
      child: tabRoute.builder(routeInfo, this),
      key: ValueKey(routeInfo.path),
    );
  }

  @override
  bool maybeSetRoutes(Iterable<RoutemasterElement> routes) {
    final index = getIndexForPath(routes.toList()[0].routeInfo.path);
    if (index == null) {
      return false;
    }

    this.routes[index].setRoutes(routes.toList());
    return true;
  }

  @override
  bool maybePush(RoutemasterElement route) {
    final index = getIndexForPath(route.routeInfo.path);
    if (index == null) {
      return false;
    }

    this.routes[index].push(route);
    return true;
  }

  @override
  bool maybePop() {
    return routes[index].maybePop();
  }
}

class _TabRouteWidget extends InheritedWidget {
  final TabRoute route;

  _TabRouteWidget({@required this.route}) : assert(route != null);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
