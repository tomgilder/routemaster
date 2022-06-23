part of '../../routemaster.dart';

/// Manages a stack of pages. Used by [PageStackNavigator].
class PageStack extends ChangeNotifier {
  _StackNavigatorState? _attachedNavigator;

  List<PageContainer>? __pageContainers;
  List<PageContainer> get _pageContainers => __pageContainers!;
  set _pageContainers(List<PageContainer> newPages) {
    if (newPages == __pageContainers) {
      return;
    }

    __pageContainers = newPages;
    notifyListeners();
  }

  /// The count of how many pages this stack will generate.
  int get length => _pageContainers.length;

  /// A map so we can keep track of each page's route data. This can be used by
  /// users to get the current page's [RouteData] via `RouteData.of(context)`.
  Map<Page, RouteData> _routeMap = {};

  /// Manages a stack of pages.
  PageStack({List<PageContainer> routes = const <PageContainer>[]}) {
    _pageContainers = routes;
  }

  /// Generates a list of pages for the list of routes provided to this object.
  List<Page> createPages() {
    assert(_pageContainers.isNotEmpty, "Can't generate pages with no routes");

    final newRouteMap = <Page, RouteData>{};
    final pages = _pageContainers.map(
      (pageState) {
        final page = pageState._getOrCreatePage();

        // We need to keep any removed pages in the route map as they may still
        // rebuild whilst being removed - so for this build, the route map
        // contains both new and removed pages
        newRouteMap[page] = pageState.routeData;
        _routeMap[page] = pageState.routeData;
        return page;
      },
    ).toList();

    _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((timeStamp) {
      // Flushes out any removed pages
      _routeMap = newRouteMap;
    });

    assert(pages.isNotEmpty, 'Returned pages list must not be empty');
    return pages;
  }

  /// Replaces the list of routes.
  bool maybeSetChildPages(Iterable<PageContainer> pages) {
    _pageContainers = pages.toList();
    return true;
  }

  Iterable<PageContainer> _getCurrentPages() sync* {
    if (_pageContainers.isEmpty) {
      return;
    }

    yield* _pageContainers;

    final lastPage = _pageContainers.last;
    if (lastPage is MultiChildPageContainer) {
      // Delegate getting pages to last route
      yield* lastPage.getCurrentPages();
    }
  }

  RouteData? _getRouteData(Page page) {
    var route = _routeMap[page];

    if (route != null) {
      return route;
    } else {
      // It's more likely the route data will be in the currently active page
      // so go through pages in reverse order
      final multiChildChildren =
          _pageContainers.reversed.whereType<MultiChildPageContainer>();

      for (final container in multiChildChildren) {
        route = container._getRouteData(page);
        if (route != null) {
          return route;
        }
      }
    }

    return null;
  }

  /// Passed to [Navigator] widgets for the Navigator to inform this stack when
  /// a page is popped.
  bool onPopPage(
      Route<dynamic> route, dynamic result, Routemaster routemaster) {
    if (route.didPop(result)) {
      _pageContainers.removeLast();

      routemaster.history._onPopPage(
        newRoute: _pageContainers.last.routeData,
      );

      // We don't need to call notifyListeners() listeners, the Navigator will
      // rebuild its page list automatically.
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
    final lastRoute = _pageContainers.last;
    if (lastRoute is MultiChildPageContainer &&
        await lastRoute.maybePop(result)) {
      notifyListeners();
      return SynchronousFuture(true);
    }

    // Child wasn't interested, ask the navigator
    if (await _attachedNavigator?.maybePop(result) == true) {
      notifyListeners();
      return SynchronousFuture(true);
    }

    // Pop the stack as a last resort
    if (_pageContainers.length > 1) {
      _pageContainers.removeLast();
      notifyListeners();
      return SynchronousFuture(true);
    }

    // Couldn't find anything to pop
    return SynchronousFuture(false);
  }
}
