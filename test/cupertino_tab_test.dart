import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can switch between cupertino tabs', (tester) async {
    await tester.pumpWidget(CupertinoApp());
    expect(find.byType(FeedPage), findsOneWidget);

    await tester.tap(find.text('Two'));
    await tester.pump();

    expect(find.byType(FeedPage), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('No history entries created with TabBackBehavior.none',
      (tester) async {
    var app = CupertinoApp(
      tabBackBehavior: TabBackBehavior.none,
    );
    await tester.pumpWidget(app);
    expect(find.byType(FeedPage), findsOneWidget);

    await tester.tap(find.text('Two'));
    await tester.pump();

    expect(find.byType(PageTwo), findsOneWidget);
    expect(app.delegate.history.canGoBack, isFalse);
  });

  testWidgets('Can use TabBackBehavior.history with Cupertino tabs',
      (tester) async {
    final app = CupertinoApp(
      tabBackBehavior: TabBackBehavior.history,
    );
    await tester.pumpWidget(app);

    expect(find.byType(FeedPage), findsOneWidget);

    // Go to page 3
    await tester.tap(find.text('Three'));
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
    expect(app.delegate.history.canGoBack, isTrue);
    expect(app.delegate.history.canGoForward, isFalse);

    // Go to page 2
    await tester.tap(find.text('Two'));
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);
    expect(app.delegate.history.canGoBack, isTrue);
    expect(app.delegate.history.canGoForward, isFalse);

    // Go back to page 3
    final result = app.delegate.history.back();
    expect(result, isTrue);
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
    expect(app.delegate.history.canGoBack, isTrue);
    expect(app.delegate.history.canGoForward, isTrue);

    // Go back to feed page
    app.delegate.history.back();
    await tester.pumpPageTransition();
    expect(find.byType(FeedPage), findsOneWidget);
    expect(app.delegate.history.canGoBack, isFalse);
    expect(app.delegate.history.canGoForward, isTrue);

    // Go forward to page 3
    app.delegate.history.forward();
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
    expect(app.delegate.history.canGoBack, isTrue);
    expect(app.delegate.history.canGoForward, isTrue);

    // Go forward to page 2
    app.delegate.history.forward();
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);
    expect(app.delegate.history.canGoBack, isTrue);
    expect(app.delegate.history.canGoForward, isFalse);
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
              paths: const ['one', 'two'],
              child: TabbedPage(key: pageKey),
            ),
        '/one': (_) => const MaterialPageOne(),
        '/two': (_) => const MaterialPageTwo(),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final pageState = CupertinoTabPage.of(pageKey.currentContext!);
    final tabController = pageState.controller;

    expect(pageState.index, 0);
    expect(tabController.index, 0);

    pageState.index = 1;
    expect(pageState.index, 1);
    expect(tabController.index, 1);

    tabController.index = 0;
    expect(pageState.index, 0);
    expect(tabController.index, 0);
  });

  testWidgets('Can use custom page with CupertinoTabPage', (tester) async {
    const key = Key('custom');
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => CupertinoTabPage(
                paths: const ['/one', '/two'],
                child: const TabbedPage(),
                pageBuilder: (child) => CupertinoPage<void>(
                  child: Container(key: key, child: child),
                ),
              ),
          '/one': (_) => const MaterialPage<void>(child: PageOne()),
          '/two': (_) => const MaterialPage<void>(child: PageTwo()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byKey(key), findsOneWidget);
  });
}

class CupertinoApp extends StatelessWidget {
  final TabBackBehavior tabBackBehavior;

  CupertinoApp({
    Key? key,
    this.tabBackBehavior = TabBackBehavior.none,
  }) : super(key: key);

  late final delegate = RoutemasterDelegate(
    routesBuilder: (_) => RouteMap(
      routes: {
        '/': (_) => CupertinoTabPage(
              child: HomePage(),
              paths: const ['feed', 'two', 'three'],
              backBehavior: tabBackBehavior,
            ),
        '/feed': (_) => MaterialPage<void>(child: FeedPage()),
        '/feed/profile/:id': (_) => MaterialPage<void>(child: ProfilePage()),
        '/two': (_) => const MaterialPageTwo(),
        '/three': (_) => const MaterialPageThree(),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: delegate,
      routeInformationParser: const RoutemasterParser(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: tabState.tabBuilder,
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            label: 'Feed',
            icon: Icon(CupertinoIcons.list_bullet),
          ),
          BottomNavigationBarItem(
            label: 'Two',
            icon: Icon(CupertinoIcons.search),
          ),
          BottomNavigationBarItem(
            label: 'Three',
            icon: Icon(CupertinoIcons.person_3),
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
          child: const Text('Profile page'),
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
            const Text('Profile page'),
            CupertinoButton(
              onPressed: () => Routemaster.of(context).pop(),
              child: const Text('Pop'),
            ),
          ],
        ),
      ),
    );
  }
}

class TabbedPage extends StatelessWidget {
  const TabbedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
