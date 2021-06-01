part of '../../routemaster.dart';

/// Marks a page as not being navigable to directly. It cannot be the top-level
/// page, and if navigated to directly will redirect to a child page.
///
/// If the router tries to show this page as the top page, it'll redirect to
/// [redirectPath].
///
/// For example, you could have a set of tabs at `/home`, with the first tab
/// being `/home/profile`. If the user tries to navigate to `/home`, they'll be
/// redirected to `/home/profile`.
mixin PageContainer<T> on Page<T> {
  /// The path of a child route to redirect to.
  String get redirectPath;
}

mixin PageInserter<T extends StatefulPage<dynamic>> on PageState<T> {
  List<String> getPagesToInsert(List<PageWrapper<Page>> result);
}

class StackPage extends StatefulPage<void> with PageContainer {
  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  final String initialPath;

  @override
  String get redirectPath => initialPath;

  /// Optional function to customize the [Page] created for this route.
  /// If this is null, a [MaterialPage] is used.
  final Page Function(Widget child) pageBuilder;

  /// Initializes the page with a list of child [paths]. The provided [child]
  /// will normally show some kind of indexed navigation, such as tabs.
  const StackPage({
    required this.child,
    required this.initialPath,
    this.pageBuilder = _defaultPageBuilder,
  });

  @override
  PageState createState() {
    return StackPageState();
  }

  /// Retrieves the [StackPageState] from the closest [StackPage] ancestor.
  static StackPageState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_StackPageStateProvider>();

    assert(
      provider != null,
      "Couldn't find an StackPageState from the given context.",
    );

    return provider!.pageState;
  }
}

/// Injected into the widget tree to provide `IndexedPage.of(context)`
class _StackPageStateProvider extends InheritedWidget {
  final StackPageState pageState;

  const _StackPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
        );

  @override
  bool updateShouldNotify(covariant _StackPageStateProvider oldWidget) {
    return oldWidget.pageState != pageState;
  }
}

/// The current state of an [StackPage]. Created when the an instance of the
/// page is shown.
class StackPageState extends PageState<StackPage> with ChangeNotifier {
  /// Initializes the state for an [StackPage].
  StackPageState();

  final stack = PageStack();

  @override
  Page createPage() {
    return page.pageBuilder(
      _StackPageStateProvider(pageState: this, child: page.child),
    );
  }

  @override
  bool maybeSetChildPages(Iterable<PageWrapper> pages) {
    return stack.maybeSetChildPages(pages);
  }

  @override
  Future<bool> maybePop<E extends Object?>([E? result]) {
    return stack.maybePop(result);
  }

  @override
  Iterable<PageWrapper> getCurrentPages() sync* {
    yield this;
    yield* stack._getCurrentPages();
  }
}

class FlowPage extends StatefulPage<void> with PageContainer {
  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  final List<String> paths;

  final bool blockDirectNavigation;

  @override
  String get redirectPath => paths.first;

  /// Optional function to customize the [Page] created for this route.
  /// If this is null, a [MaterialPage] is used.
  final Page Function(Widget child) pageBuilder;

  /// Initializes the page with a list of child [paths]. The provided [child]
  /// will normally show some kind of indexed navigation, such as tabs.
  const FlowPage({
    required this.child,
    required this.paths,
    this.pageBuilder = _defaultPageBuilder,
    this.blockDirectNavigation = false,
  });

  @override
  PageState createState() {
    return FlowPageState();
  }

  /// Retrieves the [StackPageState] from the closest [StackPage] ancestor.
  static FlowPageState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_FlowPageStateProvider>();

    assert(
      provider != null,
      "Couldn't find an StackPageState from the given context.",
    );

    return provider!.pageState;
  }
}

/// Injected into the widget tree to provide `IndexedPage.of(context)`
class _FlowPageStateProvider extends InheritedWidget {
  final FlowPageState pageState;

  const _FlowPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
        );

  @override
  bool updateShouldNotify(covariant _FlowPageStateProvider oldWidget) {
    return oldWidget.pageState != pageState;
  }
}

/// The current state of an [StackPage]. Created when the an instance of the
/// page is shown.
class FlowPageState extends PageState<FlowPage>
    with ChangeNotifier, PageInserter {
  /// Initializes the state for an [StackPage].
  FlowPageState();

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
  bool maybeSetChildPages(Iterable<PageWrapper> pages) {
    return stack.maybeSetChildPages(pages);
  }

  @override
  Future<bool> maybePop<E extends Object?>([E? result]) {
    return stack.maybePop(result);
  }

  @override
  Iterable<PageWrapper> getCurrentPages() sync* {
    yield this;
    yield* stack._getCurrentPages();
  }

  @override
  List<String> getPagesToInsert(List<PageWrapper<Page>> result) {
    return _absolutePaths
        .takeWhile((value) => value != result.first.routeData.path)
        .toList();
  }

  int get currentIndex {
    return _absolutePaths.indexWhere(
      (path) => path == stack._pageWrappers.last.routeData.path,
    );
  }

  void pushNext() {
    routemaster.push(_absolutePaths[currentIndex + 1]);
  }

  void pop() {
    routemaster.push(_absolutePaths[currentIndex - 1]);
  }
}
