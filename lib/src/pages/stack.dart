part of '../../routemaster.dart';

/// The state of a stack of pages.
class _StackPageState with PageState {
  final Routemaster delegate;

  Page get page => throw UnimplementedError('Stacks do not have a page');

  late List<PageState> _routes;

  _StackPageState({
    required this.delegate,
    List<PageState>? routes,
  }) {
    if (routes != null) {
      _setPageStates(routes);
    }
  }

  bool onPopPage(Route<dynamic> route, dynamic result) {
    if (route.didPop(result)) {
      pop();

      return true;
    }

    return false;
  }

  void pop() {
    if (_routes.last.maybePop()) {
      return;
    }

    if (_routes.length > 1) {
      _routes.removeLast();
    }

    delegate._markNeedsUpdate();
  }

  void push(PageState route) {
    if (_routes.last.maybePush(route)) {
      return;
    }

    _routes.add(route);
    delegate._markNeedsUpdate();
  }

  List<Page> createPages() {
    assert(_routes.isNotEmpty, "Can't generate pages with no routes");

    final pages = _routes.map(
      (pageState) {
        if (pageState is PageCreator) {
          return pageState.createPage();
        }

        throw "Not a SinglePageRoute";
      },
    ).toList();

    assert(pages.isNotEmpty, "Returned pages list must not be empty");

    return pages;
  }

  void _setPageStates(Iterable<PageState> newPageStates) {
    int i = 0;

    for (final pageState in newPageStates) {
      final bool hasMoreRoutes = i < newPageStates.length - 1;

      if (hasMoreRoutes &&
          pageState.maybeSetPageStates(newPageStates.skip(i + 1))) {
        // Route has handled all of the rest of routes
        // Our job here is done
        print("StackRoute.setRoutes: adding $i routes");
        this._routes = newPageStates.take(i).toList();
        return;
      }

      i++;
    }

    this._routes = newPageStates.toList();
  }

  bool maybeSetPageStates(Iterable<PageState> routes) {
    this._routes = routes.toList();
    delegate._markNeedsUpdate();
    return true;
  }

  @override
  RouteInfo get routeInfo => this._routes.last.routeInfo;

  @override
  bool maybePush(PageState route) {
    push(route);
    return true;
  }

  @override
  bool maybePop() {
    if (_routes.last.maybePop()) {
      return true;
    }

    if (_routes.length > 1) {
      pop();
      return true;
    }

    return false;
  }

  @override
  Iterable<PageState> getCurrentPageStates() sync* {
    yield* _routes.last.getCurrentPageStates();
  }
}
