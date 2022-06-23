library routemaster;

export 'src/parser.dart';
export 'src/pages/guard.dart';
export 'src/pages/transition_page.dart';

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'src/not_found_page.dart';
import 'src/pages/guard.dart';
import 'src/path_parser.dart';
import 'src/system_nav.dart';
import 'src/trie_router/trie_router.dart';

part 'src/pages/page_stack.dart';
part 'src/pages/tab_pages.dart';
part 'src/pages/pages.dart';
part 'src/pages/stack_page.dart';
part 'src/observers.dart';
part 'src/route_data.dart';
part 'src/route_history.dart';

/// A function that builds a [Page] from given [RouteData].
typedef PageBuilder = RouteSettings Function(RouteData route);

/// A function that returns a [Page] when the given [path] couldn't be found.
typedef UnknownRouteCallback = RouteSettings Function(String path);

/// A standard simple routing table which takes a map of routes.
///
///   * [routes] - A map of paths and [PageBuilder] delegates that return
///     [Page] objects to build.
///
@immutable
class RouteMap {
  final UnknownRouteCallback? _onUnknownRoute;

  final _router = TrieRouter();

  /// Creates a standard simple routing table which takes a map of routes.
  ///
  ///   * [routes] - a map of paths and [PageBuilder] delegates that return
  ///     [Page] objects to build.
  ///
  ///   * [onUnknownRoute] - called when there's no match for a route.
  ///     There are two general options for this callback's operation:
  ///
  ///       1. Return a page, which will be displayed.
  ///
  ///     or
  ///
  ///       2. Use the routing delegate to, for instance, redirect to another
  ///          route and return null.
  ///
  RouteMap({
    required Map<String, PageBuilder> routes,
    UnknownRouteCallback? onUnknownRoute,
  }) : _onUnknownRoute = onUnknownRoute {
    _router.addAll(routes);
  }

  /// Generate a single [RouteResult] for the given [path]. Returns null if the
  /// path isn't valid.
  RouterResult? get(String path) {
    return _router.get(path);
  }

  /// Generate all [RouteResult] objects required to build the navigation tree
  /// for the given [path]. Returns null if the path isn't valid.
  List<RouterResult>? getAll(String path) {
    return _router.getAll(path);
  }

  /// Called when there's no match for a route. By default this returns
  /// [DefaultNotFoundPage], a simple page not found page.
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
  RouteSettings onUnknownRoute(String path) {
    if (_onUnknownRoute != null) {
      return _onUnknownRoute!(path);
    }

    return MaterialPage<void>(
      child: DefaultNotFoundPage(path: path),
    );
  }
}

/// Provides access to router functionality.
///
/// For example: `Routemaster.of(context).push('/path')`
class Routemaster {
  // The current router delegate. This can change if the delegate is recreated.
  late final _RoutemasterState _state;
  final BuildContext _context;

  Routemaster._({
    required _RoutemasterState state,
    required BuildContext context,
  })  : _context = context,
        _state = state;

  /// Uses [PathUrlStrategy] on the web, which removes hashes from URLs. This
  /// must be called at app startup, before `runApp` is called.
  ///
  /// Calling this method does nothing when not running on the web.
  ///
  /// Note: to load pages directly by URL, your server needs to be set up
  /// correctly.
  ///
  /// For example, if your app's home is at http://dash.dev/myapp and you have
  /// an app page with the path '/settings', then trying to load
  /// http://dash.dev/myapp/settings will probably show a server 404 error
  /// without additional server configuration.
  ///
  /// You need to ensure server requests to dash.dev/myapp/*<anything>* return
  /// the Flutter app.
  static void setPathUrlStrategy() {
    if (kIsWeb) {
      SystemNav.setPathUrlStrategy(); // coverage:ignore-line
    }
  }

  /// Retrieves the nearest ancestor [Routemaster] object.
  static Routemaster of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<_RoutemasterWidget>();

    assert(
      widget != null,
      "Couldn't get a Routemaster object from the given context.",
    );

