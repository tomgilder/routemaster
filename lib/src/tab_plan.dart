part of '../routemaster.dart';

// TODO: This might be better called something else as it could be used for something other than tab bars
// Suggestions: IndexPlan, IndexedPlan, NestedPlan
class TabPlan extends RoutePlan with RedirectPlan {
  final List<String> pathTemplates;
  final Widget Function(RouteInfo info, TabRouteState routeState) builder;
  final List<String> paths;

  String get redirectPath => paths[0];

  TabPlan(
    String pathTemplate,
    this.builder, {
    required this.paths,
  }) : this.pathTemplates = [pathTemplate];

  TabPlan.routes(
    this.pathTemplates,
    this.builder, {
    required this.paths,
  });

  @override
  RouteState createState(Routemaster delegate, RouteInfo routeInfo) {
    return TabRouteState(this, delegate, routeInfo);
  }
}

mixin RedirectPlan {
  String get redirectPath;
}

class TabRouteState extends SinglePageRouteState {
  final TabPlan plan;
  final Routemaster delegate;
  final RouteInfo routeInfo;

  TabRouteState(
    this.plan,
    this.delegate,
    this.routeInfo,
  ) {
    _routes = List.filled(plan.paths.length, null);
  }

  int _index = 0;
  int get index => _index;
  set index(int value) {
    if (value != _index) {
      _index = value;
      delegate._markNeedsUpdate();
    }
  }

  late List<_StackRouteState?> _routes;

  _StackRouteState getStackForIndex(int index) {
    if (_routes[index] == null) {
      _routes[index] = _StackRouteState(
        delegate: delegate,
        routes: [
          delegate._getRoute(join(
            routeInfo.path,
            plan.paths[index],
          ))!,
        ],
      );
    }

    return _routes[index]!;
  }

  List<Page> buildPagesForIndex(int index) {
    final stack = getStackForIndex(index);
    return stack.createPages();
  }

  int? getIndexForPath(String path) {
    int i = 0;
    for (String initialPath in plan.paths) {
      if (path.startsWith(initialPath)) {
        return i;
      }
      i++;
    }

    return null;
  }

  void setNewPath(List<RouteState> newRoutes) {
    final tabIndex = getIndexForPath(newRoutes[0].routeInfo.path)!;
    this.index = tabIndex;
    final stack = getStackForIndex(tabIndex);
    stack._setRouteStates(newRoutes);
    this.delegate._markNeedsUpdate();
  }

  @override
  Page createPage() {
    return MaterialPage<void>(
      child: plan.builder(routeInfo, this),
      key: ValueKey(routeInfo.path),
    );
  }

  @override
  bool maybeSetRouteStates(Iterable<RouteState> routes) {
    assert(
        routes.isNotEmpty, "Don't call maybeSetRouteStates with an empty list");

    final newIndex = getIndexForPath(routes.toList()[0].routeInfo.path);
    if (newIndex == null) {
      return false;
    }

    this.index = newIndex;
    getStackForIndex(index)._setRouteStates(routes.toList());
    return true;
  }

  @override
  bool maybePush(RouteState route) {
    final index = getIndexForPath(route.routeInfo.path);
    if (index == null) {
      return false;
    }

    getStackForIndex(index).push(route);
    return true;
  }

  @override
  bool maybePop() {
    return getStackForIndex(index).maybePop();
  }

  @override
  Iterable<RouteState> getCurrentRouteStates() sync* {
    yield this;
    yield* _routes[index]!.getCurrentRouteStates();
  }

  // Removed for now, might come back later
  // static TabRoute of(BuildContext context) {
  //   return context.dependOnInheritedWidgetOfExactType<_TabRouteWidget>()!.route;
  // }
}

// class _TabRouteWidget extends InheritedWidget {
//   final TabRoute route;

//   _TabRouteWidget({required this.route}) : assert(route != null), super(child: child);

//   @override
//   bool updateShouldNotify(covariant InheritedWidget oldWidget) {
//     return false;
//   }
// }
