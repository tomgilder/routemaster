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
  PageState createState(RoutemasterDelegate delegate, RouteInfo routeInfo) {
    return IndexedPageState(this, delegate, routeInfo);
  }

  static IndexedPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_IndexedPageStateProvider>()!
        .pageState;
  }
}

class _IndexedPageStateProvider extends InheritedNotifier {
  final IndexedPageState pageState;

  _IndexedPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState._delegate,
        );

  @override
  bool updateShouldNotify(covariant _IndexedPageStateProvider oldWidget) {
    return pageState != oldWidget.pageState;
  }
}

class IndexedPageState extends PageState
    with ChangeNotifier, IndexedPageStateMixIn {
  @override
  final IndexedPage _page;

  @override
  final RoutemasterDelegate _delegate;

  @override
  final RouteInfo routeInfo;

  IndexedPageState(
    this._page,
    this._delegate,
    this.routeInfo,
  ) {
    _routes = List.filled(_page.paths.length, null);
  }
  @override
  Page createPage() {
    // TODO: Provide a way for user to specify something other than MaterialPage
    return MaterialPage<void>(
      child: _IndexedPageStateProvider(
        pageState: this,
        child: _page.child,
      ),
      key: ValueKey(routeInfo),
    );
  }
}

class TabPage extends StatefulPage<void> with IndexedRouteMixIn {
  final Widget child;

  @override
  final List<String> paths;

  TabPage({
    required this.child,
    required this.paths,
  });

  @override
  PageState createState(RoutemasterDelegate delegate, RouteInfo routeInfo) {
    return TabPageState(this, delegate, routeInfo);
  }

  static TabPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TabPageStateProvider>()!
        .pageState;
  }
}

class _TabPageStateProvider extends InheritedNotifier {
  final TabPageState pageState;

  _TabPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState._delegate,
        );

  @override
  bool updateShouldNotify(covariant _TabPageStateProvider oldWidget) {
    return pageState != oldWidget.pageState;
  }
}

class TabPageState extends PageState
    with ChangeNotifier, IndexedPageStateMixIn {
  @override
  final TabPage _page;

  @override
  final RoutemasterDelegate _delegate;

  @override
  final RouteInfo routeInfo;

  TabPageState(this._page, this._delegate, this.routeInfo) {
    _routes = List.filled(_page.paths.length, null);
  }

  @override
  set index(int value) {
    if (_tabController != null) {
      _tabController!.index = value;
    }

    super.index = value;
  }

  @override
  Page createPage() {
    // TODO: Provide a way for user to specify something other than MaterialPage
    return MaterialPage<void>(
      key: ValueKey(routeInfo),
      child: _TabControllerProvider(
        pageState: this,
        child: _TabPageStateProvider(
          pageState: this,
          child: Builder(builder: (_) => _page.child),
        ),
      ),
    );
  }

  TabController? _tabController;
  TabController get tabController => _tabController!;
}

/// Creates a [TabController] for [TabPageState]
class _TabControllerProvider extends StatefulWidget {
  final Widget child;
  final TabPageState pageState;

  _TabControllerProvider({
    required this.child,
    required this.pageState,
  });

  @override
  _TabControllerProviderState createState() => _TabControllerProviderState();
}

class _TabControllerProviderState extends State<_TabControllerProvider>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    final tabController = TabController(
      length: widget.pageState._routes.length,
      initialIndex: widget.pageState.index,
      vsync: this,
    );

    tabController.addListener(() {
      widget.pageState.index = tabController.index;
    });

    widget.pageState._tabController = tabController;
  }

  @override
  void dispose() {
    widget.pageState._tabController?.dispose();
    widget.pageState._tabController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
  PageState createState(RoutemasterDelegate delegate, RouteInfo routeInfo) {
    return CupertinoTabPageState(this, delegate, routeInfo);
  }

  static CupertinoTabPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CupertinoTabPageStateProvider>()!
        .pageState;
  }
}

class _CupertinoTabPageStateProvider extends InheritedNotifier {
  final CupertinoTabPageState pageState;