    return Routemaster._(
      state: widget!.state,
      context: context,
    );
  }

  /// The current global route.
  RouteData get currentRoute => _state.delegate.currentConfiguration!;

  /// Pops the current route from the router. Returns `true` if the pop was
  /// successful, or `false` if it wasn't.
  @optionalTypeArgs
  Future<bool> pop<T extends Object?>([T? value]) {
    return _state.delegate.pop(value);
  }

  /// Allows navigating through the chronological history of routes.
  ///
  /// This is the routes that the user has recently seen.
  RouteHistory get history => _state.history;

  /// Calls [pop] repeatedly whilst the [predicate] function returns true.
  ///
  /// If [predicate] immediately returns false, pop won't be called.
  Future<void> popUntil(bool Function(RouteData routeData) predicate) {
    return _state.delegate.popUntil(predicate);
  }

  /// Replaces the current route with [path]. On the web, this prevents the user
  /// returning to the previous route via the back button.
  ///
  ///   * [path] - an absolute or relative path. See [push] for the difference
  ///     between the two.
  ///
  ///   * [queryParameters] - an optional map of string parameters to be passed
  ///     to the new route.
  ///
  void replace(String path, {Map<String, String>? queryParameters}) {
    final routeData = RouteData.maybeOf(_context);
    if (routeData != null) {
      // Use context route data for relative path
      _state.delegate._replaceUri(
        PathParser.getAbsolutePath(
          basePath: routeData.fullPath,
          path: path,
          queryParameters: queryParameters,
        ),
        queryParameters: queryParameters,
      );

      return;
    }

    _state.delegate.replace(path, queryParameters: queryParameters);
  }

  /// Navigates to [path].
  ///
  /// If this path starts with a forward slash, it's treated as an absolute
  /// path. Otherwise it's handled as a path relative to the current route.
  ///
  /// For example, if the current route is '/products':
  ///
  ///   * Calling `push('1')` navigates to '/products/1'.
  ///
  ///   * Calling `push('/home')` navigates to '/home'.
  ///
  /// A [queryParameters] map can be added to pass string parameters to the new
  /// route:
  ///
  ///   `push('/search', queryParameters: {'query': 'hello'})`
  ///
  /// These can then be access from [RouteData], using
  /// `RouteData.of(context).queryParameters`, or from within a route map:
  ///
  ///   `'/product': (route) => MaterialPage(child: SearchPage(route.queryParameters['id']))`
  ///
  @optionalTypeArgs
  NavigationResult<T> push<T extends Object?>(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final routeData = RouteData.maybeOf(_context);
    if (routeData != null) {
      // Use context route data for relative path
      return _state.delegate._pushUri<T>(
        PathParser.getAbsolutePath(
          basePath: routeData.fullPath,
          path: path,
          queryParameters: queryParameters,
        ),
        queryParameters: queryParameters,
      );
    }

    return _state.delegate.push<T>(path, queryParameters: queryParameters);
  }
}

/// Provides access to the [Route] created after a route has been pushed.
///
/// Also provides access to any value returned when popping the route.
@immutable
class NavigationResult<T extends Object?> {
  NavigationResult._();

  /// Returns the top-most route that was created as a result of the navigation.
  Future<Route> get route => _routeCompleter.future;
  final Completer<Route> _routeCompleter = Completer<Route>();

  /// Used to get the return value from a route.
  ///
  /// Return values are passed back when popping a route, for example:
  ///
  ///   `Navigator.of(context).pop('Return value')`
  ///
  Future<T?> get result async {
    final route = await _routeCompleter.future;
    final result = await route.popped as T?;
    return result;
  }
}

