library routemaster;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'src/trie_router/trie_router.dart';
import 'src/query_parser.dart';

part 'src/stack.dart';
part 'src/tab_plan.dart';

typedef Widget RoutemasterBuilder(
  BuildContext context,
  Routemaster routemaster,
);

/// Information generated from a specific path (URL).
class RouteInfo {
  final String path;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  const RouteInfo({
    required this.path,
    required this.pathParameters,
    required this.queryParameters,
  });
}

// TODO: Do we need this? Can we just use a string?
// Will this play a part in state restoration?
class RouteData {
  const RouteData(this.routeString);

  /// The pattern used to parse the route string. e.g. "/users/:id"
  final String routeString;

  @override
  bool operator ==(Object other) =>
      other is RouteData && routeString == other.routeString;

  @override
  int get hashCode => routeString.hashCode;

  @override
  String toString() => 'Route: $routeString';
}

class Routemaster extends RouterDelegate<RouteData>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteData> {
  late TrieRouter<RoutePlan> _trieRouter;

  @override
  // TODO: Allow providing this key?
  final GlobalKey<NavigatorState> navigatorKey;

  final RoutemasterBuilder? builder;
  final List<RoutePlan> plans;
  final String defaultPath;

  _StackRouteState? _stack;

  Routemaster({
    required this.plans,
    this.builder,
    this.defaultPath = '/',
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    _initRoutes();
  }

  static Routemaster of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_RoutemasterWidget>()!
        .delegate;
  }

  @override
  Widget build(BuildContext context) {
    return _RoutemasterWidget(
      child: builder != null
          ? builder!(context, this)
          : Navigator(
              pages: buildPages(),
              onPopPage: onPopPage,
              key: navigatorKey,
            ),
      delegate: this,
    );
  }

  // Returns a [RouteData] that matches the current route state.
  @override
  RouteData? get currentConfiguration {
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
      _stack!._setRoutes(_getAllRoutes(routeData.routeString));
    }

    return SynchronousFuture(null);
  }

  /// Generates all pages and sub-pages.
  List<Page> buildPages() {
    final pages = _stack!.createPages();
    assert(pages.isNotEmpty, "Returned pages list must not be empty");
    return pages;
  }

  /// Add [path] to the end of the current path.
  void pushNamed(String path) {
    replaceNamed(join(currentConfiguration!.routeString, path));
  }

  /// Replace the entire route with the path from [path].
  void replaceNamed(String path) {
    final routes = _getAllRoutes(path);
    _stack!._setRoutes(routes);
    _markNeedsUpdate();
  }

  /// Passed to [Navigator] widgets, called when the navigator requests that it
  /// wants to pop a page.
  bool onPopPage(Route<dynamic> route, dynamic result) {
    return _stack!.onPopPage(route, result);
  }

  /// Pop the top-most path from the router.
  void pop() {
    _stack!.pop();
    _markNeedsUpdate();
  }

  void _initRoutes() {
    _trieRouter = TrieRouter<RoutePlan>();
    for (final route in plans) {
      _trieRouter.add(route.pathTemplate, route);
    }

    final elements = _getAllRoutes('/');
    // TODO: Should we just update the stack rather than creating a new one?
    _stack = _StackRouteState(
      delegate: this,
      routes: elements.toList(),
    );
  }

  void _markNeedsUpdate() {
    notifyListeners();
  }

  Iterable<RouteState?> _getAllRoutes(String path) {
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
  RouteState? _getRoute(String path) {
    final result = _trieRouter.get(path);
    if (result == null) {
      print(
        "Router couldn't find a match for path '$path', returning default of '$defaultPath'",
      );
      return _getRoute(defaultPath);
    }

    return _createElement(path, result);
  }

  RouteState? _createElement(
    String path,
    RouterData<RoutePlan?> result,
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

    return result.value!.createState(this, routeInfo);
  }
}

/// Used internally so descendent widgets can use `Routemaster.of(context)`.
class _RoutemasterWidget extends InheritedWidget {
  final Routemaster delegate;

