part of '../../routemaster.dart';

class IndexedPage extends StatefulPage<void> with IndexedRouteMixIn {
  final Widget child;

  @override
  final List<String> paths;

  const IndexedPage({
    required this.child,
    required this.paths,
  });

  @override
  PageState createState(Routemaster routemaster, RouteData routeData) {
    return IndexedPageState(this, routemaster, routeData);
  }

  static IndexedPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_IndexedPageStateProvider>()!
        .pageState;
  }
}

class _IndexedPageStateProvider extends InheritedNotifier {
  final IndexedPageState pageState;

  const _IndexedPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState,
        );
}

class IndexedPageState extends PageState
    with ChangeNotifier, IndexedPageStateMixIn {
  @override
  final IndexedPage page;

  @override
  final Routemaster routemaster;

  @override
  final RouteData routeData;

  IndexedPageState(
    this.page,
    this.routemaster,
    this.routeData,
  ) {
    _routes = List.filled(page.paths.length, null);
  }

  @override
  Page createPage() {
    // TODO: Provide a way for user to specify something other than MaterialPage
    return MaterialPage<void>(
      child: _IndexedPageStateProvider(
        pageState: this,
        child: page.child,
      ),
    );
  }
}

class TabPage extends StatefulPage<void> with IndexedRouteMixIn {
  final Widget child;

  @override
  final List<String> paths;

  const TabPage({
    required this.child,
    required this.paths,
  });

  @override
  PageState createState(Routemaster routemaster, RouteData routeData) {
    return TabPageState(this, routemaster, routeData);
  }

  static TabPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TabPageStateProvider>()!
        .pageState;
  }
}

class _TabPageStateProvider extends InheritedNotifier {
  final TabPageState pageState;

  const _TabPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState,
        );
}

class TabPageState extends PageState
    with ChangeNotifier, IndexedPageStateMixIn {
  @override
  final TabPage page;

  @override
  final Routemaster routemaster;

  @override
  final RouteData routeData;

  TabPageState(this.page, this.routemaster, this.routeData) {
    _routes = List.filled(page.paths.length, null);
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
      child: _TabControllerProvider(
        pageState: this,
        child: _TabPageStateProvider(
          pageState: this,
          child: page.child,
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

  const _TabControllerProvider({
    required this.child,
    required this.pageState,
  });

  @override
  _TabControllerProviderState createState() => _TabControllerProviderState();
}

class _TabControllerProviderState extends State<_TabControllerProvider>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: widget.pageState._routes.length,
      initialIndex: widget.pageState.index,
      vsync: this,
    );

    _tabController.addListener(() {
      widget.pageState.index = _tabController.index;
    });

    widget.pageState._tabController = _tabController;
  }

  @override
  void didUpdateWidget(_TabControllerProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.pageState._tabController = _tabController;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class CupertinoTabPage extends StatefulPage<void> with IndexedRouteMixIn {
  final Widget child;

  @override
  final List<String> paths;

  const CupertinoTabPage({
    required this.child,
    required this.paths,
  });

  @override
  PageState createState(Routemaster routemaster, RouteData routeData) {
    return CupertinoTabPageState(this, routemaster, routeData);
  }

  static CupertinoTabPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CupertinoTabPageStateProvider>()!
        .pageState;
  }
}

class _CupertinoTabPageStateProvider extends InheritedNotifier {
  final CupertinoTabPageState pageState;

  const _CupertinoTabPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState,
        );
}

class CupertinoTabPageState extends PageState
    with ChangeNotifier, IndexedPageStateMixIn {
  @override
  final CupertinoTabPage page;

  @override
  final Routemaster routemaster;

  @override
  final RouteData routeData;

  final CupertinoTabController tabController = CupertinoTabController();

  CupertinoTabPageState(
    this.page,
    this.routemaster,
    this.routeData,
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

  @override
  Page createPage() {
    // TODO: Provide a way for user to specify something other than MaterialPage
    return MaterialPage<void>(
      child: _CupertinoTabPageStateProvider(
        pageState: this,
        child: page.child,
      ),
    );
  }

  Widget tabBuilder(BuildContext context, int index) {
    return StackNavigator(stack: _getStackForIndex(index));
  }
}

mixin IndexedRouteMixIn<T> on Page<T> {
  List<String> get paths;
}

mixin IndexedPageStateMixIn on PageWrapper, ChangeNotifier {
  Routemaster get routemaster;
  late List<PageStack?> _routes;

  @override
  RouteData get routeData;

  IndexedRouteMixIn get page;

  StackList? _stacks;
  StackList get stacks => _stacks ??= StackList(this);

  PageStack get currentStack => _getStackForIndex(index);

  int _index = 0;
  int get index => _index;
  set index(int value) {
    if (value != _index) {
      _index = value;

      notifyListeners();
      routemaster._delegate._markNeedsUpdate();
    }
  }

  PageStack _getStackForIndex(int index) {
    if (_routes[index] == null) {
      final stack = _createInitialStackState(index);
      _routes[index] = stack;
    }

    return _routes[index]!;
  }

  PageStack _createInitialStackState(int index) {
    final path = join(routeData.path, page.paths[index]);
    final route = routemaster._delegate._getPageForTab(
      _RouteRequest(
        path: path,
        isReplacement: routeData.isReplacement,
      ),
    );
    return PageStack(routes: [route]);
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

    final tabPagePath = routeData.path;
    final subPagePath = pages.first.routeData.path;

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
    for (final initialPath in page.paths) {
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

  const StackList(this._indexedPageState);

  PageStack operator [](int index) =>
      _indexedPageState._getStackForIndex(index);
}

class _TabNotFoundPage extends StatelessPage {
  _TabNotFoundPage(String path)
      : super(
          routeData: RouteData(path, pathTemplate: null),
          page: MaterialPage<void>(
            child: DefaultUnknownRoutePage(path: path),
          ),
        );
}
