import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Hot reload stays on route', (tester) async {
    await recordUrlChanges((systemUrl) async {
      await tester.pumpWidget(MyApp());

      expect(find.byType(CupertinoTabBar), findsOneWidget);

      // Go to profile page
      await tester.tap(find.text('Push page'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(systemUrl.current, '/feed/profile');
      expect(
        find.byType(ProfilePage),
        findsOneWidget,
      );

      unawaited(tester.binding.reassembleApplication());
      await tester.pump();

      expect(
        find.byType(ProfilePage),
        findsOneWidget,
      );
    });
  });

  testWidgets('Can navigate after hot reload', (tester) async {
    await recordUrlChanges((systemUrl) async {
      await tester.pumpWidget(MyApp());
      unawaited(tester.binding.reassembleApplication());
      await tester.pump();

      await tester.tap(find.text('Push page'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(systemUrl.current, '/feed/profile');
      expect(find.byType(ProfilePage), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(systemUrl.current, '/feed');
      expect(find.byType(ProfilePage), findsNothing);

      await tester.tap(find.text('Push page'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(systemUrl.current, '/feed/profile');
      expect(find.byType(ProfilePage), findsOneWidget);
    });
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (context) => routeMap,
      ),
    );
  }
}

final routeMap = RouteMap(routes: {
  '/': (_) => CupertinoTabPage(child: HomePage(), paths: const ['feed']),
  '/feed': (_) => MaterialPage<void>(child: FeedPage()),
  '/feed/profile': (info) => MaterialPage<void>(child: ProfilePage())
});

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () => Routemaster.of(context).push('profile'),
        child: const Text('Push page'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar());
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: '1',
            icon: Icon(CupertinoIcons.list_bullet),
          ),
          BottomNavigationBarItem(
            label: '2',
            icon: Icon(CupertinoIcons.search),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        final stack = tabState.stacks[index];
        return PageStackNavigator(stack: stack);
      },
    );
  }
}
