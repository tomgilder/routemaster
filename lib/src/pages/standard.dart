part of '../../routemaster.dart';

/// A page that can create a state.
abstract class StatefulPage<T> extends Page<T> {
  PageState createState(Routemaster delegate, RouteInfo info);

  @override
  Route<T> createRoute(BuildContext context) {
    throw UnimplementedError(
        'Stateful pages do not directly create routes. Do not call createRoute on them directly.');
  }
}

abstract class PageState {
  Future<bool> maybePop();
  RouteInfo get routeInfo;
  Iterable<PageState> getCurrentPageStates();
  bool maybeSetChildPages(Iterable<PageState> pages);
  Page createPage();
}

/// A page that wraps other pages in order to provide more functionality.
///
/// For example, [Guarded] adds validation functionality for routes.
abstract class ProxyPage<T> extends Page<T> {
  final Page<T> child;

  ProxyPage({required this.child});

  @override
  Route<T> createRoute(BuildContext context) {
    return child.createRoute(context);
  }
}

/// A wrapper for normal, non-stateless pages that allows us to treat them like
/// stateful ones.
class StatelessPage extends PageState {
  StatelessPage({
    required this.routeInfo,
    required this.page,
  }) : assert(page is! Redirect);

  final Page page;

  @override
  final RouteInfo routeInfo;

  @override
  Iterable<PageState> getCurrentPageStates() sync* {
    yield this;
  }

  @override
  Future<bool> maybePop() => SynchronousFuture(false);

  @override
  bool maybeSetChildPages(Iterable<PageState> pages) => false;

  @override
  Page createPage() => page;
}
