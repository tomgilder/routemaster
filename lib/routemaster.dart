library routemaster;

export 'src/parser.dart';
export 'src/route_data.dart';
export 'src/pages/guard.dart';

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';
import 'src/pages/guard.dart';
import 'src/path_parser.dart';
import 'src/system_nav.dart';
import 'src/trie_router/trie_router.dart';
import 'src/route_data.dart';

part 'src/pages/page_stack.dart';
part 'src/pages/tab_pages.dart';
part 'src/pages/basic_pages.dart';
part 'src/observers.dart';

typedef RoutemasterBuilder = Widget Function(
  BuildContext context,
  List<Page> pages,
  PopPageCallback onPopPage,
  GlobalKey<NavigatorState> navigatorKey,
);

typedef PageBuilder = Page Function(RouteData route);

typedef UnknownRouteCallback = Page Function(
  String path,
  BuildContext context,
);

class DefaultUnknownRoutePage extends StatelessWidget {
  final String path;

  const DefaultUnknownRoutePage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Text("Page '$path' wasn't found.")),
    );
  }
}

/// An abstract class that can provide a map of routes
@immutable
abstract class RouteConfig {
  const RouteConfig();

  /// Called when there's no match for a route. By default this returns
  /// [DefaultUnknownRoutePage], a simple page not found page.
  ///
  /// There are two general options for this callback's operation:
  ///
  ///   1. Return a page, which will be displayed.
  ///
  /// or
  ///
  ///   2. Use the routing delegate to, for instance, redirect to another route
  ///      and return null.
  ///
  Page onUnknownRoute(String path, BuildContext context) {
    return MaterialPage<void>(
      child: DefaultUnknownRoutePage(path: path),
    );
  }

  /// Generate a single [RouteResult] for the given [path]. Returns null if the
  /// path isn't valid.
  RouterResult? get(String path);

  /// Generate all [RouteResult] objects required to build the navigation tree
  /// for the given [path]. Returns null if the path isn't valid.
  List<RouterResult>? getAll(String path);
}

@immutable
abstract class DefaultRouterConfig extends RouteConfig {
  final _router = TrieRouter();

  DefaultRouterConfig() {
    _router.addAll(routes);
  }

  @override
  RouterResult? get(String route) => _router.get(route);

  @override
  List<RouterResult>? getAll(String route) => _router.getAll(route);

  Map<String, PageBuilder> get routes;
}

/// A standard simple routing table which takes a map of routes.
@immutable
class RouteMap extends DefaultRouterConfig {
  /// A map of paths and [PageBuilder] delegates that return [Page] objects to
  /// build.
  @override
  final Map<String, PageBuilder> routes;

  final UnknownRouteCallback? _onUnknownRoute;

  RouteMap({
    required this.routes,
    UnknownRouteCallback? onUnknownRoute,
  }) : _onUnknownRoute = onUnknownRoute;

  @override
  Page onUnknownRoute(String path, BuildContext context) {
    if (_onUnknownRoute != null) {
      return _onUnknownRoute!(path, context);
    }

    return super.onUnknownRoute(path, context);
  }
}

class Routemaster {
  // The current router delegate. This can change if the delegate is recreated.
  late RoutemasterDelegate _delegate;

  Routemaster._();

  static void setPathUrlStrategy() {
    if (kIsWeb) {
      SystemNav.setPathUrlStrategy();
    }
  }

  static Routemaster of(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<_RoutemasterWidget>();

    assert(
      element != null,
      "Couldn't get a Routemaster object from the given context.",
    );

    return (element!.widget as _RoutemasterWidget).routemaster;
  }

  /// Pops the current route from the router. Returns `true` if the pop was
  /// successful, or `false` if it wasn't.
  @optionalTypeArgs
  Future<bool> pop<T extends Object?>([T? value]) {
    return _delegate.pop(value);
  }

  /// Replaces the current route with [path].
  ///
  /// If the given [path] starts with a forward slash, it's treated as an
  /// absolute path.
  ///
  /// If it doesn't start with a forward slash, it's treated as a relative path
  /// to the current route.
  ///
  /// For example:
  ///
  ///   * If the current route is '/products' and you call `replace('1')`
  ///     you'll navigate to '/products/1'.
  ///
  ///   * If the current route is '/products' and you call `replace('/home')`
  ///     you'll navigate to '/home'.
  ///
  void replace(String path, {Map<String, String>? queryParameters}) {
    _delegate.replace(path, queryParameters: queryParameters);
  }

