part of '../../routemaster.dart';

Page _defaultPageBuilder(Widget child) {
  return MaterialPage<void>(child: child);
}

/// A page for creating an indexed page, such as a tab bar. In most use cases,
/// it's easier to use a [TabPage] or [CupertinoTabPage].
///
/// This class is only for very custom cases that don't require a
/// [TabController] or [CupertinoTabController].
class IndexedPage extends StatefulPage<void>
    with IndexedRouteMixIn, PageContainer {
  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  @override
  final List<String> paths;

  /// Optional function to customize the [Page] created for this route.
  /// If this is null, a [MaterialPage] is used.
  final Page Function(Widget child) pageBuilder;

  @override
  String get redirectPath => paths[0];

  /// Initializes the page with a list of child [paths]. The provided [child]
  /// will normally show some kind of indexed navigation, such as tabs.
  const IndexedPage({
    required this.child,
    required this.paths,
    this.pageBuilder = _defaultPageBuilder,
  });

  @override
  PageState createState() {
    return IndexedPageState();
  }

  /// Retrieves the [IndexedPageState] from the closest [IndexPage] ancestor.
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

/// Injected into the widget tree to provide `IndexedPage.of(context)`
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

/// The current state of an [IndexedPage]. Created when the an instance of the
/// page is shown. Provides a list of track of the currently active index.
///
///   * [stacks] - a list of [PageStack] objects that manage the child routes.
///
///   * [index] - the currently active index.
///
class IndexedPageState extends PageState<IndexedPage>
    with ChangeNotifier, IndexedPageStateMixIn {
  /// Initializes the state for an [IndexedPage].
  IndexedPageState();

  @override
  void initState() {
    super.initState();
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

/// A page used to manage tab views. Its state object creates and manages a
/// [TabController] that can be retrieved via `TabPage.of(context).controller`.
class TabPage extends StatefulPage<void> with IndexedRouteMixIn, PageContainer {
  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  @override
  final List<String> paths;

  /// Optional function to customize the [Page] created for this route.
  /// If this is null, a [MaterialPage] is used.
  final Page Function(Widget child) pageBuilder;

  @override
  String get redirectPath => paths[0];

  /// Initializes the page with a list of child [paths].
  const TabPage({
    required this.child,
    required this.paths,
    this.pageBuilder = _defaultPageBuilder,
  });

  @override
  PageState createState() {
    return TabPageState();
  }

  /// Retrieves the nearest [TabPageState] ancestor.
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

/// The state for a [TabPage]. Creates and manages a [TabController] that can be
/// retrieved via `TabPage.of(context).controller`.
class TabPageState extends PageState<TabPage>
    with ChangeNotifier, IndexedPageStateMixIn {
  /// Initializes the state for a [TabPage].
  TabPageState();

  @override
  void initState() {
    super.initState();
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

  /// The [TabController] for this page that can be passed to widgets such as
  /// `TabBar` and `TabBarView`.
  TabController get controller => _controller!;
  TabController? _controller;
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

/// A page used to manage a [CupertinoTabBar] and its child routes.
///
/// Example:
///
/// ```
/// final tabState = CupertinoTabPage.of(context);
/// final scaffold = CupertinoTabScaffold(
///   controller: tabState.controller,
///   tabBuilder: tabState.tabBuilder,
///   tabBar: CupertinoTabBar(
///     items: [
///       BottomNavigationBarItem(
///         label: 'Feed',
///         icon: Icon(CupertinoIcons.list_bullet),
///       ),
///       BottomNavigationBarItem(
///         label: 'Settings',
///         icon: Icon(CupertinoIcons.search),
///       ),
///     ],
///   ),
/// );
/// ```
class CupertinoTabPage extends StatefulPage<void>
    with IndexedRouteMixIn, PageContainer {
  /// The child [Widget] that will display the [CupertinoTabBar].
  final Widget child;

  @override
  final List<String> paths;

  /// Optional function to customize the [Page] created for this route.
  /// If this is null, a [MaterialPage] is used.
  final Page Function(Widget child) pageBuilder;

  @override
  String get redirectPath => paths[0];

  /// Initializes the page with a list of child [paths].
  const CupertinoTabPage({
    required this.child,
    required this.paths,
    this.pageBuilder = _defaultPageBuilder,
  });

  @override
  PageState createState() {
    return CupertinoTabPageState();
  }

  /// Retrieves the nearest [CupertinoTabPageState] ancestor.
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

/// The state for a [CupertinoTabPage]. Creates and manages a
/// [CupertinoTabController] that can be accessed by calling
/// `CupertinoTabPage.of(context).controller`.
class CupertinoTabPageState extends PageState<CupertinoTabPage>
    with ChangeNotifier, IndexedPageStateMixIn {
  /// Initializes the state for a [CupertinoTabPage].
  CupertinoTabPageState();

  /// A tab controller that is managed by this page state.
  ///
  /// Normally accessed by calling `CupertinoTabPage.of(context).controller`.
  final CupertinoTabController controller = CupertinoTabController();

  @override
  void initState() {
    super.initState();

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

  /// Returns the [PageStackNavigator] for the given [index].
  ///
  /// This can be passed to the [tabBuilder] property of a
  /// [CupertinoTabScaffold]:
  ///
  /// ```
  /// final tabState = CupertinoTabPage.of(context);
  /// final scaffold = CupertinoTabScaffold(
  ///   controller: tabState.controller,
  ///   tabBuilder: tabState.tabBuilder,
  ///   ...
  /// )
  /// ```
  Widget tabBuilder(BuildContext context, int index) {
    return PageStackNavigator(stack: stacks[index]);
  }
}

/// An interface for [StatefulPage] that provides a list of child route paths.
mixin IndexedRouteMixIn<T> on StatefulPage<T> {
  /// A list of the child paths. These can be relative (for example `'one'`) or
  /// absolute (for example `'/tabs/one'`).
  ///
  /// Example: `['/tabs/one', '/tabs/two']`
  List<String> get paths;
}

/// Provides functionality for indexed pages, including managing the active
/// index and a list of [PageStack] objects.
mixin IndexedPageStateMixIn<T extends IndexedRouteMixIn<dynamic>>
    on PageState<T>, ChangeNotifier {
  late final List<PageStack?> _routes;

  List<PageStack>? _stacks;

  /// A list of [PageStack] objects, for each child path specified in the page.
  List<PageStack> get stacks {
    return _stacks ??=
        page.paths.map((e) => _createInitialStackState(e)).toList();
  }

  /// The currently active stack of pages.
  ///
  /// Equivalent to `pageState.stacks[pageStage.index]`.
  PageStack get currentStack => stacks[index];

  int _index = 0;
  int get index => _index;

  /// The currently active index.
  set index(int value) {
    if (value != _index) {
      _index = value;

      notifyListeners();
      routemaster._delegate._markNeedsUpdate();
    }
  }

  PageStack _createInitialStackState(String stackPath) {
    final path = PathParser.getAbsolutePath(
      basePath: routeData.fullPath,
      path: stackPath,
    );

    final route = routemaster._delegate._getSinglePage(
      _RouteRequest(
        uri: path,
        isReplacement: routeData.isReplacement,
        source: routeData.source,
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
      return PathParser.getAbsolutePath(
        basePath: routeData.path,
        path: subpath,
      ).path;
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
  Future<bool> maybePop<E extends Object?>([E? result]) {
    return stacks[index].maybePop(result);
  }

  @override
  Iterable<PageWrapper> getCurrentPages() sync* {
    yield this;
    yield* stacks[index]._getCurrentPages();
  }
}

class _TabNotFoundPage extends PageWrapper {
  _TabNotFoundPage(_RouteRequest request)
      : super.fromPage(
          routeData: RouteData(
            request.uri.toString(),
            pathTemplate: null,
            source: request.source,
          ),
          page: MaterialPage<void>(
            child: DefaultNotFoundPage(path: request.uri.toString()),
          ),
        );
}
