part of '../../routemaster.dart';

class NestedPage extends StatefulPage<void> {
  final Widget child;

  final List<String> paths;

  const NestedPage({
    required this.child,
    required this.paths,
  });

  @override
  PageState createState(Routemaster routemaster, RouteData routeData) {
    return NestedPageState(this, routemaster, routeData);
  }

  static NestedPageState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_NestedPageStateProvider>();

    assert(
      provider != null,
      "Couldn't find an NestedPageState from the given context.",
    );

    return provider!.pageState;
  }
}

class _NestedPageStateProvider extends InheritedNotifier {
  final NestedPageState pageState;

  const _NestedPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState,
        );
}

class NestedPageState extends PageState with ChangeNotifier {
  final NestedPage page;

  @override
  final RouteData routeData;

  NestedPageState(
    this.page,
    Routemaster routemaster,
    this.routeData,
  ) {
    _routemaster = routemaster;
  }

  @override
  Page createPage() {
    // TODO: Provide a way for user to specify something other than MaterialPage
    return MaterialPage<void>(
      child: _NestedPageStateProvider(
        pageState: this,
        child: page.child,
      ),
    );
  }

  late final Routemaster _routemaster;

  // @override
  // RouteData get routeData;

  // IndexedRouteMixIn get _tabPage;

  List<PageStack>? _stacks;
  List<PageStack> get stacks {
    return _stacks ??=
        page.paths.map((e) => _createInitialStackState(e)).toList();
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
    // TODO: ???
    return SynchronousFuture(false);
  }

  @override
  Iterable<List<PageWrapper>> getCurrentPages() sync* {
    for (final stack in stacks) {
      yield* stack._getCurrentPages();
    }
  }
}
