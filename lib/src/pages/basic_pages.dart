part of '../../routemaster.dart';

/// A page that can create a state.
abstract class StatefulPage<T> extends Page<T> {
  const StatefulPage();

  @protected
  @factory
  PageState createState();

  @override
  Route<T> createRoute(BuildContext context) {
    throw UnimplementedError(
        'Stateful pages do not directly create routes. Do not call createRoute on them directly.');
  }
}

/// A wrapper around a page object.
abstract class PageWrapper<T extends Page<dynamic>> {
  /// Information about the current route.
  RouteData get routeData => _routeData!;
  RouteData? _routeData;

  T? _page;
  T get page => _page!;

  /// Called when popping a route stack. Returns `true` if this page wrapper
  /// has been able to pop a page, otherwise `false`.
  Future<bool> maybePop<E extends Object?>([E? result]);

  /// Returns this page, and any descendant pages below it in the navigation
  /// hierarchy.
  Iterable<PageWrapper> getCurrentPages();

  /// See if this page can consume the list of [pages] as children. For instance
  /// a tab page could accept the pages and put them in one of its tab's stacks.
  bool maybeSetChildPages(Iterable<PageWrapper> pages);

  /// Gets the actual Flutter [Page] object for passing to a [Navigator].
  ///
  /// This will only be called once per [PageWrapper], and the result cached.
  Page createPage();

  Page? _createdPage;
  Page _getOrCreatePage() {
    assert(_routeData != null);
    return _createdPage ??= createPage();
  }

  NavigationResult? result;
}

/// A page's state, similar to [State] for a [StatefulWidget]. For instance,
/// maintains the current index for a tabbed page.
abstract class PageState<T extends StatefulPage<dynamic>>
    extends PageWrapper<T> {
  Routemaster? _routemaster;
  Routemaster get routemaster => _routemaster!;

  void initState() {
    assert(_page != null);
    assert(_routemaster != null);
    assert(_routeData != null);
  }

  bool _debugTypesAreRight(Page page) => page is T;
}

/// A wrapper for normal, non-stateless pages that allows us to treat them like
/// stateful ones.
class StatelessPage extends PageWrapper {
  StatelessPage({
    required Page page,
    required RouteData routeData,
  }) {
    _page = page;
    _routeData = routeData;
  }

  @override
  Iterable<PageWrapper> getCurrentPages() sync* {
    yield this;
  }

  @override
  Future<bool> maybePop<T extends Object?>([T? result]) {
    return SynchronousFuture(false);
  }

  @override
  bool maybeSetChildPages(Iterable<PageWrapper> pages) => false;

  @override
  Page createPage() => page;
}
