part of '../../routemaster.dart';

/// Manages a stack of pages. Used by [PageStackNavigator].
class PageStack extends ChangeNotifier {
  NavigatorState? _attachedNavigator;

  List<PageWrapper>? __pageWrappers;
  List<PageWrapper> get _pageWrappers => __pageWrappers!;
  set _pageWrappers(List<PageWrapper> newPages) {
    if (newPages == __pageWrappers) {
      return;
    }

    _listenedToRoutes.forEach((route) {
      route.removeListener(notifyListeners);
    });

    _listenedToRoutes = newPages.whereType<Listenable>().toList()
      ..forEach((route) {
        route.addListener(notifyListeners);
      });

    __pageWrappers = newPages;
    notifyListeners();
  }

  List<Listenable> _listenedToRoutes = [];

  /// A map so we can keep track of each page's route data. This can be used by
  /// users to get the current page's [RouteData] via `RouteData.of(context)`.
  Map<Page, RouteData> _routeMap = {};

  /// Manages a stack of pages.
  PageStack({List<PageWrapper> routes = const <PageWrapper>[]}) {
    _pageWrappers = routes;
  }

  /// Generates a list of pages for the list of routes provided to this object.
  List<Page> createPages() {
    assert(_pageWrappers.isNotEmpty, "Can't generate pages with no routes");

    final newRouteMap = <Page, RouteData>{};

    final pages = _pageWrappers.map((pageState) {
      final page = pageState._getOrCreatePage();

      // We need to keep any removed pages in the route map as they may still
      // rebuild whilst being removed - so for this build, the route map
      // contains both new and removed pages
      newRouteMap[page] = pageState.routeData;
      _routeMap[page] = pageState.routeData;
      return page;
    }).toList();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      // Flushes out any removed pages
      _routeMap = newRouteMap;
    });

    assert(pages.isNotEmpty, 'Returned pages list must not be empty');
    return pages;
  }

  /// Replaces the list of routes.
  bool maybeSetChildPages(Iterable<PageWrapper> pages) {
    _pageWrappers = pages.toList();
    return true;
  }

  Iterable<PageWrapper> _getCurrentPages() sync* {
    if (_pageWrappers.isNotEmpty) {
      yield* _pageWrappers;
      yield* _pageWrappers.last.getCurrentPages();
    }
  }

  /// Passed to [Navigator] widgets for them to inform this stack of a pop
  bool onPopPage(Route<dynamic> route, dynamic result) {
    if (route.didPop(result)) {
      _pageWrappers.removeLast();

      // We don't need to notify listeners, the Navigator will rebuild itself
      return true;
    }

    return false;
  }

  /// Attempts to pops this page stack. Returns `true` if a route was
  /// successfully popped, otherwise `false`.
  ///
  /// An optional value can be passed to the previous route via the [result]
  /// parameter.
  Future<bool> maybePop<T extends Object?>([T? result]) async {
    // First try delegating the pop to the last child route.
    if (await _pageWrappers.last.maybePop(result)) {
      return SynchronousFuture(true);
    }

    // Child wasn't interested, ask the navigator
    if (await _attachedNavigator?.maybePop(result) == true) {
      return SynchronousFuture(true);
    }

    // Pop the stack as a last resort
    if (_pageWrappers.length > 1) {
      _pageWrappers.removeLast();
      notifyListeners();
      return SynchronousFuture(true);
    }

    // Couldn't find anything to pop
    return SynchronousFuture(false);
  }
}
