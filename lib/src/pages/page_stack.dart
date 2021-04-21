part of '../../routemaster.dart';

class PageStack extends ChangeNotifier {
  GlobalKey<NavigatorState>? _attachedNavigatorKey;

  List<PageWrapper>? __routes;
  List<PageWrapper> get _routes => __routes!;
  set _routes(List<PageWrapper> newRoutes) {
    if (newRoutes == __routes) {
      return;
    }

    _listenedToRoutes.forEach((route) {
      route.removeListener(notifyListeners);
    });

    _listenedToRoutes = newRoutes.whereType<Listenable>().toList()
      ..forEach((route) {
        route.addListener(notifyListeners);
      });

    __routes = newRoutes;
    notifyListeners();
  }

  List<Listenable> _listenedToRoutes = [];

  /// A map so we can keep track of each page's route data. This can be used by
  /// users to get the current page's [RouteData] via `RouteData.of(context)`.
  Map<Page, RouteData> _routeMap = {};

  PageStack({List<PageWrapper>? routes}) {
    _routes = routes ?? [];
  }

  List<Page> createPages() {
    assert(_routes.isNotEmpty, "Can't generate pages with no routes");
    _routeMap = {};
    final pages = _routes.map((pageState) {
      final page = pageState.createPage();
      _routeMap[page] = pageState.routeData;
      return page;
    }).toList();
    assert(pages.isNotEmpty, 'Returned pages list must not be empty');
    return pages;
  }

  bool maybeSetChildPages(Iterable<PageWrapper> pages) {
    _routes = pages.toList();
    return true;
  }

  Iterable<PageWrapper> _getCurrentPages() sync* {
    if (_routes.isNotEmpty) {
      yield* _routes.last.getCurrentPages();
    }
  }

  /// Passed to [Navigator] widgets for them to inform this stack of a pop
  bool onPopPage(Route<dynamic> route, dynamic result) {
    if (route.didPop(result)) {
      _routes.removeLast();
      // We don't need to notify listeners, the Navigator will rebuild itself
      return true;
    }

    return false;
  }

  Future<bool> maybePop() async {
    // First try delegating the pop to the last child route.
    if (await _routes.last.maybePop()) {
      return SynchronousFuture(true);
    }

    // Child wasn't interested, ask the navigator if we have a key
    if (await _attachedNavigatorKey?.currentState?.maybePop() == true) {
      return SynchronousFuture(true);
    }

    // No navigator attached, but we can pop the stack anyway
    if (_routes.length > 1) {
      _routes.removeLast();
      notifyListeners();
      return SynchronousFuture(true);
    }

    // Couldn't find anything to pop
    return SynchronousFuture(false);
  }
}