  const _RoutemasterWidget({
    required Widget child,
    required this.delegate,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant _RoutemasterWidget oldWidget) {
    return delegate != oldWidget.delegate;
  }
}

@immutable
abstract class RoutePlan {
  RoutePlan();

  String get pathTemplate;

  RouteState createState(Routemaster delegate, RouteInfo path);

  final bool Function(RouteInfo info)? validate = (_) => true;
  final void Function(Routemaster routemaster, RouteInfo info)?
      onValidationFailed = (routemaster, _) {
    routemaster.replaceNamed(routemaster.defaultPath);
  };
}

abstract class RouteState {
  bool maybeSetRoutes(Iterable<RouteState?> routes);
  bool maybePush(RouteState route);
  bool maybePop();

  RouteState get currentRoute;
  RouteInfo get routeInfo;
}

// TODO: Is this abstract class helpful to anyone?
abstract class MultiPageRouteState extends RouteState {
  List<Page> createPages();

  void pop();
  void push(RouteState routerData);
  void _setRoutes(List<RouteState> newRoutes);
}

// TODO: Is this abstract class helpful to anyone?
abstract class SinglePageRouteState extends RouteState {
  Page createPage();
}

class WidgetPlan extends RoutePlan {
  final String pathTemplate;
  final Widget Function(RouteInfo info) builder;
  final bool Function(RouteInfo info)? validate;
  final void Function(Routemaster routemaster, RouteInfo info)?
      onValidationFailed;

  WidgetPlan(
    this.pathTemplate,
    this.builder, {
    this.validate,
    this.onValidationFailed,
  });

  @override
  RouteState createState(Routemaster delegate, RouteInfo routeInfo) {
    return WidgetRouteElement(this, routeInfo);
  }
}

class WidgetRouteElement extends SinglePageRouteState {
  final WidgetPlan widgetRoute;
  final RouteInfo routeInfo;

  RouteState get currentRoute => this;

  WidgetRouteElement(this.widgetRoute, this.routeInfo);

  Page<void> createPage() {
    return MaterialPage<void>(
      child: widgetRoute.builder(routeInfo),
      key: ValueKey(routeInfo),
    );
  }

  bool maybeSetRoutes(Iterable<RouteState?> routes) {
    return false;
  }

  @override
  bool maybePush(RouteState route) {
    return false;
  }

  @override
  bool maybePop() {
    return false;
  }
}

class PagePlan extends RoutePlan {
  final String pathTemplate;
  final Page Function(RouteInfo info) builder;
  final bool Function(RouteInfo info)? validate;
  final void Function(Routemaster routemaster, RouteInfo info)?
      onValidationFailed;

  PagePlan(
    this.pathTemplate,
    this.builder, {
    this.validate,
    this.onValidationFailed,
  });

  @override
  RouteState createState(Routemaster delegate, RouteInfo routeInfo) {
    return PagePlanElement(this, routeInfo);
  }
}

class PagePlanElement extends SinglePageRouteState {
  final PagePlan pageRoute;
  final RouteInfo routeInfo;

  RouteState get currentRoute => this;

  PagePlanElement(this.pageRoute, this.routeInfo);

  Page createPage() {
    return pageRoute.builder(routeInfo);
  }

  bool maybeSetRoutes(Iterable<RouteState?> routes) {
    return false;
  }

  @override
  bool maybePush(RouteState route) {
    return false;
  }

  @override
  bool maybePop() {
    return false;
  }
}

class RoutemasterParser extends RouteInformationParser<RouteData> {
  /// RouteInformation (URL) -> Route object
  ///
  /// Takes a URL and turns it into some kind of route
  /// In this case a [RouteData], but it can be anything
  ///
  /// This should probably be automatic, matching to a list of URLs
  @override
  Future<RouteData> parseRouteInformation(
      RouteInformation routeInformation) async {
    return RouteData(routeInformation.location!);
  }

  // / Route object -> RouteInformation (URL)
  @override
  RouteInformation restoreRouteInformation(RouteData routeData) {
    return RouteInformation(location: routeData.routeString);
  }
}
