part of '../../routemaster.dart';

/// A page that can create a state.
abstract class StatefulPage<T> extends Page<T> {
  const StatefulPage();

  PageState createState(Routemaster routemaster, RouteData info);

  @override
  Route<T> createRoute(BuildContext context) {
    throw UnimplementedError(
        'Stateful pages do not directly create routes. Do not call createRoute on them directly.');
  }
}

/// A wrapper around a page object.
abstract class PageWrapper {
  /// Information about the current route.
  RouteData get routeData;

  /// Called when popping a route stack. Returns `true` if this page wrapper
  /// has been able to pop a page, otherwise `false`.
  Future<bool> maybePop();

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

  Page? _page;
  Page _getOrCreatePage() {
    return _page ??= createPage();
  }
}

/// A page's state, similar to [State] for a [StatefulWidget]. For instance,
/// maintains the current index for a tabbed page.
abstract class PageState extends PageWrapper {}

/// A wrapper for normal, non-stateless pages that allows us to treat them like
/// stateful ones.
class StatelessPage extends PageWrapper {
  StatelessPage({
    required this.routeData,
    required this.page,
  }) : assert(page is! Redirect);

  final Page page;

  @override
  final RouteData routeData;

  @override
  Iterable<PageWrapper> getCurrentPages() sync* {
    yield this;
  }

  @override
  Future<bool> maybePop() => SynchronousFuture(false);

  @override
  bool maybeSetChildPages(Iterable<PageWrapper> pages) => false;

  @override
  Page createPage() => page;
}
