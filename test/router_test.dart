import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can set system URL', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(
            routes: {
              '/': (_) => const MaterialPageOne(),
              '/two': (_) => const MaterialPageTwo(),
            },
          ),
        ),
      ),
    );

    await setSystemUrl('/two');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(PageTwo), findsOneWidget);
  });

  test('Throws after dispose', () {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: const {},
      ),
    );
    delegate.dispose();

    expect(() => delegate.currentConfiguration, throwsAssertionError);
    expect(
      () => delegate.setInitialRoutePath(RouteData('')),
      throwsAssertionError,
    );
    expect(
      () => delegate.setNewRoutePath(RouteData('path')),
      throwsAssertionError,
    );
    expect(() => delegate.push(''), throwsAssertionError);
    expect(() => delegate.replace(''), throwsAssertionError);
    expect(() => delegate.popRoute(), throwsAssertionError);
  });

  testWidgets('Asserts when no RoutemasterWidget found', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(Builder(
      builder: (c) {
        context = c;
        return const SizedBox();
      },
    ));

    expect(
        () => Routemaster.of(context),
        throwsA(predicate((e) =>
            e is AssertionError &&
            e.message ==
                "Couldn't get a Routemaster object from the given context.")));
  });

  testWidgets('Can push relative path when current page has query string',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
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

    delegate.push('/?query=string');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageOne), findsOneWidget);

    delegate.push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Can replace relative path when current page has query string',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
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

    delegate.replace('/?query=string');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageOne), findsOneWidget);

    delegate.replace('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Can push just a query string', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
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

    expect(
      await recordUrlChanges(() async {
        delegate.push('?query=string');
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/?query=string'],
    );
  });

  testWidgets('Can replace just a query string', (tester) async {
    final key = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: Container(key: key)),
      }),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(
      await recordUrlChanges(() async {
        delegate.replace('?query=string');
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/?query=string'],
    );

    expect(
      RouteData.of(key.currentContext!).queryParameters['query'],
      'string',
    );
  });

  testWidgets('Can change query string and then go back', (tester) async {
    final key = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (route) => MaterialPage<void>(
                child: Scaffold(
                  body: Text(
                    'Query: ' + (route.queryParameters['q'] ?? ''),
                    key: key,
                  ),
                ),
              ),
          '/two': (_) => MaterialPage<void>(child: Scaffold(appBar: AppBar())),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(
      await recordUrlChanges(() async {
        delegate.push('?q=string');
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/?q=string'],
    );

    expect(find.text('Query: string'), findsOneWidget);
    expect(RouteData.of(key.currentContext!).queryParameters['q'], 'string');

    expect(
      await recordUrlChanges(() async {
        delegate.push('/two');
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/two'],
    );

    expect(
      await recordUrlChanges(() async {
        await tester.tap(find.byType(BackButton));
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/?q=string'],
    );

    expect(find.text('Query: string'), findsOneWidget);
    expect(RouteData.of(key.currentContext!).queryParameters['q'], 'string');
  });

  testWidgets('Can change query string and then go back with path ID',
      (tester) async {
    final key = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (route) => const MaterialPageOne(),
          '/:id': (route) => MaterialPage<void>(
                child: Scaffold(
                  body: Text(
                    'Query: ' + (route.queryParameters['q'] ?? ''),
                    key: key,
                  ),
                ),
              ),
          '/:id/two': (_) =>
              MaterialPage<void>(child: Scaffold(appBar: AppBar())),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(
      await recordUrlChanges(() async {
        delegate.push('/id1?q=string');
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/id1?q=string'],
    );

    expect(find.text('Query: string'), findsOneWidget);
    expect(RouteData.of(key.currentContext!).queryParameters['q'], 'string');

    expect(
      await recordUrlChanges(() async {
        delegate.push('two');
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/id1/two'],
    );

    expect(
      await recordUrlChanges(() async {
        await tester.tap(find.byType(BackButton));
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/id1?q=string'],
    );

    expect(find.text('Query: string'), findsOneWidget);
    expect(RouteData.of(key.currentContext!).queryParameters['q'], 'string');
  });

  testWidgets('Can change query string and then go back with path ID',
      (tester) async {
    final key = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (route) => const MaterialPageOne(),
          '/:id': (route) => MaterialPage<void>(
                child: Scaffold(
                  body: Text(
                    'Query: ' + (route.queryParameters['q'] ?? ''),
                    key: key,
                  ),
                ),
              ),
          '/:id/two': (_) =>
              MaterialPage<void>(child: Scaffold(appBar: AppBar())),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(
      await recordUrlChanges(() async {
        delegate.push('/id1?q=string');
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/id1?q=string'],
    );

    expect(find.text('Query: string'), findsOneWidget);
    expect(RouteData.of(key.currentContext!).queryParameters['q'], 'string');

    expect(
      await recordUrlChanges(() async {
        delegate.push('/id2/two');
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/id2/two'],
    );

    expect(
      await recordUrlChanges(() async {
        await tester.tap(find.byType(BackButton));
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/id2'],
    );
  });
}
