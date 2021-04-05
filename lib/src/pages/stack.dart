part of '../../routemaster.dart';

/// The state of a stack of pages.
class StackPageState {
  final navigatorKey = GlobalKey<NavigatorState>();
  final RoutemasterDelegate _delegate;
  late List<PageWrapper> _routes;

  StackPageState({
    required RoutemasterDelegate delegate,
    List<PageWrapper>? routes,
  }) : _delegate = delegate {
    if (routes != null) {
      _routes = routes;
    }
  }

  List<Page> createPages() {
    assert(_routes.isNotEmpty, "Can't generate pages with no routes");
    final pages = _routes.map((pageState) => pageState.createPage()).toList();
    assert(pages.isNotEmpty, 'Returned pages list must not be empty');
    return pages;
  }

  bool maybeSetChildPages(Iterable<PageWrapper> pages) {
    _routes = pages.toList();
    _delegate._markNeedsUpdate();
    return true;
  }

  Iterable<PageWrapper> _getCurrentPages() sync* {
    yield* _routes.last.getCurrentPages();
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
