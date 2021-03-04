import 'package:flutter/widgets.dart';
import 'query_parser.dart';
import 'routemaster.dart';
import 'trie_router/trie_router.dart';
import 'package:path/path.dart' as path;

typedef Widget RoutemasterBuilder(
    BuildContext context, RoutemasterDelegate routemaster);

class Routemaster extends InheritedWidget {
  final RoutemasterDelegate delegate;

  Routemaster({
    required Widget child,
    required this.delegate,
  }) : super(child: child);

  static Routemaster of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Routemaster>()!;
  }

  void pop() => delegate.pop();

  void pushNamed(String name) => delegate.pushNamed(name);

  void replaceNamed(String name) => delegate.replaceNamed(name);

  @override
  bool updateShouldNotify(covariant Routemaster oldWidget) {
    return delegate != oldWidget.delegate;
  }
}

class RoutemasterDelegate extends RouterDelegate<RouteData>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteData> {
  late TrieRouter<RoutemasterRoute> _trieRouter;

  @override
  // TODO: Allow providing this key?
  final GlobalKey<NavigatorState> navigatorKey;

  final RoutemasterBuilder? builder;
  final List<RoutemasterRoute> routes;
  final String defaultPath;

  StackRouteElement? _stack;

  RoutemasterDelegate({
    required this.routes,
    this.builder,
    this.defaultPath = '/',
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    _initRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Routemaster(
      child: builder != null
          ? builder!(context, this)
          : Navigator(
              pages: getPages(),
              onPopPage: onPopPage,
              key: navigatorKey,
            ),
      delegate: this,
    );
  }

  void _initRoutes() {
    _trieRouter = TrieRouter<RoutemasterRoute>();
    for (final route in routes) {
      _trieRouter.add(route.pathTemplate, route);
    }

    final elements = getAllRoutes('/');
    // TODO: Should we just update the stack rather than creating a new one?
    _stack = StackRouteElement(
      delegate: this,
      routes: elements.toList(),
    );
  }

  void markNeedsUpdate() {
    notifyListeners();
  }

  Iterable<RoutemasterElement?> getAllRoutes(String path) {
    final result = _trieRouter.getAll(path);

    if (result == null) {
      print(
          "Router couldn't find a match for path '$path', returning default of '$defaultPath'");
      return [_getRoute(defaultPath)];
    }

    return result.map((result) => _createElement(path, result));
  }

  /// Try to get the route for [path]. If no match, returns default path.
  /// Returns null if validation fails.
  RoutemasterElement? _getRoute(String path) {
    final result = _trieRouter.get(path);
    if (result == null) {
      print(
        "Router couldn't find a match for path '$path', returning default of '$defaultPath'",
      );
      return _getRoute(defaultPath);
    }

    return _createElement(path, result);
  }

  RoutemasterElement? _createElement(
    String path,
    RouterData<RoutemasterRoute?> result,
  ) {
    final routeInfo = RouteInfo(
      path: result.path,
      pathParameters: result.parameters,
      queryParameters: QueryParser.parseQueryParameters(path),
    );

    if (result.value!.validate != null && !result.value!.validate!(routeInfo)) {
      print("Validation failed for '$path'");
      result.value!.onValidationFailed!(this, routeInfo);
      return null;
    }

    return result.value!.createElement(this, routeInfo);
  }

  @override
  RouteData? get currentConfiguration {
    // Look at the current app state and return a route path that matches it
    if (_stack == null) {
      return null;
    }

    final path = _stack!.currentRoute.routeInfo.path;

    print("Current configuration is '$path'");
    return RouteData(path);
  }

  // Called when a new URL is set. The RouteInformationParser will parse the
  // URL, and return a new [RouteData], that gets passed this this method.
  //
  // This method then modifies the state based on that information.
  @override
  Future<void> setNewRoutePath(RouteData routeData) {
    print("New route set: '${routeData.routeString}'");

    if (currentConfiguration != routeData) {
      _stack!.setRoutes(getAllRoutes(routeData.routeString));
    }

    return Future.value();
  }

  List<Page> getPages() {
    final pages = _stack!.createPages();
    assert(pages.isNotEmpty, "Returned pages list must not be empty");
    return pages;
  }

  void pop() {
    _stack!.pop();
    markNeedsUpdate();
  }

  void pushNamed(String name) {
    final newPath = path.join(this.currentConfiguration!.routeString, name);
    final routes = getAllRoutes(newPath);
    _stack!.setRoutes(routes);
    markNeedsUpdate();
  }

  void replaceNamed(String name) {
    final routes = getAllRoutes(name);
    _stack!.setRoutes(routes);
    markNeedsUpdate();
  }

  bool onPopPage(Route<dynamic> route, dynamic result) {
    return _stack!.onPopPage(route, result);
  }
}
