import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:routemaster/routemaster.dart';

class TestMaterialPage<T> extends Page<T> {
  const TestMaterialPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );
  final Widget child;

  final bool maintainState;

  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    print('createRoute');

    return TestPageRoute<T>(page: this, page2: this);
  }
}

class TestPageRoute<T> extends PageRoute<T> {
  // TestMaterialPage<T> get _page => settings as TestMaterialPage<T>;
  final TestMaterialPage<T> page;

  TestPageRoute({
    required this.page,
    required TestMaterialPage<T> page2,
  }) : super(settings: page2);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return page.child;
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  void changedInternalState() {
    // TODO: implement changedInternalState
    super.changedInternalState();
  }
}

class MaterialWithModalsPage extends Page<void> {
  final Widget child;

  MaterialWithModalsPage({required this.child});

  @override
  Route<void> createRoute(BuildContext context) {
    return MaterialWithModalsPageRoute(
      builder: (_) => child,
      settings: this,
    );
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

class BottomSheetContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageStackNavigator(stack: FlowPage.of(context).stack);
  }
}

class BottomSheetPageOne extends StatelessWidget {
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
              onPressed: () => FlowPage.of(context).pushNext(),
              child: Text('Next page'),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomSheetPageTwo extends StatelessWidget {
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

// class AddWishlistPage extends Page<void> {
//   @override
//   Route<void> createRoute(BuildContext context) {
//     return DialogRoute(
//       context: context,
//       builder: (context) => AddWishlistDialog(),
//       settings: this,
//     );
//   }
// }

// class BottomSheetPage extends StackPage {
//   BottomSheetPage()
//       : super(
//           path: '/test',
//           child: BottomSheetContents(),
//         );

//   @override
//   PageState createState() {
//     return BottomSheetPageState();
//   }
// }

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

class MaterialPage2<T> extends Page<T> {
  /// Creates a material page.
  const MaterialPage2({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
            key: key,
            name: name,
            arguments: arguments,
            restorationId: restorationId);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedMaterialPageRoute2<T>(page: this);
  }
}

// A page-based version of MaterialPageRoute.
//
// This route uses the builder from the page to build its content. This ensures
// the content is up to date after page updates.
class _PageBasedMaterialPageRoute2<T> extends PageRoute<T> {
  _PageBasedMaterialPageRoute2({
    required MaterialPage2<T> page,
  }) : super(settings: page) {
    assert(opaque);
  }

  MaterialPage2<T> get _page => settings as MaterialPage2<T>;

  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is MaterialRouteTransitionMixin &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoRouteTransitionMixin &&
            !nextRoute.fullscreenDialog);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final result = buildContent(context);

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions<T>(
        this, context, animation, secondaryAnimation, child);
  }
}
