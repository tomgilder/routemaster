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
mixin RedirectingPage<T> on Page<T> {
  /// The path of a child route to redirect to.
  String get redirectPath;
}

/// Provides routing information about a [Page].
mixin PageContainer<T extends Page<dynamic>> {
  /// Route information for this page.
  RouteData get routeData;

  /// Provides access to the [Route] created from this page, and any result
  /// returned via popping the route.
  NavigationResult? _result;

  Page _getOrCreatePage();
}

/// A [PageContainer] for a regular [Page] that maintains no state.
///
/// Page containers associate [RouteData] with a page.
class StatelessPage<T extends Page<dynamic>> with PageContainer {
  /// Creates a stateless page container from the given page and routing data.
  StatelessPage({
    required T page,
    required RouteData routeData,
  })  : _page = page,
        _routeData = routeData;

  @override
  Page _getOrCreatePage() => _page;
  final Page _page;

  /// Route information for this page.
  @override
  RouteData get routeData => _routeData!;
  final RouteData? _routeData;
}

/// A [Page] that can create a state, for instance to keep track of the current
/// tab index. Similar to [StatefulWidget].
abstract class StatefulPage<T> extends Page<T> {
  /// Initializes a stateful page.
  const StatefulPage();

  /// Returns a state object for this page.
  @protected
  @factory
  PageState createState();

  @override
  Route<T> createRoute(BuildContext context) {
    throw UnimplementedError(
      'Stateful pages do not directly create routes. Do not call createRoute on them directly.',
    );
  }
}

/// A page's state, similar to [State] for a [StatefulWidget]. For instance,
/// maintains the current index for a tabbed page.
abstract class PageState<T extends StatefulPage<dynamic>>
    with PageContainer<T> {
  /// Initializes the state for a [StatefulPage].
  PageState();

  _RoutemasterState? _routemasterState;

  @override
  RouteData get routeData => _routeData!;
  RouteData? _routeData;

  /// The [StatefulPage] associated witht this page state.
  T get page => _page!;
  T? _page;

  /// Gets the actual Flutter [Page] object for passing to a [Navigator].
  ///
  /// This will only be called once per [PageState], and the result cached.
  Page createPage();

  Page? _createdChildPage;

  @override
  Page _getOrCreatePage() {
    _createdChildPage ??= createPage();
    return _createdChildPage!;
  }

  /// Called once to initialize the state of this page.
  void initState() {
    assert(_page != null);
    assert(_routemasterState != null);
    assert(_routeData != null);
  }

  bool _debugTypesAreRight(Page page) => page is T;
}

/// A stateful page that hosts other child pages.
mixin MultiChildPageContainer<T extends StatefulPage<dynamic>> on PageState<T> {
  /// Called when popping a route stack. Returns `true` if this page container
  /// has been able to pop a page, otherwise `false`.
  Future<bool> maybePop<E extends Object?>([E? result]);

  /// Returns this page, and any descendant pages below it in the navigation
  /// hierarchy.
  Iterable<PageContainer> getCurrentPages();

  /// See if this page can consume the list of [pages] as children. For instance
  /// a tab page could accept the pages and put them in one of its tab's stacks.
  bool maybeSetChildPages(Iterable<PageContainer> pages);

  RouteData? _getRouteData(Page page);
}
