part of '../../routemaster.dart';

class IndexedPage extends StatefulPage<void> with IndexedRouteMixIn {
  final Widget child;

  @override
  final List<String> paths;

  IndexedPage({
    required this.child,
    required this.paths,
  });

  @override
  PageState createState(Routemaster delegate, RouteInfo routeInfo) {
    return IndexedPageState(this, delegate, routeInfo);
  }
}

class _IndexedPageStateProvider extends InheritedNotifier {
  final IndexedPageState pageState;

  _IndexedPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState.delegate,
        );

  @override
  bool updateShouldNotify(covariant _IndexedPageStateProvider oldWidget) {
    return true;
  }
}

class IndexedPageState
    with PageState, PageCreator, ChangeNotifier, IndexedPageStateMixIn {
  @override
  final IndexedPage page;

  @override
  final Routemaster delegate;

  @override
  final RouteInfo routeInfo;

  IndexedPageState(
    this.page,
    this.delegate,
    this.routeInfo,
  ) {
    _routes = List.filled(page.paths.length, null);
  }

  static IndexedPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_IndexedPageStateProvider>()!
        .pageState;
  }

  @override
  Page createPage() {
    return MaterialPage<void>(
      child: _IndexedPageStateProvider(
        pageState: this,
        child: page.child,
      ),
      key: ValueKey(routeInfo),
    );
  }
}

class TabPage extends StatefulPage<void> with IndexedRouteMixIn {
  // TODO: This should probably take a page and not a widget
  final Widget child;

  @override
  final List<String> paths;

  TabPage({
    required this.child,
    required this.paths,
  });

  @override
  PageState createState(Routemaster delegate, RouteInfo routeInfo) {
    return TabPageState(this, delegate, routeInfo);
  }
}

class _TabPageStateProvider extends InheritedNotifier {
  final TabPageState pageState;

  _TabPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState.delegate,
        );

  @override
  bool updateShouldNotify(covariant _TabPageStateProvider oldWidget) {
    return true;
  }
}

class TabPageState
    with PageState, PageCreator, ChangeNotifier, IndexedPageStateMixIn {
  @override
  final TabPage page;

  @override
  final Routemaster delegate;

  @override
  final RouteInfo routeInfo;

  TabPageState(this.page, this.delegate, this.routeInfo) {
    _routes = List.filled(page.paths.length, null);
  }

  static TabPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TabPageStateProvider>()!
        .pageState;
  }

  @override
  Page createPage() {
    return MaterialPage<void>(
      child: _TabPageStateProvider(
        pageState: this,
        child: page.child,
      ),
      key: ValueKey(routeInfo),
    );
  }

  TabController? _tabController;
  TabController getTabController({required TickerProvider vsync}) {
    if (_tabController == null) {
      final tabController = TabController(length: _routes.length, vsync: vsync);

      addListener(() {
        if (index != tabController.index) {
          tabController.index = index;
        }
      });

      tabController.addListener(() {
        index = tabController.index;
      });

      _tabController = tabController;
    }

    return _tabController!;
  }
}

class CupertinoTabPage extends StatefulPage<void> with IndexedRouteMixIn {
  final Widget child;

  @override
  final List<String> paths;

  CupertinoTabPage({
    required this.child,
    required this.paths,
  });

  @override
  PageState createState(Routemaster delegate, RouteInfo routeInfo) {
    return CupertinoTabPageState(this, delegate, routeInfo);
  }
}

class _CupertinoTabPageStateProvider extends InheritedNotifier {
  final CupertinoTabPageState pageState;

  _CupertinoTabPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState.delegate,
        );

  @override
  bool updateShouldNotify(covariant _CupertinoTabPageStateProvider oldWidget) {
    return true;
  }
}

