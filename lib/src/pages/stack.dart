part of '../../routemaster.dart';

/// The state of a stack of pages.
class StackPageState with PageState {
  final navigatorKey = GlobalKey<NavigatorState>();
  final Routemaster _delegate;

  // TODO: Can this be final?
  late List<PageState> _routes;

  @override
  RouteInfo get routeInfo => _routes.last.routeInfo;

  StackPageState({
    required Routemaster delegate,
    List<PageState>? routes,
  }) : _delegate = delegate {
    if (routes != null) {
      _routes = routes;
    }
  }

  List<Page> createPages() {
    assert(_routes.isNotEmpty, "Can't generate pages with no routes");

    final pages = _routes.map(
      (pageState) {
        if (pageState is PageCreator) {
          return pageState.createPage();
        }

        throw 'Page must be a PageCreator';
      },
    ).toList();

    assert(pages.isNotEmpty, 'Returned pages list must not be empty');

    return pages;
  }

  @override
  bool maybeSetChildPages(Iterable<PageState> pages) {
    _routes = pages.toList();
    _delegate._markNeedsUpdate();
    return true;
  }

  @override
  Iterable<PageState> getCurrentPageStates() sync* {
    yield* _routes.last.getCurrentPageStates();
  }

  /// Passed to [Navigator] widgets for them to inform this stack of a pop
  bool onPopPage(Route<dynamic> route, dynamic result) {
    if (route.didPop(result)) {
      _didPop();
      return true;
    }

    return false;
  }

  void _didPop() async {
    if (await _routes.last.maybePop()) {
      return;
    }

    if (_routes.length > 1) {
      _routes.removeLast();
      _delegate._markNeedsUpdate();
    }
  }

  @override
  Future<bool> maybePop() async {
    // First try delegating the pop to the last child route.
    // Covered by several tests in feed_test.dart
    if (await _routes.last.maybePop()) {
      return SynchronousFuture(true);
    }

    // Child wasn't interested, ask the navigator if we have a key
    if (await navigatorKey.currentState?.maybePop() == true) {
      return SynchronousFuture(true);
    }

    // No navigator attached, but we can pop the stack anyway
    if (_routes.length > 1) {
      _routes.removeLast();
      _delegate._markNeedsUpdate();
      return SynchronousFuture(true);
    }

    // Couldn't find anything to pop
    return SynchronousFuture(false);
  }
}