  /// Pushes [path] into the navigation tree.
  ///
  /// If the given [path] starts with a forward slash, it's treated as an
  /// absolute path.
  ///
  /// If it doesn't start with a forward slash, it's treated as a relative path
  /// to the current route.
  ///
  /// For example:
  ///
  ///   * If the current route is '/products' and you call `replace('1')`
  ///     you'll navigate to '/products/1'.
  ///
  ///   * If the current route is '/products' and you call `replace('/home')`
  ///     you'll navigate to '/home'.
  ///
  @optionalTypeArgs
  NavigationResult<T> push<T extends Object?>(String path,
      {Map<String, String>? queryParameters}) {
    return _delegate.push<T>(path, queryParameters: queryParameters);
  }
}

class NavigationResult<T extends Object?> {
  Future<T> get result => _completer.future;
  final Completer<T> _completer = Completer<T>();
}

class RoutemasterDelegate extends RouterDelegate<RouteData>
    with ChangeNotifier {
  final TransitionDelegate? transitionDelegate;
  final RouteConfig Function(BuildContext context) routesBuilder;

  _RoutemasterState _state = _RoutemasterState();
  bool _isBuilding = false;
  bool _isDisposed = false;
  late BuildContext _context;
  final List<RoutemasterObserver> observers;

  RoutemasterDelegate({
    required this.routesBuilder,
    this.transitionDelegate,
    this.observers = const [],
  }) {
    _state.routemaster._delegate = this;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Called by the [Router] when the [Router.backButtonDispatcher] reports that
  /// the operating system is requesting that the current route be popped.
  @override
  Future<bool> popRoute() async {
    assert(!_isDisposed);
    return pop();
  }

  @optionalTypeArgs
  Future<bool> pop<T extends Object?>([T? result]) async {
    assert(!_isDisposed);

    final popResult = await _state.stack.maybePop<T>(result);
    if (popResult) {
      _markNeedsUpdate();
    }
    return popResult;
  }

  /// Replaces the current route with [path].
  void replace(String path, {Map<String, String>? queryParameters}) {
    assert(!_isDisposed);

    if (kIsWeb && SystemNav.pathStrategy == PathStrategy.hash) {
      // If we're using the default hash path strategy, we can do a simple
      // replace on the location hash.
      SystemNav.setHash(path, queryParameters);
      return;
    }

    // Otherwise we do a convoluted dance which uses a custom UrlStrategy that
    // supports replacing the URL.
    _setPendingNavigation(
      path,
      queryParameters: queryParameters,
      isReplacement: true,
    );
  }

  /// Pushes [path] into the navigation tree.
  @optionalTypeArgs
  NavigationResult<T> push<T extends Object?>(String path,
      {Map<String, String>? queryParameters}) {
    assert(!_isDisposed);

    final result = NavigationResult<T>();
    _setPendingNavigation(
      path,
      queryParameters: queryParameters,
      isReplacement: false,
      result: result,
    );
    return result;
  }

  void _setPendingNavigation(
    String path, {
    Map<String, String>? queryParameters,
    required bool isReplacement,
    NavigationResult? result,
  }) {
    final absolutePath = PathParser.getAbsolutePath(
      basePath: currentConfiguration!.path,
      path: path,
      queryParameters: queryParameters,
    );

    // Schedule request for next build. This makes sure the routing table is
    // updated before processing the new path.
    _state.pendingNavigation = _RouteRequest(
      path: absolutePath,
      isReplacement: isReplacement,
      result: result,
    );

    _markNeedsUpdate();
  }

  void _markNeedsUpdate() {
    assert(!_isDisposed);

    _updateCurrentConfiguration();

    if (!_isBuilding) {
      notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(!_isDisposed);

    _context = context;

    return _RoutemasterStateTracker(
      delegate: this,
      builder: (context) {
        _isBuilding = true;
        _initRouter(context);
        _processPendingNavigation();
        _isBuilding = false;

        return _RoutemasterWidget(
          routemaster: _state.routemaster,
          child: StackNavigator(
            stack: _state.stack,
            transitionDelegate: transitionDelegate ??
                const DefaultTransitionDelegate<dynamic>(),
          ),
        );
      },
    );
  }

  // Returns a [RouteData] that matches the current route state.
  // This is used to update a browser's current URL.

  @override
  RouteData? get currentConfiguration {
    assert(!_isDisposed);

    return _state.currentConfiguration;
  }

  void _updateCurrentConfiguration() {
    final currentPages = _state.stack._getCurrentPages();

    if (currentPages.isNotEmpty) {
      final pageWrapper = currentPages.last;
      final routeData = pageWrapper.routeData;

      if (_state.currentConfiguration!.path != routeData.path) {
        _state.currentConfiguration = RouteData(
          routeData.path,
          isReplacement: routeData.isReplacement,
          pathTemplate: routeData.pathTemplate,
        );

        for (final observer in observers) {
          observer.didChangeRoute(routeData, pageWrapper._getOrCreatePage());
        }
      }
    }
  }

  // Called when a new URL is set. The RouteInformationParser will parse the
  // URL, and return a new [RouteData], that gets passed this this method.
  //
  // This method then modifies the state based on that information.
  @override
  Future<void> setNewRoutePath(RouteData routeData) {
    assert(!_isDisposed);

    push(routeData.path);
    return SynchronousFuture(null);
  }

  @override
  Future<void> setInitialRoutePath(RouteData configuration) {
    assert(!_isDisposed);

    _state.currentConfiguration = configuration;
    return SynchronousFuture(null);
  }

  void _initRouter(BuildContext context, {bool isRebuild = false}) {
    final routerNeedsBuilding = _state.routeConfig == null;

    if (routerNeedsBuilding) {
      _state.routeConfig = routesBuilder(context);

      _processNavigation(
        routeRequest: _state.pendingNavigation ??
            _RouteRequest(path: currentConfiguration?.path ?? '/'),
        currentRoutes: null,
      );

      _state.pendingNavigation = null;
    }
  }

  void _processPendingNavigation() {
    final pendingNavigation = _state.pendingNavigation;

    if (pendingNavigation != null) {
      _processNavigation(
        routeRequest: pendingNavigation,
        currentRoutes: _state.stack._getCurrentPages().toList(),
      );
      _state.pendingNavigation = null;
    }
  }

  void _processNavigation({
    required _RouteRequest routeRequest,
    required List<PageWrapper>? currentRoutes,
  }) {
    final pages = _createAllPageWrappers(
      routeRequest,
      currentRoutes: currentRoutes,
    );
    assert(pages.isNotEmpty);

    _state.stack._routes = pages;
    _updateCurrentConfiguration();
  }

  /// Called when dependencies of the [routesBuilder] changed.
  ///
  /// This triggers a full rebuild of the routes.
  void _didChangeDependencies(BuildContext context) {
    if (currentConfiguration == null) {
      return;
    }

    // Reset state
    _state.routeConfig = null;

    _isBuilding = true;
    _initRouter(context, isRebuild: true);
    _isBuilding = false;

    // Already building; schedule rebuild for next frame
    WidgetsBinding.instance?.addPostFrameCallback((_) => _markNeedsUpdate());
  }

  List<PageWrapper> _createAllPageWrappers(
    _RouteRequest routeRequest, {
    List<PageWrapper>? currentRoutes,
    List<String>? redirects,
  }) {
    final requestedPath = routeRequest.path;
    final routerResult = _state.routeConfig!.getAll(requestedPath);

    if (routerResult == null || routerResult.isEmpty) {
      return _onUnknownRoute(routeRequest);
    }

    var result = <PageWrapper>[];
    var i = 0;

    for (final routerData in routerResult.reversed) {
      final isLastRoute = i++ == 0;

      final routeData = RouteData.fromRouterResult(
        routerData,
        // Only the last route gets query parameters
        isLastRoute ? requestedPath : routerData.pathSegment,
        isReplacement: routeRequest.isReplacement,
      );

      final current = _getOrCreatePageWrapper(
        routeRequest: routeRequest,
        routeData: routeData,
        currentRoutes: currentRoutes,
        routerResult: routerData,
      );

      if (current is _PageWrapperResult) {
        final page = current.pageWrapper;

        if (isLastRoute) {
          page.result = routeRequest.result;
        }

        if (result.isNotEmpty && page.maybeSetChildPages(result)) {
          result = [page];
        } else {
          result.insert(0, page);
        }
      }

      if (!isLastRoute) {
        // We only follow redirects and not found for the last route
        continue;
      }

      if (current is _NotFoundResult) {
        return _onUnknownRoute(routeRequest);
      }

      if (current is _RedirectResult) {
        if (kDebugMode) {
          redirects = _debugCheckRedirectLoop(redirects, requestedPath);
        }

        return _createAllPageWrappers(
          _RouteRequest(
            path: current.redirectPath,
            isReplacement: routeRequest.isReplacement,
          ),
          currentRoutes: currentRoutes,
          redirects: redirects,
        );
      }
    }

    assert(result.isNotEmpty, "_createAllStates can't return empty list");

    return result;
  }

  /// If there's a current route matching the path in the tree, return it.
  /// Otherwise create a new one. This could possibly be made more efficient
  /// By using a map rather than iterating over all currentRoutes.
  _PageResult _getOrCreatePageWrapper({
    required _RouteRequest routeRequest,
    required RouteData routeData,
    required List<PageWrapper>? currentRoutes,
    required RouterResult routerResult,
  }) {
    if (currentRoutes != null) {
      // See if we have a current route matching the routeData
      final currentState = currentRoutes.firstWhereOrNull(
        ((element) => element.routeData == routeData),
      );

      if (currentState != null) {
        return _PageWrapperResult(currentState);
      }
    }

    // No current route, create a new one
    return _createPageWrapper(
      routeRequest: routeRequest,
      page: routerResult.builder(routeData),
      routeData: routeData,
    );
  }

  /// Called by tab pages to lazily generate their initial routes
  PageWrapper _getPageForTab(_RouteRequest routeRequest) {
    final requestedPath = routeRequest.path;
    final routerResult = _state.routeConfig!.get(requestedPath);
    if (routerResult != null) {
      final routeData = RouteData.fromRouterResult(routerResult, requestedPath);

      final wrapper = _createPageWrapper(
        routeRequest: routeRequest,
        page: routerResult.builder(routeData),
        routeData: routeData,
      );

      if (wrapper is _PageWrapperResult) {
        return wrapper.pageWrapper;
      }

      if (wrapper is _RedirectResult) {
        return _getPageForTab(
          _RouteRequest(
            path: wrapper.redirectPath,
            isReplacement: routeRequest.isReplacement,
          ),
        );
      }
    }

    return _TabNotFoundPage(routeRequest.path);
  }

  _PageResult _createPageWrapper({
    required _RouteRequest routeRequest,
    required Page page,
    required RouteData routeData,
  }) {
    while (page is ProxyPage || page is ProxyBuilderPage) {
      if (page is GuardedPage && !page.validate(routeData, _context)) {
        if (page.onValidationFailed == null) {
          return _NotFoundResult();
        }

        final result = page.onValidationFailed!(routeData, _context);
        return _createPageWrapper(
          routeRequest: routeRequest,
          page: result,
          routeData: routeData,
        );
      }

      if (page is ProxyPage) {
        page = page.child;
      } else if (page is ProxyBuilderPage) {
        page = page.builder();
      }
    }

    if (page is Redirect) {
      return _RedirectResult(page.redirectPath);
    }

    if (page is StatefulPage) {
      return _PageWrapperResult(
        page.createState(_state.routemaster, routeData),
      );
    }

    assert(page is! Redirect, 'Redirect has not been followed');
    assert(page is! ProxyPage, 'ProxyPage has not been unwrapped');
    assert(
        page is! ProxyBuilderPage, 'ProxyBuilderPage has not been unwrapped');

    // Page is just a standard Flutter page, create a wrapper for it
    return _PageWrapperResult(StatelessPage(routeData: routeData, page: page));
  }

  List<PageWrapper> _onUnknownRoute(_RouteRequest routeRequest) {
    final requestedPath = routeRequest.path;
    final result = _state.routeConfig!.onUnknownRoute(
      requestedPath,
      _context,
    );

    if (result is Redirect) {
      return _createAllPageWrappers(
        _RouteRequest(
          path: result.redirectPath,
          isReplacement: routeRequest.isReplacement,
        ),
      );
    }

    // Return 404 page
    final routeData = RouteData(
      requestedPath,
      isReplacement: routeRequest.isReplacement,
    );
    return [StatelessPage(routeData: routeData, page: result)];
  }

  List<String> _debugCheckRedirectLoop(
      List<String>? redirects, String requestedPath) {
    if (redirects == null) {
      return [requestedPath];
    }

    if (redirects.contains(requestedPath)) {
      redirects.add(requestedPath);
      throw RedirectLoopError(redirects);
    }
    redirects.add(requestedPath);

    return redirects;
  }
}

@immutable
abstract class _PageResult {}

class _PageWrapperResult extends _PageResult {
  final PageWrapper pageWrapper;

  _PageWrapperResult(this.pageWrapper);
}

class _NotFoundResult extends _PageResult {}

class _RedirectResult extends _PageResult {
  final String redirectPath;

  _RedirectResult(this.redirectPath);
}

/// Used internally so descendent widgets can use `Routemaster.of(context)`.
class _RoutemasterWidget extends InheritedWidget {
  final Routemaster routemaster;

  const _RoutemasterWidget({
    required Widget child,
    required this.routemaster,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant _RoutemasterWidget oldWidget) {
    return false;
  }
}

/// Maintains the router's state so [RoutemasterDelegate] can be replaced but
/// still maintain its state.
class _RoutemasterState {
  final routemaster = Routemaster._();
  final stack = PageStack();
  RouteConfig? routeConfig;
  RouteData? currentConfiguration;
  _RouteRequest? pendingNavigation;
}

class _RoutemasterStateTracker extends StatefulWidget {
  final RoutemasterDelegate delegate;
  final Widget Function(BuildContext context) builder;

  _RoutemasterStateTracker({
    required this.delegate,
    required this.builder,
  });

  @override
  _RoutemasterStateTrackerState createState() {
    return _RoutemasterStateTrackerState();
  }
}

class _RoutemasterStateTrackerState extends State<_RoutemasterStateTracker> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.delegate._didChangeDependencies(this.context);
  }

  @override
  void didUpdateWidget(_RoutemasterStateTracker oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldDelegate = oldWidget.delegate;
    final newDelegate = widget.delegate;

    // Check if delegate has been recreated
    if (oldDelegate != newDelegate) {
      // Update new delegate's state from old delegate's state
      newDelegate._state = oldDelegate._state;
      newDelegate._state.routemaster._delegate = newDelegate;

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        // Dispose after this frame to allow child widgets to unsubscribe
        oldDelegate.dispose();
      });
    }
  }
}

