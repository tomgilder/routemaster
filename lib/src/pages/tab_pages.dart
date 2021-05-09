part of '../../routemaster.dart';

Page _defaultPageBuilder(Widget child) {
  return MaterialPage<void>(child: child);
}

class IndexedPage extends StatefulPage<void> with IndexedRouteMixIn {
  final Widget child;

  @override
  final List<String> paths;

  final Page Function(Widget child) pageBuilder;

  const IndexedPage({
    required this.child,
    required this.paths,
    this.pageBuilder = _defaultPageBuilder,
  });

  @override
  PageState createState(Routemaster routemaster, RouteData routeData) {
    return IndexedPageState(this, routemaster, routeData);
  }

  static IndexedPageState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_IndexedPageStateProvider>();

    assert(
      provider != null,
      "Couldn't find an IndexedPageState from the given context.",
    );

    return provider!.pageState;
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
  final RouteData routeData;

  IndexedPageState(
    this.page,
    Routemaster routemaster,
    this.routeData,
  ) {
    _routemaster = routemaster;
    _routes = List.filled(page.paths.length, null);
  }

  @override
  Page createPage() {
    return page.pageBuilder(
      _IndexedPageStateProvider(
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

  final Page Function(Widget child) pageBuilder;

  const TabPage({
    required this.child,
    required this.paths,
    this.pageBuilder = _defaultPageBuilder,
  });

  @override
  PageState createState(Routemaster routemaster, RouteData routeData) {
    return TabPageState(this, routemaster, routeData);
  }

  static TabPageState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_TabPageStateProvider>();

    assert(
      provider != null,
      "Couldn't find a TabPageState from the given context.",
    );

    return provider!.pageState;
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
  final RouteData routeData;

  TabPageState(this.page, Routemaster routemaster, this.routeData) {
    _routemaster = routemaster;
    _routes = List.filled(page.paths.length, null);
  }

  @override
  set index(int value) {
    if (_controller != null) {
      _controller!.index = value;
    }

    super.index = value;
  }

  @override
  Page createPage() {
    return page.pageBuilder(
      _TabControllerProvider(
        pageState: this,
        child: _TabPageStateProvider(
          pageState: this,
          child: page.child,
        ),
      ),
    );
  }

  TabController? _controller;
  TabController get controller => _controller!;
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
    with TickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _updateController();
    widget.pageState._controller = _controller;
  }

  @override
  void didUpdateWidget(_TabControllerProvider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.pageState._routes.length != _controller!.length) {
      _updateController();
    }

    widget.pageState._controller = _controller;
  }

  void _updateController() {
    _controller?.dispose();
    _controller = TabController(
      length: widget.pageState._routes.length,
      initialIndex: widget.pageState.index,
      vsync: this,
    )..addListener(() {
        widget.pageState.index = _controller!.index;
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class CupertinoTabPage extends StatefulPage<void> with IndexedRouteMixIn {
  final Widget child;

  @override
  final List<String> paths;

  final Page Function(Widget child) pageBuilder;

  const CupertinoTabPage({
    required this.child,
    required this.paths,
    this.pageBuilder = _defaultPageBuilder,
  });

  @override
  PageState createState(Routemaster routemaster, RouteData routeData) {
    return CupertinoTabPageState(this, routemaster, routeData);
  }

  static CupertinoTabPageState of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_CupertinoTabPageStateProvider>();

    assert(
      provider != null,
      "Couldn't find a CupertinoTabPageState from the given context.",
    );

    return provider!.pageState;
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
  final RouteData routeData;

  final CupertinoTabController controller = CupertinoTabController();

  CupertinoTabPageState(
    this.page,
    Routemaster routemaster,
    this.routeData,
  ) {
    _routemaster = routemaster;
    _routes = List.filled(page.paths.length, null);

    addListener(() {
      controller.index = index;
    });

    controller.addListener(() {
      index = controller.index;
    });
  }

  @override
  Page createPage() {
    return page.pageBuilder(
      _CupertinoTabPageStateProvider(
        pageState: this,
        child: page.child,
      ),
    );
  }

  Widget tabBuilder(BuildContext context, int index) {
    return PageStackNavigator(stack: stacks[index]);
  }
}

mixin IndexedRouteMixIn<T> on Page<T> {
  List<String> get paths;
}

mixin IndexedPageStateMixIn on PageWrapper, ChangeNotifier {
  late final Routemaster _routemaster;
  late final List<PageStack?> _routes;

  @override
  RouteData get routeData;

  IndexedRouteMixIn get page;

  List<PageStack>? _stacks;
  List<PageStack> get stacks {
    return _stacks ??=
        page.paths.map((e) => _createInitialStackState(e)).toList();
  }

  PageStack get currentStack => stacks[index];

  int _index = 0;
  int get index => _index;
  set index(int value) {
    if (value != _index) {
      _index = value;

      notifyListeners();
      _routemaster._delegate._markNeedsUpdate();
    }
  }

  PageStack _createInitialStackState(String stackPath) {
    final path = PathParser.getAbsolutePath(
      basePath: routeData.fullPath,
      path: stackPath,
    );

    final route = _routemaster._delegate._getPageForTab(
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

    if (!pathContext.isWithin(tabPagePath, subPagePath)) {
      // subPagePath is not a path beneath the tab page's path.
      return false;
    }

    final index = _getIndexForPath(subPagePath);
    if (index == null) {
      // First route didn't match any of our child paths, so this isn't a route
      // that we can handle.
      return false;
    }

    // Handle route
    stacks[index].maybeSetChildPages(pages.toList());
    this.index = index;
    return true;
  }

  /// Returns an index if the given [path] can be pushed into one of the tabs.
  ///
  /// Otherwise, returns null.
  int? _getIndexForPath(String path) {
    String _getAbsoluteTabPath(String subpath) {
      return PathParser.stripQueryString(
        PathParser.getAbsolutePath(basePath: routeData.path, path: subpath),
      );
    }

    final requiredAbsolutePath = _getAbsoluteTabPath(path);

    var i = 0;
    for (final initialPath in page.paths) {
      final tabRootAbsolutePath = _getAbsoluteTabPath(initialPath);
      if (pathContext.equals(tabRootAbsolutePath, requiredAbsolutePath) ||
          pathContext.isWithin(tabRootAbsolutePath, requiredAbsolutePath)) {
        return i;
      }

      i++;
    }

    return null;
  }

  @override
  Future<bool> maybePop<T extends Object?>([T? result]) {
    return stacks[index].maybePop(result);
  }

  @override
  Iterable<PageWrapper> getCurrentPages() sync* {
    yield this;
    yield* stacks[index]._getCurrentPages();
  }
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
