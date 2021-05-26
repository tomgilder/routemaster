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