class RedirectLoopError extends Error {
  final List<String> redirects;

  RedirectLoopError(this.redirects);

  @override
  String toString() {
    return 'Routemaster is stuck in an endless redirect loop:\n\n' +
        redirects
            .take(redirects.length - 1)
            .mapIndexed((i, path1) =>
                "  * '$path1' redirected to '${redirects[i + 1]}'")
            .join('\n') +
        '\n\nThis is an error in your routing map.';
  }
}

class _RouteRequest {
  final String path;
  final bool isReplacement;
  final NavigationResult? result;

  _RouteRequest({
    required this.path,
    this.isReplacement = false,
    this.result,
  });
}

/// Provides a [Navigator] that shows pages from a [PageStack].
///
/// This widget listens to that stack, and updates the navigator when the pages
/// change.
class StackNavigator extends StatefulWidget {
  final PageStack stack;
  final TransitionDelegate transitionDelegate;
  final List<NavigatorObserver> observers;

  const StackNavigator({
    Key? key,
    required this.stack,
    this.transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
    this.observers = const [],
  }) : super(key: key);

  @override
  StackNavigatorState createState() => StackNavigatorState();

  static StackNavigatorState of(BuildContext context) {
    final state = context.findAncestorStateOfType<StackNavigatorState>();
    assert(state != null, "Couldn't find a StackNavigatorState");
    return state!;
  }
}

