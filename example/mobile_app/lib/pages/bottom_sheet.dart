import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:routemaster/routemaster.dart';

class MaterialWithModalsPage extends Page<void> {
  final Widget child;

  const MaterialWithModalsPage({required this.child});

  @override
  Route<void> createRoute(BuildContext context) {
    return MaterialWithModalsPageRoute(builder: (_) => child, settings: this);
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
              onPressed: () {
                // Router.neglect(context, () {
                FlowPage.of(context).pushNext();
                // });
              },
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
