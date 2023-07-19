part of '../../routemaster.dart';

/// Specifies how tabs behave when used with the system back button.
enum TabBackBehavior {
  /// Switching tabs will not affect the route history.
  ///
  /// The system back button will never navigate between tabs.
  none,

  /// Switching tabs will add routes to the route history.
  ///
  /// The system back button will navigate backwards through tabs
  /// chronologically, in the order the user visited them.
  history,
}

Page<dynamic> _defaultPageBuilder(Widget child) {
  return MaterialPage<void>(child: child);
}

/// A page for creating an indexed page, such as a custom tab bar. Can be used
/// with Flutter's [NavigationBar] widget, see the [navigation_bar example][navigation_bar example].
///
/// [navigation_bar example]: https://github.com/tomgilder/routemaster/tree/main/example/navigation_bar
///
/// For Flutter's standard [TabBar] widget, use [TabPage], which will create and
/// manage a [TabController].
///
/// For Cupertino-style tabs, use [CupertinoTabPage], which will create and
/// manage a [CupertinoTabController].
class IndexedPage extends StatefulPage<void> with IndexedRouteMixIn {
  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  @override
  final List<String> paths;

  /// Optional function to customize the [Page] created for this route.
  /// If this is null, a [MaterialPage] is used.
  final Page<dynamic> Function(Widget child) pageBuilder;

  /// Specifies how tabs behave when used with the system back button.
  final TabBackBehavior backBehavior;

  /// Initializes the page with a list of child [paths]. The provided [child]
  /// will normally show some kind of indexed navigation, such as tabs.
  const IndexedPage({
    required this.child,
    required this.paths,
    this.pageBuilder = _defaultPageBuilder,
    this.backBehavior = TabBackBehavior.none,
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
    required super.child,
    required this.pageState,
  }) : super(
          notifier: pageState,
        );
}

/// The current state of an [IndexedPage]. Created when an instance of the page
/// is shown. Provides a list of track of the currently active index.
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
  TabBackBehavior get backBehavior => page.backBehavior;

  @override
  void initState() {
    super.initState();
    _routes = List.filled(page.paths.length, null);
  }

  @override
  Page<dynamic> createPage() {
    return page.pageBuilder(
      _IndexedPageStateProvider(
        pageState: this,
        child: page.child,
      ),
    );
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
    on PageState<T>, ChangeNotifier
    implements MultiChildPageContainer<T> {
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

  /// The current tab index.
  int get index => _index;
  int _index = 0;

  /// How the back button should be handled.
  final TabBackBehavior backBehavior = TabBackBehavior.none;

  /// The currently active index.
  set index(int value) {
    if (value != _index) {
      _index = value;

      notifyListeners();
      _routemasterState!.delegate._updateCurrentConfiguration(
        isReplacement: backBehavior == TabBackBehavior.none,
      );
    }
  }

  PageStack _createInitialStackState(String stackPath) {
    final path = PathParser.getAbsolutePath(
      basePath: routeData.fullPath,
      path: stackPath,
    );

    final route = _routemasterState!.delegate._getSinglePage(
      _RouteRequest(
        uri: path,
        isReplacement: routeData.isReplacement,
        requestSource: routeData.requestSource,
        isBrowserHistoryNavigation: false,
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
  bool maybeSetChildPages(Iterable<PageContainer> pages) {
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
    String getAbsoluteTabPath(String subpath) {
      return PathParser.getAbsolutePath(
        basePath: routeData.path,
        path: subpath,
      ).path;
    }

    final requiredAbsolutePath = getAbsoluteTabPath(path);

    var i = 0;
    for (final initialPath in page.paths) {
      final tabRootAbsolutePath = getAbsoluteTabPath(initialPath);
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
  Iterable<PageContainer> getCurrentPages() sync* {
    yield this;
    yield* stacks[index]._getCurrentPages();
  }

  @override
  RouteData? _getRouteData(Page<dynamic> page) {
    // It's likely the route data will be in the currently active page so
    // check that first
    final routeData = stacks[index]._getRouteData(page);
    if (routeData != null) {
      return routeData;
    }

    for (var i = 0; i < stacks.length; i++) {
      if (i == index) {
        continue;
      }

      final stack = stacks[i];
      final routeData = stack._getRouteData(page);
      if (routeData != null) {
        return routeData;
      }
    }

    return null;
  }
}

class _TabNotFoundPage extends StatelessPage {
  _TabNotFoundPage(_RouteRequest request)
      : super(
          routeData: RouteData(
            request.uri.toString(),
            pathTemplate: request.uri.toString(),
          ),
          page: MaterialPage<void>(
            child: DefaultNotFoundPage(path: request.uri.toString()),
          ),
        );
}
