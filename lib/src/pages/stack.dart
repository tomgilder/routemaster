part of '../../routemaster.dart';

/// The state of a stack of pages.
class StackPageState with _PageState {
  final navigatorKey = GlobalKey<NavigatorState>();

  final Routemaster _delegate;
  late List<_PageState> _routes;

  StackPageState({
    required Routemaster delegate,
    List<_PageState>? routes,
  }) : _delegate = delegate {
    if (routes != null) {
      _setPageStates(routes);
    }
  }

  /// Passed to [Navigator] widgets for them to inform this stack of a pop
  bool onPopPage(Route<dynamic> route, dynamic result) {
    if (route.didPop(result)) {
      _pop();

      return true;
    }

    return false;
  }

  List<Page> createPages() {
    assert(_routes.isNotEmpty, "Can't generate pages with no routes");

    final pages = _routes.map(
      (pageState) {
        if (pageState is _PageCreator) {
          return pageState._createPage();
        }

        throw 'Not a SinglePageRoute';
      },
    ).toList();

    assert(pages.isNotEmpty, 'Returned pages list must not be empty');

    return pages;
  }

  void _pop() async {
    if (await _routes.last._maybePop()) {
      return;
    }

    if (_routes.length > 1) {
      _routes.removeLast();
    }

    _delegate._markNeedsUpdate();
  }

  void _push(_PageState route) {
    if (_routes.last._maybePush(route)) {
      return;
    }

    _routes.add(route);
    _delegate._markNeedsUpdate();
  }

  void _setPageStates(Iterable<_PageState> newPageStates) {
    var i = 0;

    for (final pageState in newPageStates) {
      final hasMoreRoutes = i < newPageStates.length - 1;

      if (hasMoreRoutes &&
          pageState._maybeSetPageStates(newPageStates.skip(i + 1))) {
        // Route has handled all of the rest of routes
        // Our job here is done
        print('StackRoute.setRoutes: adding $i routes');
        _routes = newPageStates.take(i).toList();
        return;
      }

      i++;
    }

    _routes = newPageStates.toList();
  }

  @override
  bool _maybeSetPageStates(Iterable<_PageState> routes) {
    _routes = routes.toList();
    _delegate._markNeedsUpdate();
    return true;
  }

  @override
  RouteInfo get _routeInfo => _routes.last._routeInfo;

  @override
  bool _maybePush(_PageState route) {
    _push(route);
    return true;
  }

  @override
  Future<bool> _maybePop() async {
    // First try delegating the pop to the last child route
    if (await _routes.last._maybePop()) {
      return SynchronousFuture(true);
    }

    // Child wasn't interested, ask a navigator if we have a key
    if (await navigatorKey.currentState?.maybePop() == true) {
      return SynchronousFuture(true);
    }

    // No navigator attached, but we can pop the stack anyway
    if (_routes.length > 1) {
      _pop();
      return SynchronousFuture(true);
    }

    // Couldn't find anything to pop
    return SynchronousFuture(false);
  }

  @override
  Iterable<_PageState> _getCurrentPageStates() sync* {
    yield* _routes.last._getCurrentPageStates();
  }
}