class StackNavigatorState extends State<StackNavigator> {
  late HeroControllerScope _widget;
  late Routemaster _routemaster;
  final HeroController _heroController =
      MaterialApp.createMaterialHeroController();

  @override
  void initState() {
    super.initState();

    _didUpdateStack(null, widget.stack);
    _updateNavigator();
  }

  @override
  void didUpdateWidget(StackNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.stack != widget.stack) {
      _didUpdateStack(oldWidget.stack, widget.stack);
      _updateNavigator();
    }
  }

  void _didUpdateStack(PageStack? oldStack, PageStack newStack) {
    if (oldStack != null) {
      oldStack.removeListener(_onStackChanged);
    }

    newStack.addListener(_onStackChanged);
    newStack._attachedNavigatorKey = GlobalKey<NavigatorState>(
      debugLabel: 'StackNavigator',
    );
  }

  @override
  void dispose() {
    widget.stack.removeListener(_onStackChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routemaster = Routemaster.of(this.context);
  }

  void _onStackChanged() {
    setState(() {
      _updateNavigator();
    });
  }

  void _updateDelegate() {
    _routemaster._delegate._markNeedsUpdate();
  }

  void _updateNavigator() {
    _widget = HeroControllerScope(
      controller: _heroController,
      child: Navigator(
        key: widget.stack._attachedNavigatorKey,
        onPopPage: (route, dynamic result) {
          final didPop = widget.stack.onPopPage(route, result);
          if (didPop) {
            _updateDelegate();
          }
          return didPop;
        },
        transitionDelegate: widget.transitionDelegate,
        pages: widget.stack.createPages(),
        observers: [
          _RelayingNavigatorObserver(
            () => widget.observers + _routemaster._delegate.observers,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _widget;
  }

  RouteData? routeDataFor(Page page) {
    return widget.stack._routeMap[page];
  }
}
