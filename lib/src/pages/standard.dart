part of '../../routemaster.dart';

/// A page that can create a state.
abstract class StatefulPage<T> extends Page<T> {
  _PageState createState(Routemaster delegate, RouteInfo info);

  @override
  Route<T> createRoute(BuildContext context) {
    throw UnimplementedError(
        'Stateful pages do not directly create routes. Do not call createRoute on them directly.');
  }
}

/// The state for a page. For now, this is all private, but could be opened up
/// in future for users to make their own page subclasses.
abstract class _PageState {
  bool _maybePush(_PageState route);
  Future<bool> _maybePop();
  RouteInfo get _routeInfo;
  Iterable<_PageState> _getCurrentPageStates();
  bool _maybeSetPageStates(Iterable<_PageState> routes);
}

/// A page state that can create a single page.
mixin _PageCreator on _PageState {
  Page _createPage();
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
  _PageState createState(Routemaster delegate, RouteInfo info) {
    if (child is StatefulPage) {
      return (child as StatefulPage).createState(delegate, info);
    }

    return _StatelessPage(info, this);
  }
}

/// A wrapper for normal, non-stateless pages that allows us to treat them like
/// stateful ones.
class _StatelessPage extends _PageState with _PageCreator {
  _StatelessPage(RouteInfo routeInfo, Page page)
      : _routeInfo = routeInfo,
        _page = page;

  final Page _page;

  @override
  final RouteInfo _routeInfo;

  @override
  Iterable<_PageState> _getCurrentPageStates() sync* {
    yield this;
  }

  @override
  Future<bool> _maybePop() => SynchronousFuture(false);

  @override
  bool _maybePush(_PageState route) => false;

  @override
  bool _maybeSetPageStates(Iterable<_PageState> routes) => false;

  @override
  Page _createPage() => _page;
}
