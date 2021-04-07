library routemaster;

export 'src/parser.dart';
export 'src/route_info.dart';
export 'src/pages/guard.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';
import 'src/pages/guard.dart';
import 'src/route_dart.dart';
import 'src/system_nav.dart';
import 'src/trie_router/trie_router.dart';
import 'src/route_info.dart';

part 'src/pages/page_stack.dart';
part 'src/pages/tab_pages.dart';
part 'src/pages/standard.dart';

typedef RoutemasterBuilder = Widget Function(
  BuildContext context,
  List<Page> pages,
  PopPageCallback onPopPage,
  GlobalKey<NavigatorState> navigatorKey,
);

typedef PageBuilder = Page Function(RouteInfo info);

typedef UnknownRouteCallback = Page Function(
  String route,
  BuildContext context,
);

class DefaultUnknownRoutePage extends StatelessWidget {
  final String route;

  DefaultUnknownRoutePage({required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Page '$route' wasn't found."),
    );
  }
}

/// An abstract class that can provide a map of routes
abstract class RouteConfig {
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
  Page onUnknownRoute(String route, BuildContext context) {
    return MaterialPage<void>(
      child: DefaultUnknownRoutePage(route: route),
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
  Page onUnknownRoute(String route, BuildContext context) {
    if (_onUnknownRoute != null) {
      return _onUnknownRoute!(route, context);
    }

    return super.onUnknownRoute(route, context);
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
    return context
        .dependOnInheritedWidgetOfExactType<_RoutemasterWidget>()!
        .routemaster;
  }

  /// Pops the current route from the router. Returns `true` if the pop was
  /// successful, or `false` if it wasn't.
  Future<bool> pop() {
    return _delegate.popRoute();
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
  void push(String path, {Map<String, String>? queryParameters}) {
    _delegate.push(path, queryParameters: queryParameters);
  }

  /// The current route path, for example '/products/1'.
  String get currentPath => _delegate.currentConfiguration!.path;
}

class RoutemasterDelegate extends RouterDelegate<RouteData>
    with ChangeNotifier {
  /// Used to override how the [Navigator] builds.
  final RoutemasterBuilder? builder;
  final TransitionDelegate? transitionDelegate;
  final RouteConfig Function(BuildContext context) routesBuilder;

  _RoutemasterState _state = _RoutemasterState();
  bool _isBuilding = false;
  bool _isDisposed = false;
  late BuildContext _context;

  RoutemasterDelegate({
    required this.routesBuilder,
    this.builder,
    this.transitionDelegate,
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
  Future<bool> popRoute() {
    assert(!_isDisposed);

    if (_state.stack == null) {
      return SynchronousFuture(false);
    }

    return _state.stack!.maybePop();
  }

  /// Passed to top-level [Navigator] widget, called when the navigator requests
  /// that it wants to pop a page.
  bool onPopPage(Route<dynamic> route, dynamic result) {
    assert(!_isDisposed);
    return _state.stack!.onPopPage(route, result);
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
    final absolutePath = _getAbsolutePath(path, queryParameters);
    _state.pendingNavigation = _RouteRequest(
      path: absolutePath,
      isReplacement: true,
    );
    _markNeedsUpdate();
  }

  /// Pushes [path] into the navigation tree.
  void push(String path, {Map<String, String>? queryParameters}) {
    assert(!_isDisposed);

    final absolutePath = _getAbsolutePath(path, queryParameters);

    // Schedule request for next build. This makes sure the routing table is
    // updated before processing the new path.
    _state.pendingNavigation = _RouteRequest(
      path: absolutePath,
      isReplacement: false,
    );
    _markNeedsUpdate();
  }

  String _getAbsolutePath(String path, Map<String, String>? queryParameters) {
    final absolutePath =
        isAbsolute(path) ? path : join(currentConfiguration!.path, path);

    if (queryParameters == null) {
      return absolutePath;
    }

    return Uri(path: absolutePath, queryParameters: queryParameters).toString();
  }

  /// Generates all pages and sub-pages.
  List<Page> createPages(BuildContext context) {
    assert(!_isDisposed);

    assert(_state.stack != null,
        'Stack must have been created when createPages() is called');
    final pages = _state.stack!.createPages();
    assert(pages.isNotEmpty, 'Returned pages list must not be empty');
    _updateCurrentConfiguration();

    assert(
      pages.none((page) => page is Redirect),
      'Returned pages list must not have redirect',
    );

    return pages;
  }

  void _markNeedsUpdate() {
    assert(!_isDisposed);

    _updateCurrentConfiguration();

    if (!_isBuilding) {
      notifyListeners();
    }
  }

  void _processPendingNavigation() {
    if (_state.pendingNavigation != null) {
      _processNavigation(_state.pendingNavigation!);
      _state.pendingNavigation = null;
    }
  }

  void _processNavigation(_RouteRequest path) {
    final pages = _createAllPageWrappers(
      path,
      currentRoutes: _state.stack?._getCurrentPages().toList(),
    );
    _state.stack = PageStack(routes: pages);
  }

  @override
  Widget build(BuildContext context) {
    assert(!_isDisposed);

    _context = context;

    return _RoutemasterStateTracker(
      delegate: this,
      builder: (context) {
        _isBuilding = true;
        _init(context);
        _processPendingNavigation();
        final pages = createPages(context);
        _isBuilding = false;

        return _RoutemasterWidget(
          routemaster: _state.routemaster,
          child: builder != null
              ? builder!(context, pages, onPopPage, _state.stack!.navigatorKey)
              : Navigator(
                  pages: pages,
                  onPopPage: onPopPage,
                  key: _state.stack!.navigatorKey,
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
    if (_state.stack == null) {
      return;
    }

    final routeInfo = _state.stack!._getCurrentPages().last.routeInfo;
    print("Updated path: '${routeInfo.path}'");
    _state.currentConfiguration = RouteData(
      routeInfo.path,
      isReplacement: routeInfo.isReplacement,
    );
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

    _state.currentConfiguration = RouteData(configuration.path);
    return SynchronousFuture(null);
  }

  void _init(BuildContext context, {bool isRebuild = false}) {
    if (_state.routeConfig == null) {
      _state.routeConfig = routesBuilder(context);

      final routeRequest = _state.pendingNavigation ??
          _RouteRequest(
            path: currentConfiguration?.path ?? '/',
          );

      final pageStates = _createAllPageWrappers(
        routeRequest,
        currentRoutes: null,
      );
      assert(pageStates.isNotEmpty);
      _state.stack = PageStack(routes: pageStates);
    }
  }

  /// Called when dependencies of the [routesBuilder] changed.
  void _didChangeDependencies(BuildContext context) {
    if (currentConfiguration == null) {
      return;
    }

    // Reset state
    _state.routeConfig = null;
    _state.stack = null;

    _isBuilding = true;
    _init(context, isRebuild: true);
    _isBuilding = false;

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

      final routeInfo = RouteInfo.fromRouterResult(
        routerData,
        // Only the last route gets query parameters
        isLastRoute ? requestedPath : routerData.pathSegment,
        isReplacement: routeRequest.isReplacement,
      );

      final current = _getOrCreatePageWrapper(
        routeRequest: routeRequest,
        routeInfo: routeInfo,
        currentRoutes: currentRoutes,
        routerResult: routerData,
      );

      if (current is _PageWrapperResult) {
        final page = current.pageWrapper;
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
    required RouteInfo routeInfo,
    required List<PageWrapper>? currentRoutes,
    required RouterResult routerResult,
  }) {
    if (currentRoutes != null) {
      // See if we have a current route matching the routeInfo
      final currentState = currentRoutes.firstWhereOrNull(
        ((element) => element.routeInfo == routeInfo),
      );

      if (currentState != null) {
        return _PageWrapperResult(currentState);
      }
    }

    // No current route, create a new one
    return _createPageWrapper(
      routeRequest: routeRequest,
      page: routerResult.builder(routeInfo),
      routeInfo: routeInfo,
    );
  }

  /// Called by tab pages to lazily generate their initial routes
  PageWrapper _getPageForTab(_RouteRequest routeRequest) {
    final requestedPath = routeRequest.path;
    final routerResult = _state.routeConfig!.get(requestedPath);
    if (routerResult != null) {
      final routeInfo = RouteInfo.fromRouterResult(routerResult, requestedPath);

      final wrapper = _createPageWrapper(
        routeRequest: routeRequest,
        page: routerResult.builder(routeInfo),
        routeInfo: routeInfo,
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
    required RouteInfo routeInfo,
  }) {
    while (page is ProxyPage) {
      if (page is GuardedPage) {
        if (!page.validate(routeInfo, _context)) {
          print("Validation failed for '${routeInfo.path}'");

          if (page.onValidationFailed == null) {
            return _NotFoundResult();
          }

          final result = page.onValidationFailed!(routeInfo, _context);
          return _createPageWrapper(
            routeRequest: routeRequest,
            page: result,
            routeInfo: routeInfo,
          );
        }
      }

      page = page.child;
    }

    if (page is Redirect) {
      return _RedirectResult(page.redirectPath);
    }

    if (page is StatefulPage) {
      return _PageWrapperResult(
        page.createState(_state.routemaster, routeInfo),
      );
    }

    assert(page is! Redirect, 'Redirect has not been followed');
    assert(page is! ProxyPage, 'ProxyPage has not been unwrapped');

    // Page is just a standard Flutter page, create a wrapper for it
    return _PageWrapperResult(StatelessPage(routeInfo: routeInfo, page: page));
  }

  List<PageWrapper> _onUnknownRoute(_RouteRequest routeRequest) {
    final requestedPath = routeRequest.path;
    print("Router couldn't find a match for path '$requestedPath'");

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
    final routeInfo = RouteInfo(
      requestedPath,
      isReplacement: routeRequest.isReplacement,
    );
    return [StatelessPage(routeInfo: routeInfo, page: result)];
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
    return routemaster._delegate != oldWidget.routemaster._delegate;
  }
}

/// Maintains the router's state so [RoutemasterDelegate] can be replaced but
/// still maintain its state.
class _RoutemasterState {
  final routemaster = Routemaster._();
  RouteConfig? routeConfig;
  RouteData? currentConfiguration;
  _RouteRequest? pendingNavigation;

  PageStack? _stack;
  PageStack? get stack => _stack;
  set stack(PageStack? newStack) {
    if (newStack == _stack) {
      return;
    }

    if (_stack != null) {
      _stack!.removeListener(_onStackChanged);
    }

    if (newStack != null) {
      newStack.addListener(_onStackChanged);
    }

    _stack = newStack;
  }

  void _onStackChanged() {
    routemaster._delegate._markNeedsUpdate();
  }
}

class _RoutemasterStateTracker extends StatefulWidget {
  final RoutemasterDelegate delegate;
  final Widget Function(BuildContext context) builder;

  _RoutemasterStateTracker({
    required this.delegate,
    required this.builder,
  });

  @override
  _RoutemasterStateTrackerState createState() =>
      _RoutemasterStateTrackerState();
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

  _RouteRequest({
    required this.path,
    this.isReplacement = false,
  });
}