  _CupertinoTabPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState._delegate,
        );

  @override
  bool updateShouldNotify(covariant _CupertinoTabPageStateProvider oldWidget) {
    return pageState != oldWidget.pageState;
  }
}

class CupertinoTabPageState extends PageState
    with ChangeNotifier, IndexedPageStateMixIn {
  @override
  final CupertinoTabPage _page;

  @override
  final RoutemasterDelegate _delegate;

  @override
  final RouteInfo routeInfo;

  final CupertinoTabController tabController = CupertinoTabController();

  CupertinoTabPageState(
    this._page,
    this._delegate,
    this.routeInfo,
  ) {
    _routes = List.filled(_page.paths.length, null);

    addListener(() {
      if (index != tabController.index) {
        tabController.index = index;
      }
    });

    tabController.addListener(() {
      index = tabController.index;
    });
  }

  @override
  Page createPage() {
    // TODO: Provide a way for user to specify something other than MaterialPage
    return MaterialPage<void>(
      child: _CupertinoTabPageStateProvider(
        pageState: this,
        child: _page.child,
      ),
      key: ValueKey(routeInfo),
    );
  }

  Widget tabBuilder(BuildContext context, int index) {
    final stack = _getStackForIndex(index);
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

mixin IndexedPageStateMixIn on PageWrapper, ChangeNotifier {
  late List<StackPageState?> _routes;

  RoutemasterDelegate get _delegate;

  @override
  RouteInfo get routeInfo;

  IndexedRouteMixIn get _page;

  StackList? _stacks;
  StackList get stacks => _stacks ??= StackList(this);

  StackPageState get currentStack => _getStackForIndex(index);

  int _index = 0;
  int get index => _index;
  set index(int value) {
    if (value != _index) {
      _index = value;

      notifyListeners();
      _delegate._markNeedsUpdate();
    }
  }

  StackPageState _getStackForIndex(int index) {
    if (_routes[index] == null) {
      _routes[index] = _createInitialStackState(index);
    }

    return _routes[index]!;
  }

  StackPageState? _createInitialStackState(int index) {
    final path = join(routeInfo.path, _page.paths[index]);
    final route = _delegate._getPageWrapper(_RouteRequest(
      path: path,
      isReplacement: routeInfo.isReplacement,
    ));
    return StackPageState(delegate: _delegate, routes: [route]);
  }

  /// Attempts to handle a list of child pages.
  ///
  /// Checks if the first route matches one of the child paths of this tab page.
  /// If it does, it sets that stack's pages to the routes, and switches the
  /// current index to that tab.
  @override
  bool maybeSetChildPages(Iterable<PageWrapper> pages) {
    assert(
      pages.isNotEmpty,
      "Don't call maybeSetPageStates with an empty list",
    );

    final tabPagePath = routeInfo.path;
    final subPagePath = pages.first.routeInfo.path;

    if (!isWithin(tabPagePath, subPagePath)) {
      // subPagePath is not a path beneath the tab page's path.
      return false;
    }

    final index = _getIndexForPath(_stripPath(tabPagePath, subPagePath));
    if (index == null) {
      // First route didn't match any of our child paths, so this isn't a route
      // that we can handle.
      return false;
    }

    // Handle route
    _getStackForIndex(index).maybeSetChildPages(pages.toList());
    this.index = index;
    return true;
  }

  int? _getIndexForPath(String path) {
    var i = 0;
    for (final initialPath in _page.paths) {
      if (path.startsWith(initialPath)) {
        return i;
      }
      i++;
    }

    return null;
  }

  static String _stripPath(String parent, String child) {
    final splitParent = split(parent);
    final splitChild = split(child);
    return joinAll(splitChild.skip(splitParent.length));
  }

  @override
  Future<bool> maybePop() {
    return _getStackForIndex(index).maybePop();
  }

  @override
  Iterable<PageWrapper> getCurrentPages() sync* {
    yield this;
    yield* _getStackForIndex(index)._getCurrentPages();
  }
}

class StackList {
  final IndexedPageStateMixIn _indexedPageState;

  StackList(this._indexedPageState);

  StackPageState operator [](int index) =>
      _indexedPageState._getStackForIndex(index);
}
