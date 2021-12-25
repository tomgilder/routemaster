part of '../../routemaster.dart';

/// Creates a flow of pages, such as a wizard. Flows are a list of pages that
/// are visited in order.
///
/// For example, in a route map:
///
/// ```
///   '/flow': (route) {
///     return FlowPage(
///       pageBuilder: (child) => BottomSheetPage(child: child),
///       child: FlowBottomSheetContents(),
///       paths: ['one', 'two'],
///     );
///   },
///
///   '/flow/one': (route) => MaterialPage(child: FlowPageOne()),
///
///   '/flow/two': (route) => MaterialPage(child: FlowPageTwo());
/// ```
class FlowPage extends StatefulPage<void> with RedirectingPage {
  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// The paths in this flow.
  ///
  /// These can be absolute paths such as `['/flow/one', '/flow/two']`, or
  /// relative paths such as `['one', 'two']`.
  final List<String> paths;

  @override
  String get redirectPath => paths.first;

  /// Optional function to customize the [Page] created for this route.
  /// If this is null, a [MaterialPage] is used.
  final Page Function(Widget child) pageBuilder;

  /// Initializes the page with a list of child [paths]. The provided [child]
  /// will normally show some kind of indexed navigation, such as tabs.
  FlowPage({
    required this.child,
    required this.paths,
    this.pageBuilder = _defaultPageBuilder,
  });

  @override
  PageState createState() {
    return FlowPageState();
  }

  /// Retrieves the [FlowPageState] from the closest [FlowPage] ancestor.
  static FlowPageState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_FlowPageStateProvider>();

    assert(
      provider != null,
      "Couldn't find an FlowPageState from the given context.",
    );

    return provider!.pageState;
  }
}

/// Injected into the widget tree to provide `IndexedPage.of(context)`
class _FlowPageStateProvider extends InheritedNotifier {
  final FlowPageState pageState;

  const _FlowPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(child: child);
}

/// The current state of an [FlowPage]. Created when the an instance of the
/// page is shown.
class FlowPageState extends PageState<FlowPage>
    with MultiChildPageContainer, ChangeNotifier {
  /// Initializes the state for an [FlowPage].
  FlowPageState();

  /// The stack for this page, which can be passed to a [StackNavigator].
  final stack = PageStack();

  late List<String> _absolutePaths;

  @override
  void initState() {
    super.initState();
    _absolutePaths = page.paths
        .map((pagePath) => pathContext.join(routeData.path, pagePath))
        .toList();
  }

  @override
  Page createPage() {
    return page.pageBuilder(
      _FlowPageStateProvider(pageState: this, child: page.child),
    );
  }

  @override
  bool maybeSetChildPages(Iterable<PageContainer> pages) {
    final tabPagePath = routeData.path;
    final subPagePath = pages.first.routeData.path;

    if (!pathContext.isWithin(tabPagePath, subPagePath)) {
      return false;
    }

    final index = _getIndexForPath(subPagePath);
    if (index == null) {
      // First route didn't match any of our child paths, so this isn't a route
      // that we can handle.
      return false;
    }

    final insertedPages = _absolutePaths.take(index).map(
          (insertPath) => _routemasterState!.delegate._getSinglePage(
            _RouteRequest(
              uri: Uri.parse(insertPath),
              requestSource: routeData.requestSource,
              isBrowserHistoryNavigation: false,
            ),
          ),
        );

    return stack.maybeSetChildPages(insertedPages.followedBy(pages));
  }

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
    return stack.maybePop(result);
  }

  @override
  Iterable<PageContainer> getCurrentPages() sync* {
    yield this;
    yield* stack._getCurrentPages();
  }

  /// The currently active index of this flow.
  int get currentIndex {
    return _absolutePaths.indexWhere(
      (path) => path == stack._pageContainers.last.routeData.path,
    );
  }

  /// Pushes the next page in this flow.
  void pushNext() {
    _routemasterState!.delegate.push(_absolutePaths[currentIndex + 1]);
  }

  /// Goes back to the previous page in this flow.
  void pop() {
    _routemasterState!.delegate.push(_absolutePaths[currentIndex - 1]);
  }

  @override
  RouteData? _getRouteData(Page page) {
    return stack._getRouteData(page);
  }
}
