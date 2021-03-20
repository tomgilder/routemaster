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

/// The state for a page.
abstract class PageState {
  Page get page;

  bool maybeSetPageStates(Iterable<PageState> routes);
  bool maybePush(PageState route);
  Future<bool> maybePop();

  RouteInfo get routeInfo;
  Iterable<PageState> getCurrentPageStates();
}

/// A page state that can create a single page.
mixin PageCreator on PageState {
  Page createPage();
}

/// A page that wraps other pages in order to provide more functionality.
///
/// For example, [Guarded] adds validation functionality for routes.
class ProxyPage<T> extends StatefulPage<T> {
  final Page<T> child;

  ProxyPage({required this.child});

  @override
  Route<T> createRoute(BuildContext context) {
    return child.createRoute(context);
  }

  @override
  PageState createState(Routemaster delegate, RouteInfo info) {
    if (child is StatefulPage) {
      return (child as StatefulPage).createState(delegate, info);
    }

    return StatelessPage(info, this);
  }
}

/// A wrapper for normal, non-stateless pages that allows us to treat them like
/// stateful ones.
class StatelessPage extends PageState with PageCreator {
  StatelessPage(this.routeInfo, this.page);

  @override
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
  bool maybePush(PageState route) => false;

  @override
  bool maybeSetPageStates(Iterable<PageState> routes) => false;

  @override
  Page createPage() => page;
}
