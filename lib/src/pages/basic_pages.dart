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

/// A wrapper around a [Page] that holds additional routing information and
/// provides navigation functions.
class PageWrapper<T extends Page<dynamic>> {
  PageWrapper._();

  /// Creates a stateless wrapper from the given page and routing data.
  PageWrapper.fromPage({
    required T page,
    required RouteData routeData,
  }) {
    _page = page;
    _routeData = routeData;
  }

  /// Information about the current route.
  RouteData get routeData => _routeData!;
  RouteData? _routeData;

  /// The page object that will be added to a [Navigator].
  T get page => _page!;
  T? _page;

  /// Called when popping a route stack. Returns `true` if this page wrapper
  /// has been able to pop a page, otherwise `false`.
  ///
  /// By default this returns `false`.
  Future<bool> maybePop<E extends Object?>([E? result]) {
    return SynchronousFuture(false);
  }

  /// Returns this page, and any descendant pages below it in the navigation
  /// hierarchy.
  ///
  /// By default this only returns this page wrapper.
  Iterable<PageWrapper> getCurrentPages() sync* {
    yield this;
  }

  /// See if this page can consume the list of [pages] as children. For instance
  /// a tab page could accept the pages and put them in one of its tab's stacks.
  ///
  /// By default this returns false.
  bool maybeSetChildPages(Iterable<PageWrapper> pages) => false;

  /// Provides access to the [Route] created from this page, and any result
  /// returned via popping the route.
  NavigationResult? result;

  /// Gets the actual Flutter [Page] object for passing to a [Navigator].
  ///
  /// This will only be called once per [PageWrapper], and the result cached.
  Page createPage() {
    return _page!;
  }

  Page? _createdPage;
  Page _getOrCreatePage() {
    assert(_routeData != null);
    return _createdPage ??= createPage();
  }
}

/// A [Page] object that can create a state, for instance to keep track of
/// the current tab index. Similar to [StatefulWidget].
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
    extends PageWrapper<T> {
  /// Initializes the state for a [StatefulPage].
  PageState() : super._();

  _RoutemasterState? _routemasterState;

  /// Called once to initialize the state of this page.
  void initState() {
    assert(_page != null);
    assert(_routemasterState != null);
    assert(_routeData != null);
  }

  bool _debugTypesAreRight(Page page) => page is T;
}
