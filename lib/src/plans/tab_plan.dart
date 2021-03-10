part of '../../routemaster.dart';

class IndexedPlan extends RoutePlan with RedirectPlan, IndexedRoutePlanMixIn {
  final List<String> pathTemplates;
  final Widget Function(RouteInfo info) builder;
  final List<String> paths;

  String get redirectPath => paths[0];

  IndexedPlan(
    String pathTemplate,
    this.builder, {
    required this.paths,
  }) : this.pathTemplates = [pathTemplate];

  IndexedPlan.routes(
    this.pathTemplates,
    this.builder, {
    required this.paths,
  });

  @override
  RouteState createState(Routemaster delegate, RouteInfo routeInfo) {
    return IndexedRouteState(this, delegate, routeInfo);
  }
}

class _IndexedRouteStateProvider extends InheritedNotifier {
  final IndexedRouteState routeState;

  _IndexedRouteStateProvider({
    required Widget child,
    required this.routeState,
  }) : super(
          child: child,
          notifier: routeState.delegate,
        );

  @override
  bool updateShouldNotify(covariant _IndexedRouteStateProvider oldWidget) {
    return true;
  }
}

class IndexedRouteState extends SinglePageRouteState
    with ChangeNotifier, IndexedRouteStateMixIn {
  final IndexedPlan plan;
  final Routemaster delegate;
  final RouteInfo routeInfo;

  IndexedRouteState(
    this.plan,
    this.delegate,
    this.routeInfo,
  ) {
    _routes = List.filled(plan.paths.length, null);
  }

  static IndexedRouteState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_IndexedRouteStateProvider>()!
        .routeState;
  }

  @override
  Page createPage() {
    return MaterialPage<void>(
      child: _IndexedRouteStateProvider(
        routeState: this,
        child: plan.builder(routeInfo),
      ),
      key: ValueKey(routeInfo.path),
    );
  }
}

class TabPlan extends RoutePlan with RedirectPlan, IndexedRoutePlanMixIn {
  final List<String> pathTemplates;
  final Widget Function(RouteInfo info) builder;
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

class _TabRouteStateProvider extends InheritedNotifier {
  final TabRouteState routeState;

  _TabRouteStateProvider({
    required Widget child,
    required this.routeState,
  }) : super(
          child: child,
          notifier: routeState.delegate,
        );

  @override
  bool updateShouldNotify(covariant _TabRouteStateProvider oldWidget) {
    return true;
  }
}

class TabRouteState extends SinglePageRouteState
    with ChangeNotifier, IndexedRouteStateMixIn {
  final TabPlan plan;
  final Routemaster delegate;
  final RouteInfo routeInfo;

  TabRouteState(this.plan, this.delegate, this.routeInfo) {
    _routes = List.filled(plan.paths.length, null);
  }

  static TabRouteState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TabRouteStateProvider>()!
        .routeState;
  }

  @override
  Page createPage() {
    return MaterialPage<void>(
      child: _TabRouteStateProvider(
        routeState: this,
        child: plan.builder(routeInfo),
      ),
      key: ValueKey(routeInfo.path),
    );
  }

  TabController? _tabController;
  TabController getTabController({required TickerProvider vsync}) {
    if (_tabController == null) {
      final tabController = TabController(length: _routes.length, vsync: vsync);

      addListener(() {
        if (this.index != tabController.index) {
          tabController.index = this.index;
        }
      });

      tabController.addListener(() {
        this.index = tabController.index;
      });

      _tabController = tabController;
    }

    return _tabController!;
  }
}

class CupertinoTabPlan extends RoutePlan
    with RedirectPlan, IndexedRoutePlanMixIn {
  final List<String> pathTemplates;
  final Widget Function(RouteInfo info) builder;
  final List<String> paths;

  String get redirectPath => paths[0];

  CupertinoTabPlan(
    String pathTemplate,
    this.builder, {
    required this.paths,
  }) : this.pathTemplates = [pathTemplate];

  CupertinoTabPlan.routes(
    this.pathTemplates,
    this.builder, {
    required this.paths,
  });

  @override
  RouteState createState(Routemaster delegate, RouteInfo routeInfo) {
    return CupertinoTabRouteState(this, delegate, routeInfo);
  }
}

class _CupertinoTabRouteStateProvider extends InheritedNotifier {
  final CupertinoTabRouteState routeState;

  _CupertinoTabRouteStateProvider({
    required Widget child,
    required this.routeState,
  }) : super(
          child: child,
          notifier: routeState.delegate,
        );

  @override
  bool updateShouldNotify(covariant _CupertinoTabRouteStateProvider oldWidget) {
    return true;
  }
}

class CupertinoTabRouteState extends SinglePageRouteState
    with ChangeNotifier, IndexedRouteStateMixIn {
  final CupertinoTabPlan plan;
  final Routemaster delegate;
  final RouteInfo routeInfo;
  final CupertinoTabController tabController = CupertinoTabController();

  CupertinoTabRouteState(
    this.plan,
    this.delegate,
    this.routeInfo,
  ) {
    _routes = List.filled(plan.paths.length, null);

    addListener(() {
      if (this.index != tabController.index) {
        tabController.index = this.index;
      }
    });

    tabController.addListener(() {
      this.index = tabController.index;
    });
  }

  static CupertinoTabRouteState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CupertinoTabRouteStateProvider>()!
        .routeState;
  }

  @override
  Page createPage() {
    return MaterialPage<void>(
      child: _CupertinoTabRouteStateProvider(
        routeState: this,
        child: plan.builder(routeInfo),
      ),
      key: ValueKey(routeInfo.path),
    );
  }

  Widget tabBuilder(BuildContext context, int index) {
    final stack = getStackForIndex(index);
    final pages = stack.createPages();

    assert(pages.isNotEmpty, "Pages must not be empty");

    return Navigator(
      onPopPage: stack.onPopPage,
      pages: pages,
    );
  }
}

mixin IndexedRoutePlanMixIn on RoutePlan {
  List<String> get paths;
}

mixin IndexedRouteStateMixIn on SinglePageRouteState, ChangeNotifier {
  late List<_StackRouteState?> _routes;
  RouteInfo get routeInfo;
  IndexedRoutePlanMixIn get plan;
  Routemaster get delegate;

  int _index = 0;
  int get index => _index;
  set index(int value) {
    if (value != _index) {
      _index = value;
      delegate._markNeedsUpdate();
      notifyListeners();
    }
  }

  _StackRouteState getStackForIndex(int index) {
    if (_routes[index] == null) {
      _routes[index] = _StackRouteState(
        delegate: delegate,
        routes: [
          delegate._getRoute(
            join(routeInfo.path, plan.paths[index]),
          )!,
        ],
      );
    }

    return _routes[index]!;
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
}
