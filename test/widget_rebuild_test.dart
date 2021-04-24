import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets("Doesn't rebuild CupertinoTabPage when inner stack changes",
      (tester) async {
    var buildCount = 0;

    final delegate = RoutemasterDelegate(
      routesBuilder: (context) {
        return RouteMap(
          routes: {
            '/': (_) => CupertinoTabPage(
                  child: HomePage(onBuild: () {
                    buildCount++;
                  }),
                  paths: ['one', 'three'],
                ),
            '/one': (_) => MaterialPageOne(),
            '/one/two': (_) => MaterialPageTwo(),
            '/three': (_) => MaterialPageThree(),
          },
        );
      },
    );
    await tester.pumpWidget(MaterialApp.router(
      routeInformationParser: RoutemasterParser(),
      routerDelegate: delegate,
    ));

    expect(buildCount, 1);
    delegate.push('/one/two');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(buildCount, 1);
  });
}

class HomePage extends StatelessWidget {
  final void Function() onBuild;

  HomePage({required this.onBuild});

  @override
  Widget build(BuildContext context) {
    onBuild();

    final tabState = CupertinoTabPage.of(context);
    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: tabState.tabBuilder,
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Heros',
            icon: Icon(CupertinoIcons.list_bullet),
          ),
          BottomNavigationBarItem(
            label: 'Other',
            icon: Icon(CupertinoIcons.search),
          ),
        ],
      ),
    );
  }
}
