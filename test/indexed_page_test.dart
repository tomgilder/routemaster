import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can switch indexed tab index', (tester) async {
    final pageKey = GlobalKey();
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => IndexedPage(
              paths: const ['one', 'two'],
              child: TabPage(key: pageKey),
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

    expect(find.text('Index 0'), findsOneWidget);
    final pageState = IndexedPage.of(pageKey.currentContext!);
    pageState.index = 1;
    await tester.pump();
    expect(find.text('Index 1'), findsOneWidget);
  });

  testWidgets('Switches to correct index when building child route',
      (tester) async {
    final pageKey = GlobalKey();
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => IndexedPage(
              paths: const ['one', 'two'],
              child: TabPage(key: pageKey),
            ),
        '/one': (_) => const MaterialPageOne(),
        '/two': (_) => const MaterialPageTwo(),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: const RouteInformation(location: '/two'),
        ),
        routerDelegate: delegate,
      ),
    );

    final pageState = IndexedPage.of(pageKey.currentContext!);
    expect(pageState.index, 1);
  });

  testWidgets('Shows not found page within tab', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => const IndexedPage(
              paths: ['not-found', 'two'],
              child: BasicTabPage(),
            ),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.text("Page '/not-found' wasn't found."), findsOneWidget);
  });

  testWidgets('Can redirect within tab', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => const IndexedPage(
              paths: ['one', 'two'],
              child: BasicTabPage(),
            ),
        '/one': (_) => const Redirect('/three'),
        '/two': (_) => const MaterialPageTwo(),
        '/three': (_) => const MaterialPageThree(),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageThree), findsOneWidget);
  });

  testWidgets('Can use custom page with indexed page', (tester) async {
    const key = Key('custom');
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => IndexedPage(
                paths: const ['/one', '/two'],
                child: const BasicTabPage(),
                pageBuilder: (child) => CupertinoPage<void>(
                  child: Container(key: key, child: child),
                ),
              ),
          '/one': (_) => const MaterialPageOne(),
          '/two': (_) => const MaterialPageTwo(),
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

  testWidgets('No history entries created with TabBackBehavior.none',
      (tester) async {
    final pageKey = GlobalKey();
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => IndexedPage(
              paths: const ['one', 'two'],
              child: TabPage(key: pageKey),
              backBehavior: TabBackBehavior.none,
            ),
        '/one': (_) => const MaterialPageOne(),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.text('Index 0'), findsOneWidget);
    final pageState = IndexedPage.of(pageKey.currentContext!);
    pageState.index = 1;
    await tester.pump();
    expect(find.text('Index 1'), findsOneWidget);
    expect(delegate.history.canGoBack, isFalse);
    expect(delegate.history.canGoForward, isFalse);
  });

  testWidgets('Creates history entries with TabBackBehavior.history',
      (tester) async {
    final pageKey = GlobalKey();
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => IndexedPage(
              paths: const ['one', 'two', 'three'],
              child: BasicTabPage(key: pageKey),
              backBehavior: TabBackBehavior.history,
            ),
        '/one': (_) => const MaterialPageOne(),
        '/two': (_) => const MaterialPageTwo(),
        '/three': (_) => const MaterialPageThree(),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final pageState = IndexedPage.of(pageKey.currentContext!);

    // Go to page 3
    pageState.index = 2;
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);

    // Go to page 2
    pageState.index = 1;
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);
    expect(delegate.history.canGoBack, isTrue);
    expect(delegate.history.canGoForward, isFalse);

    // On page 2, go back to page 3
    delegate.history.back();
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
    expect(delegate.history.canGoBack, isTrue);
    expect(delegate.history.canGoForward, isTrue);

    // On page 3, go back to page 1
    delegate.history.back();
    await tester.pumpPageTransition();
    expect(find.byType(PageOne), findsOneWidget);
    expect(delegate.history.canGoBack, isFalse);
    expect(delegate.history.canGoForward, isTrue);

    // On page 1, go forward to page 3
    delegate.history.forward();
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
    expect(delegate.history.canGoBack, isTrue);
    expect(delegate.history.canGoForward, isTrue);

    // On page 3, go forward to page 2
    delegate.history.forward();
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);
    expect(delegate.history.canGoBack, isTrue);
    expect(delegate.history.canGoForward, isFalse);
  });
}

class TabPage extends StatelessWidget {
  const TabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indexedPage = IndexedPage.of(context);

    return Scaffold(
      body: Text('Index ${indexedPage.index}'),
    );
  }
}

class BasicTabPage extends StatelessWidget {
  const BasicTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stack = IndexedPage.of(context).currentStack;

    return Scaffold(
      body: PageStackNavigator(stack: stack),
    );
  }
}