/// A delegate that is used by the [Router] widget to manage navigation.
class RoutemasterDelegate extends RouterDelegate<RouteData>
    with ChangeNotifier {
  /// Specifies how the top-level [Navigator] transitions between routes.
  ///
  /// If this isn't provided, a [DefaultTransitionDelegate] is used.
  ///
  /// This is only supplied to the top-level navigator, if you're using
  /// nested [PageStackNavigator] widgets you'll need to pass your custom
  /// [TransitionDelegate] to them individually.
  final TransitionDelegate? transitionDelegate;

  /// A function that returns a map of routes, to create pages from paths.
  final RouteMap Function(BuildContext context) routesBuilder;

  /// A list of observers for the router, and nested [Navigator] widgets.
  ///
  /// Use [RoutemasterObserver] for additional `didChangeRoute` functionality.
  final List<NavigatorObserver> observers;

  /// An optional key that's passed to the top-level [Navigator] widget.
  ///
  /// Using a `GlobalKey<NavigatorState>` will provide access to [Navigator]
  /// functionality.
  final Key? navigatorKey;

  /// A function that returns the top-level navigator widgets. Normally this
  /// function would return a [PageStackNavigator].
  final Widget Function(
    BuildContext context,
    PageStack stack,
  )? navigatorBuilder;

  /// Allows navigating through the chronological history of routes.
  ///
  /// This is the routes that the user has recently seen.
  RouteHistory get history => _state.history;

  _RoutemasterState _state = _RoutemasterState();
  bool _isBuilding = false;
  bool _isDisposed = false;
  late BuildContext _context;

  /// Initializes the delegate.
  ///
  /// This uses a default [PageStackNavigator], to supply your own
  /// use [RoutemasterDelegate.builder].
  RoutemasterDelegate({
    required this.routesBuilder,
    this.transitionDelegate,
    this.observers = const [],
    this.navigatorKey,
  }) : navigatorBuilder = null {
    _state.delegate = this;
  }

  /// Initializes the delegate with a custom [PageStackNavigator] builder via
  /// [navigatorBuilder]. For instance, if you wanted to add a observer to just
  /// the top-level navigator.
  RoutemasterDelegate.builder({
    required this.routesBuilder,
    required this.navigatorBuilder,
    this.observers = const [],
  })  : transitionDelegate = null,
        navigatorKey = null {
    _state.delegate = this;
  }

  /// Disposes the delegate. The delegate must not be used once this method has
  /// been called.
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Called by the [Router] when the [Router.backButtonDispatcher] reports that
  /// the operating system is requesting that the current route be popped, for
  /// instance on Android when the user presses the device's back button.
  @override
  Future<bool> popRoute() async {
    assert(!_isDisposed);

    return history.back();
  }

  /// Attempts to pops the top-level route. Returns `true` if a route was
  /// successfully popped, otherwise `false`.
  ///
  /// An optional value can be passed to the previous route via the [result]
  /// parameter.
  @optionalTypeArgs
  Future<bool> pop<T extends Object?>([T? result]) async {
    assert(!_isDisposed);
    final popResult = await _state.stack.maybePop<T>(result);

    if (popResult) {
      _updateCurrentConfiguration(updateHistory: false);
    }

    return popResult;
  }

  /// Calls [pop] repeatedly whilst the [predicate] function returns true.
  ///
  /// If [predicate] immediately returns false, pop won't be called.
  Future<void> popUntil(bool Function(RouteData routeData) predicate) async {
    var hasPopped = false;

    Future<bool> doPop() async {
      final popResult = await _state.stack.maybePop();
      if (popResult) {
        hasPopped = true;
      }
      return popResult;
    }

    do {
      final currentPages = _state.stack._getCurrentPages();
      if (currentPages.isEmpty || predicate(currentPages.last.routeData)) {
        if (hasPopped) {
          _updateCurrentConfiguration(updateHistory: false);
        }

        return;
      }
    } while (await doPop());

    if (hasPopped) {
      _updateCurrentConfiguration(updateHistory: false);
    }
  }

  /// Navigates to [path].
  ///
  /// If this path starts with a forward slash, it's treated as an absolute
  /// path. Otherwise it's handled as a path relative to the current route.
  ///
  /// For example, if the current route is '/products':
  ///
  ///   * Calling `push('1')` navigates to '/products/1'.
  ///
  ///   * Calling `push('/home')` navigates to '/home'.
  ///
  /// A [queryParameters] map can be added to pass string parameters to the new
  /// route:
  ///
  ///   `push('/search', queryParameters: {'query': 'hello'})`
  ///
  /// These can then be access from [RouteData], using
  /// `RouteData.of(context).queryParameters`, or from within a route map:
  ///
  ///   `'/product': (route) => MaterialPage(child: SearchPage(route.queryParameters['id']))`
  ///
  @optionalTypeArgs
  NavigationResult<T> push<T extends Object?>(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _pushUri(
      PathParser.getAbsolutePath(
        basePath: currentConfiguration!.fullPath,
        path: path,
        queryParameters: queryParameters,
      ),
    );
  }

  NavigationResult<T> _pushUri<T extends Object?>(
    Uri uri, {
    Map<String, String>? queryParameters,
  }) {
    assert(!_isDisposed);

    final result = NavigationResult<T>._();

    _navigate(
      uri: uri,
      queryParameters: queryParameters,
      isReplacement: false,
      navigationResult: result,
      requestSource: RequestSource.internal,
    );

    return result;
  }

  /// Replaces the current route with [path]. On the web, this prevents the user
  /// returning to the previous route via the back button.
  ///
  ///   * [path] - an absolute or relative path. See [push] for the difference
  ///     between the two.
  ///
  ///   * [queryParameters] - an optional map of string parameters to be passed
  ///     to the new route.
  ///
  void replace(String path, {Map<String, String>? queryParameters}) {
    assert(!_isDisposed);

    _replaceUri(
      PathParser.getAbsolutePath(
        basePath: currentConfiguration!.fullPath,
        path: path,
        queryParameters: queryParameters,
      ),
    );
  }

  void _replaceUri(Uri uri, {Map<String, String>? queryParameters}) {
    assert(!_isDisposed);

    _navigate(
      uri: uri,
      queryParameters: queryParameters,
      isReplacement: true,
      requestSource: RequestSource.internal,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(!_isDisposed);

    _context = context;

    return _RoutemasterStateTracker(
      delegate: this,
      builder: (context) {
        return _RoutemasterWidget(
          state: _state,
          routeData: currentConfiguration!,
          child: navigatorBuilder != null
              ? Builder(builder: (context) {
                  return navigatorBuilder!(context, _state.stack);
                })
              : PageStackNavigator(
                  navigatorKey: navigatorKey,
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

  /// Ensures that we don't call Router.neglect and Router.navigate in the same
  /// frame, which throws an error.
  _ReportType _reported = _ReportType.none;

  void _setHasReported(_ReportType reportType) {
    _reported = reportType;
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      _reported = _ReportType.none;
    });
  }

  /// Reports the current path to the Flutter routing system, and any observers.
  void _updateCurrentConfiguration({
    bool isBrowserHistoryNavigation = false,
    bool isReplacement = false,
    RequestSource requestSource = RequestSource.internal,
    bool updateHistory = true,
  }) {
    final currentPages = _state.stack._getCurrentPages();

    if (currentPages.isNotEmpty) {
      final pageEntry = currentPages.last;
      final routeData = pageEntry.routeData;
      final currentRouteData = _state.currentConfiguration!;

      if (!isBrowserHistoryNavigation && updateHistory) {
        _state.history._didNavigate(
          route: routeData,
          isReplacement: isReplacement,
        );
      }

      _state.currentConfiguration = routeData._copyWith(
        historyIndex: _state.history._index,
      );

      if (currentRouteData.fullPath != routeData.fullPath) {
        for (final observer in observers.whereType<RoutemasterObserver>()) {
          observer.didChangeRoute(routeData, pageEntry._getOrCreatePage());
        }
      }

      if (isBrowserHistoryNavigation) {
        // Navigated via browser back/forward button, so we don't need to
        // update the router.
        return;
      }

      if (_isBuilding) {
        // Schedule update
        _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
          _updateCurrentConfiguration(
            requestSource: requestSource,
            isReplacement: isReplacement,
            isBrowserHistoryNavigation: isBrowserHistoryNavigation,
          );
        });
      } else {
        if (isReplacement && _reported != _ReportType.navigate) {
          Router.neglect(_context, notifyListeners);
          _setHasReported(_ReportType.neglect);
        } else {
          // If the public paths match but the private paths don't, we need to
          // ensure a new history item is created
          final needsForceNavigate =
              routeData.publicPath == currentRouteData.publicPath &&
                  routeData.fullPath != currentRouteData.fullPath &&
                  requestSource != RequestSource.system;

          if (needsForceNavigate && _reported != _ReportType.neglect) {
            _setHasReported(_ReportType.navigate);
            Router.navigate(_context, notifyListeners);
          } else {
            notifyListeners();
          }
        }
      }
    }
  }

  // Called when a new URL is set. The RouteInformationParser will parse the
  // URL, and return a new [RouteData], that gets passed this this method.
  //
  // This method then modifies the state based on that information.
  @override
  Future<void> setNewRoutePath(RouteData configuration) {
    assert(!_isDisposed);

    final historyIndex = configuration._historyIndex;

    if (kIsWeb && historyIndex != null) {
      // Navigation came from web browser back or forward buttons
      history._goToIndex(historyIndex); // coverage:ignore-line
    } else {
      _navigate(
        uri: configuration._uri,
        queryParameters: configuration.queryParameters,
        isReplacement: configuration.isReplacement,
        requestSource: configuration.requestSource,
      );
    }

    return SynchronousFuture(null);
  }

  @override
  Future<void> setInitialRoutePath(RouteData configuration) {
    assert(!_isDisposed);

    _state.currentConfiguration = configuration._copyWith(historyIndex: 0);
    return SynchronousFuture(null);
  }

  void _initRouter(BuildContext context, {bool isReplacement = false}) {
    final routerNeedsBuilding = _state.routeMap == null;

    if (routerNeedsBuilding) {
      _state.routeMap = _buildRoutes(context);

      final pending = _state.pendingNavigation;
      if (pending != null) {
        // Process pending navigation after rebuild
        _navigate(
          uri: pending.uri,
          isReplacement: pending.isReplacement,
          navigationResult: pending.result,
          useCurrentState: false,
          requestSource: pending.requestSource,
          isBrowserHistoryNavigation: pending.isBrowserHistoryNavigation,
        );
      } else {
        _navigate(
          uri: currentConfiguration?._uri ?? Uri(path: '/'),
          isReplacement: isReplacement,
          useCurrentState: false,
          requestSource: RequestSource.internal,
        );
      }
    }
  }

  void _rebuildRouter(BuildContext context) {
    _state.routeMap = null;

    _isBuilding = true;
    _initRouter(context, isReplacement: true);
    _isBuilding = false;
  }

  void _navigate({
    required Uri uri,
    required bool isReplacement,
    required RequestSource requestSource,
    NavigationResult? navigationResult,
    Map<String, String>? queryParameters,
    bool useCurrentState = true,
    bool isRetry = false,
    bool isBrowserHistoryNavigation = false,
  }) {
    if (_state.routeMap == null) {
      // routeMap can be null after a hot reload
      return;
    }

    _state.pendingNavigation = null;
    final request = _RouteRequest(
      uri: uri,
      isReplacement: isReplacement,
      result: navigationResult,
      requestSource: requestSource,
      isBrowserHistoryNavigation: isBrowserHistoryNavigation,
    );

    var pages = _createAllPages(
      currentRoutes:
          useCurrentState ? _state.stack._getCurrentPages().toList() : null,
      request: request,
    );

    if (pages == null) {
      final noCurrentPages = _state.stack._getCurrentPages().isEmpty;

      // No page found from router
      if (isRetry || noCurrentPages) {
        // Either we're retrying after giving the routing map a chance to
        // rebuild, or we don't have a current stack of pages so we *have* to
        // build immediately.
        pages = _onUnknownRoute(request);
      } else {
        // No page has been found, but we don't call onUnknownRoute immediately.
        // Instead we schedule a new navigation for after this frame. This is
        // for cases where the user has updated the route map (e.g. by changing
        // the app state) and called .push() within the same frame.
        _state.pendingNavigation = request;

        if (!_isBuilding) {
          // Schedule rebuild if we're not in build phase
          notifyListeners();
        }

        _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((timeStamp) {
          if (_state.pendingNavigation != null) {
            // Retry navigation
            _navigate(
              uri: uri,
              isReplacement: isReplacement,
              useCurrentState: useCurrentState,
              navigationResult: navigationResult,
              queryParameters: queryParameters,
              requestSource: requestSource,
              isRetry: true,
              isBrowserHistoryNavigation: isBrowserHistoryNavigation,
            );
          }
        });

        return;
      }
    }

    assert(pages.isNotEmpty);

    _state.stack._pageContainers = pages;

    final pathIsSame =
        _state.currentConfiguration!.fullPath == pages.last.routeData.fullPath;

    _updateCurrentConfiguration(
      isReplacement: pathIsSame || isReplacement,
      isBrowserHistoryNavigation: isBrowserHistoryNavigation,
      requestSource: requestSource,
    );
  }

  /// Called when dependencies of the [routesBuilder] changed.
  ///
  /// This triggers a full rebuild of the routes.
  void _didChangeDependencies(BuildContext context) {
    if (currentConfiguration == null) {
      return;
    }

    // Reset state
    _rebuildRouter(context);

    // Already building; schedule rebuild for next frame
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      _updateCurrentConfiguration();
    });
  }

  /// The main Routemaster algorithm that turns a route request into a list of
  /// pages. It attempts to reuse current pages from [currentRoutes] if they
  /// exist.
  List<PageContainer>? _createAllPages({
    required _RouteRequest request,
    List<PageContainer>? currentRoutes,
    List<String>? redirects,
  }) {
    final requestedPath = request.uri.toString();
    final routerResult = _getAllRouterResults(requestedPath);

    if (routerResult == null || routerResult.isEmpty) {
      return null;
    }

    var result = <PageContainer>[];
    var i = 0;

    // Loop through routes in reverse order
    for (final routerData in routerResult.reversed) {
      final isLastRoute = i++ == 0;

      // Look the route up in the routing map
      final routeData = RouteData._fromRouterResult(
        routerData,
        // Only the last route gets query parameters
        isLastRoute ? request.uri : Uri(path: routerData.pathSegment),
        isReplacement: request.isReplacement,
        requestSource: request.requestSource,
      );

      if (routeData._privateSegmentIndex != null &&
          request.requestSource == RequestSource.system) {
        // Route contains private URL, deny loading from system request
        return null;
      }

      // Get a page container object for the current route
      late final _PageResult current;
      if (isLastRoute) {
        final page = routerData.builder(routeData);
        _assertIsPage(page, routeData.fullPath);
        current = _createPageContainer(
          routeRequest: request,
          page: page as Page,
          routeData: routeData,
          isLastRoute: true,
        );
      } else {
        current = _getOrCreatePageContainer(
          routeRequest: request,
          routeData: routeData,
          currentRoutes: currentRoutes,
          routerResult: routerData,
        );
      }

      if (current is _PageEntryResult) {
        final page = current.page;

        if (isLastRoute) {
          // Set the page result for popped return values
          page._result = request.result;
        }

        if (result.isNotEmpty &&
            page is MultiChildPageContainer &&
            page.maybeSetChildPages(result)) {
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
        return _onUnknownRoute(request);
      }

      if (current is _RedirectResult) {
        if (kDebugMode) {
          redirects = _debugCheckRedirectLoop(redirects, requestedPath);
        }

        return _createAllPages(
          currentRoutes: currentRoutes,
          redirects: redirects,
          request: _RouteRequest(
            uri: Uri.parse(current.redirectPath),
            isReplacement: request.isReplacement,
            requestSource: request.requestSource,
            isBrowserHistoryNavigation: request.isBrowserHistoryNavigation,
          ),
        );
      }
    }

    assert(result.isNotEmpty, "_createAllStates can't return empty list");

    return result;
  }

  /// Gets a list of results from the router. If a result can't be found, the
  /// router is rebuilt and the request retried. This is for cases where some
  /// state has updated but the map hasn't yet been rebuilt.
  List<RouterResult>? _getAllRouterResults(String requestedPath) {
    return _state.routeMap!.getAll(requestedPath);
  }

  RouteMap _buildRoutes(BuildContext context) {
    assert(
      context.owner!.debugBuilding,
      'Tried to call route builder outside of build phase',
    );

    return routesBuilder(context);
  }

  /// If there's a current route matching the path in the tree, return it.
  /// Otherwise create a new one. This could possibly be made more efficient
  /// By using a map rather than iterating over all currentRoutes.
  _PageResult _getOrCreatePageContainer({
    required _RouteRequest routeRequest,
    required RouteData routeData,
    required List<PageContainer>? currentRoutes,
    required RouterResult routerResult,
  }) {
    if (currentRoutes != null) {
      final currentState = currentRoutes.firstWhereOrNull(
        ((element) => element.routeData.path == routeData.path),
      );

      if (currentState != null) {
        return _PageEntryResult(currentState);
      }
    }

    // No current route, create a new one
    return _createPageContainer(
      routeRequest: routeRequest,
      page: routerResult.builder(routeData) as Page,
      routeData: routeData,
      isLastRoute: false,
    );
  }

  /// Called by tab pages to lazily generate their initial routes
  PageContainer _getSinglePage(_RouteRequest request) {
    final requestedPath = request.uri.toString();

    final routerResult = _state.routeMap!.get(requestedPath);
    if (routerResult != null) {
      final routeData = RouteData._fromRouterResult(
        routerResult,
        Uri.parse(requestedPath),
        isReplacement: request.isReplacement,
        requestSource: request.requestSource,
      );

      final page = routerResult.builder(routeData);
      _assertIsPage(page, routeData.fullPath);

      final result = _createPageContainer(
        routeRequest: request,
        page: routerResult.builder(routeData) as Page,
        routeData: routeData,
        isLastRoute: false,
      );

      if (result is _PageEntryResult) {
        return result.page;
      }

      if (result is _RedirectResult) {
        return _getSinglePage(
          _RouteRequest(
            uri: Uri.parse(result.redirectPath),
            isReplacement: request.isReplacement,
            requestSource: request.requestSource,
            isBrowserHistoryNavigation: request.isBrowserHistoryNavigation,
          ),
        );
      }
    }

    return _TabNotFoundPage(request);
  }

  _PageResult _createPageContainer({
    required _RouteRequest routeRequest,
    required Page page,
    required RouteData routeData,
    required bool isLastRoute,
  }) {
    while (page is Guard) {
      if (!page.canNavigate(routeData, _context)) {
        if (page.onNavigationFailed == null) {
          return _NotFoundResult();
        }

        final result = page.onNavigationFailed!(routeData, _context);
        return _createPageContainer(
          routeRequest: routeRequest,
          page: result,
          routeData: routeData,
          isLastRoute: isLastRoute,
        );
      }

      page = page.builder();
    }

    if (page is NotFound) {
      return _NotFoundResult();
    }

    if (page is Redirect) {
      return _RedirectResult(
          _fillRedirectPathParams(page.redirectPath, routeData));
    }

    if (isLastRoute && page is RedirectingPage) {
      return _RedirectResult(
        pathContext.join(
          routeRequest.uri.path,
          page.redirectPath,
        ),
      );
    }

    if (page is StatefulPage) {
      final state = page.createState();

      assert(
        state._debugTypesAreRight(page),
        '${page.runtimeType}.createState must return a subtype of PageState<${page.runtimeType}>, but it returned ${state.runtimeType}.',
      );

      state._page = page;
      state._routeData = routeData;
      state._routemasterState = _state;
      state.initState();

      return _PageEntryResult(state);
    }

    // Page is just a standard Flutter page, create a StatelessPage for it
    return _PageEntryResult(
      StatelessPage(routeData: routeData, page: page),
    );
  }

  String _fillRedirectPathParams(String redirectPath, RouteData routeData) {
    final pathSegments = pathContext.split(redirectPath);
    final mappedSegments = pathSegments.map((segment) => segment.startsWith(':')
        ? routeData.pathParameters[segment.substring(1)] ?? segment
        : segment);
    return pathContext.joinAll(mappedSegments);
  }

  List<PageContainer> _onUnknownRoute(_RouteRequest request) {
    final requestedPath = request.uri;
    final fullPath = request.uri.toString();
    final result = _state.routeMap!.onUnknownRoute(request.uri.toString());

    _assertIsPage(result, fullPath);

    if (result is Redirect) {
      final redirectResult = _createAllPages(
        request: _RouteRequest(
          uri: Uri.parse(result.redirectPath),
          isReplacement: request.isReplacement,
          requestSource: request.requestSource,
          isBrowserHistoryNavigation: request.isBrowserHistoryNavigation,
        ),
      );

      if (redirectResult != null) {
        return redirectResult;
      }
    }

    // Return 404 page
    return [
      StatelessPage(
        routeData: RouteData._fromUri(
          requestedPath,
          isReplacement: request.isReplacement,
          pathTemplate: null,
        ),
        page: result as Page,
      )
    ];
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

  void _didPush(Route route) {
    final page = route.settings;
    final current = _state.stack
        ._getCurrentPages()
        .firstWhereOrNull((e) => e._getOrCreatePage() == page);

    final completer = current?._result?._routeCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(route);
    }
  }

  /// Attempts to find the current route data for the given [context].
  ///
  /// Returns `null` if no route data is found.
  RouteData? _maybeRouteDataFor(Page page) {
    return _state.stack._getRouteData(page);
  }
}

/// A union type for results from the page map.
@immutable
abstract class _PageResult {}

class _PageEntryResult extends _PageResult {
  final PageContainer page;

  _PageEntryResult(this.page);
}

class _NotFoundResult extends _PageResult {}

class _RedirectResult extends _PageResult {
  final String redirectPath;

  _RedirectResult(this.redirectPath);
}

class _PushObserver extends NavigatorObserver {
  final _RoutemasterState state;

  _PushObserver(this.state);

  @override
  void didPush(Route route, Route? previousRoute) {
    state.delegate._didPush(route);
  }
}

/// Used internally so descendent widgets can use `Routemaster.of(context)`.
class _RoutemasterWidget extends InheritedWidget {
  final _RoutemasterState state;
  final RouteData routeData;

  const _RoutemasterWidget({
    required Widget child,
    required this.state,
    required this.routeData,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant _RoutemasterWidget oldWidget) {
    return oldWidget.routeData != routeData;
  }
}

/// Maintains the router's state so [RoutemasterDelegate] can be replaced but
/// still maintain its state.
class _RoutemasterState {
  final stack = PageStack();
  late final history = RouteHistory._(this);
  RouteMap? routeMap;
  RouteData? currentConfiguration;
  _RouteRequest? pendingNavigation;
  late RoutemasterDelegate delegate;

  late _PushObserver pushObserver = _PushObserver(this);
}

class _RoutemasterStateTracker extends StatefulWidget {
  final RoutemasterDelegate delegate;
  final Widget Function(BuildContext context) builder;

  const _RoutemasterStateTracker({
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
    widget.delegate._didChangeDependencies(context);
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
      newDelegate._state.delegate = newDelegate;

      newDelegate._rebuildRouter(context);

      _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((_) {
        // Dispose after this frame to allow child widgets to unsubscribe
        oldDelegate.dispose();
      });
    }
  }
}

/// Thrown when the router gets in an endless redirect loop due to a
/// misconfigured routing map.
@immutable
class RedirectLoopError extends Error {
  /// A list of paths in the redirect loop.
  final List<String> redirects;

  /// Initializes an error that the router is in an endless redirect loop.
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
  final Uri uri;
  final bool isReplacement;
  final NavigationResult? result;
  final RequestSource requestSource;
  final bool isBrowserHistoryNavigation;

  _RouteRequest({
    required this.uri,
    required this.requestSource,
    required this.isBrowserHistoryNavigation,
    this.isReplacement = false,
    this.result,
  });
}

/// Where the navigation request originated from.
enum RequestSource {
  /// Navigation request came from the system, such as the user typing a URL
  /// into the address bar.
  system,

  /// Navigation request came from an API call, such as `.push()`.
  internal,
}

/// Provides a [Navigator] that shows pages from a [PageStack].
///
/// This widget listens to that stack, and updates the navigator when the pages
/// change.
class PageStackNavigator extends StatefulWidget {
  /// The stack of pages to show in the [Navigator].
  final PageStack stack;

  /// A delegate that decides how pages are animated when they're added or
  /// removed from the [Navigator].
  final TransitionDelegate transitionDelegate;

  /// A list of [NavigatorObserver] that will be passed to the [Navigator].
  final List<NavigatorObserver> observers;

  /// A function that can filter or transform the list of pages from the stack.
  final Iterable<Page> Function(List<Page>)? builder;

  /// An optional key that's passed to the [Navigator] widget.
  ///
  /// Using a `GlobalKey<NavigatorState>` will provide access to [Navigator]
  /// functionality.
  final Key? navigatorKey;

  /// Provides a [Navigator] that shows pages from a [PageStack].
  const PageStackNavigator({
    Key? key,
    required this.stack,
    this.transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
    this.observers = const [],
    this.navigatorKey,
  })  : builder = null,
        super(key: key);

  /// Provides a [Navigator] that shows pages from a [PageStack].
  ///
  /// This constructor provides an additional `builder` function that can filter
  /// or transform the list of pages from the stack.
  const PageStackNavigator.builder({
    Key? key,
    required this.stack,
    required this.builder,
    this.transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
    this.observers = const [],
    this.navigatorKey,
  }) : super(key: key);

  @override
  PageStackNavigatorState createState() => PageStackNavigatorState();

  /// Retrieves the nearest [PageStackNavigatorState] ancestor.
  static PageStackNavigatorState of(BuildContext context) {
    final state = context.findAncestorStateOfType<PageStackNavigatorState>();
    assert(state != null, "Couldn't find a StackNavigatorState");
    return state!;
  }
}

/// The state for a [PageStackNavigator]. Watches for changes in the stack
/// and rebuilds the [Navigator] when required.
class PageStackNavigatorState extends State<PageStackNavigator> {
  late _StackNavigator _widget;
  late Routemaster _routemaster;

  /// The state for a [PageStackNavigator]. Watches for changes in the stack
  /// and rebuilds the [Navigator] when required.
  PageStackNavigatorState();

  @override
  void initState() {
    super.initState();

    _didUpdateStack(null, widget.stack);
    _updateNavigator();
  }

  @override
  void didUpdateWidget(PageStackNavigator oldWidget) {
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
  }

  @override
  void dispose() {
    widget.stack.removeListener(_onStackChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routemaster = Routemaster.of(context);
  }

  void _onStackChanged() {
    setState(() {
      _updateNavigator();
    });
  }

  void _updateNavigator() {
    final pages = widget.stack.createPages();
    final filteredPages =
        widget.builder == null ? pages : widget.builder!(pages).toList();

    _widget = _StackNavigator(
      key: widget.navigatorKey,
      stack: widget.stack,
      onPopPage: (route, dynamic result) {
        return widget.stack.onPopPage(route, result, _routemaster);
      },
      transitionDelegate: widget.transitionDelegate,
      pages: filteredPages,
      observers: [
        _RelayingNavigatorObserver(
          () sync* {
            final delegate = _routemaster._state.delegate;

            yield* widget.observers;
            yield* delegate.observers;
            yield delegate._state.pushObserver;
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _widget;
  }
}

/// A subclass of [Navigator] that attaches itself to a [PageStack], so that
/// the stack can use [Navigator.maybePop].
///
/// This is to support popping non-[Page] routes.
class _StackNavigator extends Navigator {
  final PageStack stack;

  const _StackNavigator({
    required this.stack,
    Key? key,
    PopPageCallback? onPopPage,
    TransitionDelegate transitionDelegate =
        const DefaultTransitionDelegate<dynamic>(),
    List<Page> pages = const <Page<dynamic>>[],
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
  }) : super(
          key: key,
          onPopPage: onPopPage,
          transitionDelegate: transitionDelegate,
          pages: pages,
          observers: observers,
        );

  @override
  NavigatorState createState() {
    return _StackNavigatorState();
  }
}

class _StackNavigatorState extends NavigatorState {
  @override
  void initState() {
    super.initState();
    (widget as _StackNavigator).stack._attachedNavigator = this;
  }

  @override
  void dispose() {
    (widget as _StackNavigator).stack._attachedNavigator = null;
    super.dispose();
  }
}

void _assertIsPage(RouteSettings page, String route) {
  assert(
    page is Page,
    "Route builders must return a Page object. The route builder for '$route' instead returned an object of type '${page.runtimeType}'.",
  );
}

enum _ReportType {
  none,
  navigate,
  neglect,
}

T? _ambiguate<T>(T? value) => value;