class CupertinoTabPageState
    with PageState, PageCreator, ChangeNotifier, IndexedPageStateMixIn {
  @override
  final CupertinoTabPage page;

  @override
  final Routemaster delegate;

  @override
  final RouteInfo routeInfo;

  final CupertinoTabController tabController = CupertinoTabController();

  CupertinoTabPageState(
    this.page,
    this.delegate,
    this.routeInfo,
  ) {
    _routes = List.filled(page.paths.length, null);

    addListener(() {
      if (index != tabController.index) {
        tabController.index = index;
      }
    });

    tabController.addListener(() {
      index = tabController.index;
    });
  }

  static CupertinoTabPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CupertinoTabPageStateProvider>()!
        .pageState;
  }

  @override
  Page createPage() {
    return MaterialPage<void>(
      child: _CupertinoTabPageStateProvider(
        pageState: this,
        child: page.child,
      ),
      key: ValueKey(routeInfo),
    );
  }

  Widget tabBuilder(BuildContext context, int index) {
    final stack = getStackForIndex(index);
    final pages = stack.createPages();

    assert(pages.isNotEmpty, 'Pages must not be empty');

    return Navigator(
      key: stack.navigatorKey,
      onPopPage: stack.onPopPage,
      pages: pages,
    );
  }
}

mixin IndexedRouteMixIn<T> on Page<T> {
  List<String> get paths;
}

mixin IndexedPageStateMixIn on PageCreator, ChangeNotifier {
  late List<_StackPageState?> _routes;

  Routemaster get delegate;

  @override
  RouteInfo get routeInfo;

  @override
  IndexedRouteMixIn get page;

  int _index = 0;
  int get index => _index;
  set index(int value) {
    if (value != _index) {
      _index = value;

      notifyListeners();
      delegate._markNeedsUpdate();
    }
  }

  _StackPageState getStackForIndex(int index) {
    if (_routes[index] == null) {
      final path = join(routeInfo.path, page.paths[index]);
      final route = delegate._getRoute(path);

      if (route != null) {
        _routes[index] = _StackPageState(
          delegate: delegate,
          routes: [route],
        );
      } else {
        print("Couldn't find route for '$path'!");
        // TODO: Show 404 page in debug mode
        // _routes[index] = _StackPageState(
        //   delegate: delegate,
        //   routes: [
        //     StatelessPage(
        //       RouteInfo(RouterResult()),
        //       MaterialPage<void>(
        //         child: Scaffold(
        //           body: Center(
        //             child: Text("Couldn't find route for '$path'!"),
        //           ),
        //         ),
        //       ),
        //     )
        //   ],
        // );
      }
    }

    return _routes[index]!;
  }

  int? getIndexForPath(String path) {
    var i = 0;
    for (var initialPath in page.paths) {
      if (path.startsWith(initialPath)) {
        return i;
      }
      i++;
    }

    return null;
  }

  @override
  bool maybeSetPageStates(Iterable<PageState> routes) {
    assert(
      routes.isNotEmpty,
      "Don't call maybeSetPageStates with an empty list",
    );

    final tabPagePath = routeInfo.path;
    final subPagePath = routes.first.routeInfo.path;

    if (!isWithin(tabPagePath, subPagePath)) {
      return false;
    }

    final index = getIndexForPath(_stripPath(tabPagePath, subPagePath));
    if (index == null) {
      return false;
    }

    getStackForIndex(index)._setPageStates(routes.toList());
    this.index = index;
    return true;
  }

  static String _stripPath(String parent, String child) {
    final splitParent = split(parent);
    final splitChild = split(child);
    return joinAll(splitChild.skip(splitParent.length));
  }

  @override
  bool maybePush(PageState route) {
    final index = getIndexForPath(route.routeInfo.path);
    if (index == null) {
      return false;
    }

    getStackForIndex(index).push(route);
    return true;
  }

  @override
  Future<bool> maybePop() {
    return getStackForIndex(index).maybePop();
  }

  @override
  Iterable<PageState> getCurrentPageStates() sync* {
    yield this;
    yield* getStackForIndex(index).getCurrentPageStates();
  }
}
