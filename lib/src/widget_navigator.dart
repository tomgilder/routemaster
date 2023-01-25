// ignore_for_file: public_member_api_docs

part of '../routemaster.dart';

/// Provides a [Navigator] that shows pages from a [PageStack].
///
/// This widget listens to that stack, and updates the navigator when the pages
/// change.
class WidgetPageStackNavigator extends StatefulWidget {
  /// The stack of pages to show in the [Navigator].
  final PageStack stack;

  /// A list of [NavigatorObserver] that will be passed to the [Navigator].
  final List<NavigatorObserver> observers;

  /// A function that can filter or transform the list of pages from the stack.
  final ChildrenBuilder builder;

  /// Provides a [Navigator] that shows pages from a [PageStack].
  const WidgetPageStackNavigator({
    Key? key,
    required this.stack,
    required this.builder,
    this.observers = const [],
  }) : super(key: key);

  @override
  WidgetPageStackNavigatorState createState() =>
      WidgetPageStackNavigatorState();

  /// Retrieves the nearest [WidgetPageStackNavigatorState] ancestor.
  static WidgetPageStackNavigatorState of(BuildContext context) {
    final state =
        context.findAncestorStateOfType<WidgetPageStackNavigatorState>();
    assert(state != null, "Couldn't find a StackNavigatorState");
    return state!;
  }
}

class WidgetPageStackNavigatorState extends State<WidgetPageStackNavigator> {
  late _WidgetStackNavigator _widget;
  late Routemaster _routemaster;

  /// The state for a [WidgetPageStackNavigator]. Watches for changes in the stack
  /// and rebuilds the [Navigator] when required.
  WidgetPageStackNavigatorState();

  @override
  void initState() {
    super.initState();

    _didUpdateStack(null, widget.stack);
    _updateNavigator();
  }

  @override
  void didUpdateWidget(WidgetPageStackNavigator oldWidget) {
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
    final filteredPages = pages;

    _widget = _WidgetStackNavigator(
      builder: widget.builder,
      stack: widget.stack,
      onPopPage: (route, dynamic result) {
        return widget.stack.onPopPage(route, result, _routemaster);
      },
      pages: filteredPages,
      observer: _RelayingNavigatorObserver(
        () sync* {
          final delegate = _routemaster._state.delegate;

          yield* widget.observers;
          yield* delegate.observers;
          yield delegate._state.pushObserver;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _widget;
  }
}

class _WidgetStackNavigator extends StatefulWidget {
  final PageStack stack;
  final ChildrenBuilder builder;
  final List<Page> pages;
  final _RelayingNavigatorObserver observer;
  final PopPageCallback onPopPage;

  const _WidgetStackNavigator({
    Key? key,
    required this.stack,
    required this.pages,
    required this.builder,
    required this.observer,
    required this.onPopPage,
  }) : super(key: key);

  @override
  _WidgetStackNavigatorState createState() => _WidgetStackNavigatorState();
}

class _WidgetStackNavigatorState extends State<_WidgetStackNavigator> {
  List<WidgetRoute> _routes = [];

  void _buildChildren() {
    setState(() {
      WidgetRoute? previousRoute;
      _routes = widget.pages.map((e) {
        final route = e.createRoute(context);
        assert(
          route is WidgetRoute,
          'You can only use WidgetRoutes with the widget navigator',
        );

        final widgetRoute = route as WidgetRoute;
        widgetRoute._previousRoute = previousRoute;
        previousRoute = widgetRoute;
        return widgetRoute;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _buildChildren();
  }

  @override
  void didUpdateWidget(covariant _WidgetStackNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldRoutes = _routes;
    _buildChildren();
    _diffRoutes(
      oldRoutes: oldRoutes,
      newRoutes: _routes,
    );
  }

  void _diffRoutes({
    required List<WidgetRoute> oldRoutes,
    required List<WidgetRoute> newRoutes,
  }) {
    final maxIndex = max(newRoutes.length, oldRoutes.length);
    for (var i = 0; i < maxIndex; i++) {
      final newRoute = newRoutes.elementAtOrNull(i);
      final oldRoute = oldRoutes.elementAtOrNull(i);
      final previousRoute = oldRoutes.elementAtOrNull(i - 1);

      if (oldRoute == null && newRoute != null) {
        // Page was pushed
        widget.observer.didPush(newRoute, previousRoute);
      }

      if (oldRoute != null &&
          newRoute != null &&
          oldRoute.routeData != newRoute.routeData) {
        // Page was replaced
        widget.observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
      }

      if (oldRoute != null && newRoute == null) {
        // Page was removed
        widget.observer.didRemove(oldRoute, previousRoute);
      }

      if (newRoute != null) {
        newRoute._canPop = newRoute != newRoutes.last;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onPopPage: widget.onPopPage,
      pages: [
        TransitionPage<void>(
          child: widget.builder(context, _routes),
          pushTransition: PageTransition.none,
          popTransition: PageTransition.none,
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class WidgetPage<T> extends Page<T> with RouteDataPage<T> {
  final Widget child;
  // late final Widget child = RouteDataScope(
  //   page: this,
  //   child: _child,
  // );

  WidgetPage({required this.child});

  @override
  Route<T> createRoute(BuildContext context) {
    return WidgetRoute<T>(page: this);
  }
}

class WidgetRoute<T> extends Route<T> {
  WidgetRoute({
    required WidgetPage page,
  }) : super(settings: page);

  @override
  NavigatorState? navigator;

  WidgetPage<T> get _page => settings as WidgetPage<T>;

  bool _canPop = false;
  bool get canPop => _canPop;

  WidgetRoute? _previousRoute;
  WidgetRoute? get previousRoute => _previousRoute;

  RouteData get routeData => _page.routeData;

  static WidgetRoute of(BuildContext context) {
    return RouteDataScope.maybeOf(context)!.route as WidgetRoute;
  }

  late final Widget child = RouteDataScope(
    route: this,
    page: _page,
    child: _page.child,
  );
}

typedef ChildrenBuilder = Widget Function(
    BuildContext context, List<WidgetRoute> pages);

mixin RouteDataPage<T> on Page<T> {
  RouteData? _routeData;
  RouteData get routeData => _routeData!;
}
