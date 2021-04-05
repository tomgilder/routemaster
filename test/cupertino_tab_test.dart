import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';

import 'helpers.dart';

void main() {
  testWidgets('Can switch between cupertino tabs', (tester) async {
    await tester.pumpWidget(CupertinoApp());
    expect(find.byType(FeedPage), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pump();

    expect(find.byType(FeedPage), findsNothing);
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('Can push into cupertino tab', (tester) async {
    await tester.pumpWidget(CupertinoApp());
    expect(find.byType(FeedPage), findsOneWidget);

    await tester.tap(find.text('Profile page'));
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(find.byType(ProfilePage), findsOneWidget);

    await tester.tap(find.text('Pop'));
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(find.byType(ProfilePage), findsNothing);
    expect(find.byType(FeedPage), findsOneWidget);
  });

  testWidgets('CupertinoTabController syncs with page state', (tester) async {
    final pageKey = GlobalKey();
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => CupertinoTabPage(
              paths: ['one', 'two'],
              child: TabbedPage(key: pageKey),
            ),
        '/one': (_) => MaterialPageOne(),
        '/two': (_) => MaterialPageTwo(),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final pageState = CupertinoTabPage.of(pageKey.currentContext!);
    final tabController = pageState.tabController;

    expect(pageState.index, 0);
    expect(tabController.index, 0);

    pageState.index = 1;
    expect(pageState.index, 1);
    expect(tabController.index, 1);

    tabController.index = 0;
    expect(pageState.index, 0);
    expect(tabController.index, 0);
  });
}

final routes = RouteMap(
  routes: {
    '/': (_) => CupertinoTabPage(
          child: HomePage(),
          paths: ['feed', 'settings'],
        ),
    '/feed': (_) => MaterialPage<void>(child: FeedPage()),
    '/feed/profile/:id': (_) => MaterialPage<void>(child: ProfilePage()),
    '/settings': (_) => MaterialPage<void>(child: SettingsPage()),
  },
);

class CupertinoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: RoutemasterDelegate(routesBuilder: (_) => routes),
      routeInformationParser: RoutemasterParser(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.tabController,
      tabBuilder: tabState.tabBuilder,
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            label: 'Feed',
            icon: Icon(CupertinoIcons.list_bullet),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(CupertinoIcons.search),
          ),
        ],
      ),
    );
  }
}

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Routemaster.of(context).push('profile/1'),
          child: Text('Profile page'),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text('Profile page'),
            CupertinoButton(
              onPressed: () => Routemaster.of(context).pop(),
              child: Text('Pop'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Settings page')));
  }
}

class TabbedPage extends StatelessWidget {
  TabbedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
