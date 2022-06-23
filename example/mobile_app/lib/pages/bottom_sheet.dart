import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:routemaster/routemaster.dart';

class MaterialWithModalsPage extends MaterialPage<void> {
  const MaterialWithModalsPage({
    required Widget child,
  }) : super(child: child);

  @override
  Route<void> createRoute(BuildContext context) {
    return PageBasedMaterialWithModalsPageRoute(page: this);
  }
}

class PageBasedMaterialWithModalsPageRoute<T>
    extends _PageBasedMaterialPageRoute<T> {
  PageBasedMaterialWithModalsPageRoute({
    required MaterialPage<T> page,
  }) : super(page: page);

  ModalBottomSheetRoute? _nextModalRoute;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is MaterialPageRoute && !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoPageRoute && !nextRoute.fullscreenDialog) ||
        (nextRoute is MaterialWithModalsPageRoute &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is ModalBottomSheetRoute);
  }

  @override
  void didChangeNext(Route? nextRoute) {
    if (nextRoute is ModalBottomSheetRoute) {
      _nextModalRoute = nextRoute;
    }

    super.didChangeNext(nextRoute);
  }

  @override
  void didPopNext(Route nextRoute) {
    super.didPopNext(nextRoute);
  }

  @override
  bool didPop(T? result) {
    _nextModalRoute = null;
    return super.didPop(result);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final theme = Theme.of(context).pageTransitionsTheme;
    final nextRoute = _nextModalRoute;
    if (nextRoute != null) {
      if (!secondaryAnimation.isDismissed) {
        // Avoid default transition theme to animate when a new modal view is pushed
        final fakeSecondaryAnimation =
            Tween<double>(begin: 0, end: 0).animate(secondaryAnimation);

        final defaultTransition = theme.buildTransitions<T>(
            this, context, animation, fakeSecondaryAnimation, child);
        return nextRoute.getPreviousRouteTransition(
            context, secondaryAnimation, defaultTransition);
      } else {
        _nextModalRoute = null;
      }
    }

    return theme.buildTransitions<T>(
        this, context, animation, secondaryAnimation, child);
  }
}

class BottomSheetPage extends Page<void> {
  final Widget child;

  BottomSheetPage({required this.child});

  @override
  Route<void> createRoute(BuildContext context) {
    return CupertinoModalBottomSheetRoute(
      containerBuilder: (context, _, child) => _CupertinoBottomSheetContainer(
        topRadius: Radius.circular(12),
        child: child,
      ),
      builder: (context) {
        // The Page object associated with this Route can change!
        // This happens for instance on a hot reload.
        // We need to make sure we don't save a reference to any page object,
        // but always get the current one.
        final page = ModalRoute.of(context)!.settings as BottomSheetPage;
        return page.child;
      },
      settings: this,
      expanded: false,
    );
  }
}

class StackBottomSheetContents extends StatelessWidget {
  const StackBottomSheetContents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageStackNavigator(stack: StackPage.of(context).stack);
  }
}

class StackPageOne extends StatelessWidget {
  const StackPageOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Routemaster.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ),
      child: Material(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Page One',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            CupertinoButton(
              onPressed: () => Routemaster.of(context).push('/stack/one/two'),
              child: Text('Next page'),
            ),
          ],
        ),
      ),
    );
  }
}

class StackPageTwo extends StatelessWidget {
  const StackPageTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: Material(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Page Two',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            CupertinoButton(
              onPressed: () => Routemaster.of(context).push('/feed'),
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

const double _kPreviousPageVisibleOffset = 10;
const BoxShadow _kDefaultBoxShadow =
    BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);

class _CupertinoBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Radius topRadius;
  final BoxShadow? shadow;

  const _CupertinoBottomSheetContainer({
    Key? key,
    required this.child,
    this.backgroundColor,
    required this.topRadius,
    this.shadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topSafeAreaPadding = MediaQuery.of(context).padding.top;
    final topPadding = _kPreviousPageVisibleOffset + topSafeAreaPadding;

    final _shadow = shadow ?? _kDefaultBoxShadow;
    BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);
    final _backgroundColor =
        backgroundColor ?? CupertinoTheme.of(context).scaffoldBackgroundColor;
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: topRadius),
        child: Container(
          decoration:
              BoxDecoration(color: _backgroundColor, boxShadow: [_shadow]),
          width: double.infinity,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true, //Remove top Safe Area
            child: child,
          ),
        ),
      ),
    );
  }
}

class _PageBasedMaterialPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _PageBasedMaterialPageRoute({
    required MaterialPage<T> page,
  }) : super(settings: page) {
    assert(opaque);
  }

  MaterialPage<T> get _page => settings as MaterialPage<T>;

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}
