import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/not_found_page.dart';
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
      () => delegate.setInitialRoutePath(RouteData('', pathTemplate: '')),
      throwsAssertionError,
    );
    expect(
      () => delegate.setNewRoutePath(RouteData('path', pathTemplate: '')),
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
    await recordUrlChanges((systemUrl) async {
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

      delegate.push('?query=string');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(systemUrl.current, '/?query=string');
    });
  });

  testWidgets('Can replace just a query string', (tester) async {
    await recordUrlChanges((systemUrl) async {
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

      delegate.replace('?query=string');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(systemUrl.current, '/?query=string');

      expect(
        RouteData.of(key.currentContext!).queryParameters['query'],
        'string',
      );
    });
  });

  testWidgets('Can change query string and then go back', (tester) async {
    await recordUrlChanges((systemUrl) async {
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
            '/two': (_) =>
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

      delegate.push('?q=string');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(systemUrl.current, '/?q=string');

      expect(find.text('Query: string'), findsOneWidget);
      expect(RouteData.of(key.currentContext!).queryParameters['q'], 'string');

      delegate.push('/two');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(systemUrl.current, '/two');

      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(systemUrl.current, '/?q=string');

      expect(find.text('Query: string'), findsOneWidget);
      expect(RouteData.of(key.currentContext!).queryParameters['q'], 'string');
    });
  });

  testWidgets('Can change query string and then go back with path ID',
      (tester) async {
    await recordUrlChanges((systemUrl) async {
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

      delegate.push('/id1?q=string');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(systemUrl.current, '/id1?q=string');

      expect(find.text('Query: string'), findsOneWidget);
      expect(RouteData.of(key.currentContext!).queryParameters['q'], 'string');

      delegate.push('two');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(systemUrl.current, '/id1/two');

      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(systemUrl.current, '/id1?q=string');

      expect(find.text('Query: string'), findsOneWidget);
      expect(RouteData.of(key.currentContext!).queryParameters['q'], 'string');
    });
  });

  testWidgets('Can change query string and then go back with path ID',
      (tester) async {
    await recordUrlChanges((systemUrl) async {
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

      delegate.push('/id1?q=string');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(systemUrl.current, '/id1?q=string');

      expect(find.text('Query: string'), findsOneWidget);
      expect(RouteData.of(key.currentContext!).queryParameters['q'], 'string');

      delegate.push('/id2/two');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(systemUrl.current, '/id2/two');

      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(systemUrl.current, '/id2');
    });
  });

  testWidgets('Query parameters update when system URL set', (tester) async {
    late Map<String, String> builderQueryParameters;
    late Map<String, String> contextQueryParameters;

    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (route) {
            builderQueryParameters = route.queryParameters;

            return MaterialPage<void>(
              child: Builder(builder: (context) {
                contextQueryParameters = RouteData.of(context).queryParameters;
                return const SizedBox();
              }),
            );
          },
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/two?query=1');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(builderQueryParameters['query'], '1');
    expect(contextQueryParameters['query'], '1');

    await setSystemUrl('/two?query=2');
    await tester.pump();
    expect(builderQueryParameters['query'], '2');
    expect(contextQueryParameters['query'], '2');

    await setSystemUrl('/two?query=3');
    await tester.pump();

    expect(builderQueryParameters['query'], '3');
    expect(contextQueryParameters['query'], '3');
  });

  testWidgets('Page gets rebuilt when query parameters update', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (route) {
            return MaterialPage<void>(
              child: QueryParamEcho(
                query: route.queryParameters['query'] ?? '',
              ),
            );
          },
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/two?query=1');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);

    await setSystemUrl('/two?query=2');
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await setSystemUrl('/two?query=3');
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('Can push query string in both URL and map', (tester) async {
    late Map<String, String> builderQueryParameters;
    late Map<String, String> contextQueryParameters;

    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (route) {
            builderQueryParameters = route.queryParameters;

            return MaterialPage<void>(
              child: Builder(builder: (context) {
                contextQueryParameters = RouteData.of(context).queryParameters;
                return const SizedBox();
              }),
            );
          },
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/two?query=1', queryParameters: {'query2': '2'});
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(builderQueryParameters['query'], '1');
    expect(contextQueryParameters['query'], '1');
    expect(builderQueryParameters['query2'], '2');
    expect(contextQueryParameters['query2'], '2');
  });

  testWidgets('Unknown startup URL shows not found page', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: const RouteInformation(location: '/404'),
        ),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(
            routes: {'/': (_) => const MaterialPageOne()},
          ),
        ),
      ),
    );

    expect(find.byType(DefaultNotFoundPage), findsOneWidget);
  });

  testWidgets(
      "Doesn't rebuild page hierarchy when nested page route pushed on top",
      (tester) async {
    final queryParamBuilds = <String?>[];

    final delegate = RoutemasterDelegate(
      routesBuilder: (BuildContext context) => RouteMap(
        routes: {
          '/': (routeData) => const Redirect(
                '/one',
                queryParameters: {'query1': 'val1'},
              ),
          '/one': (routeData) {
            queryParamBuilds.add(routeData.queryParameters['query1']);
            return const MaterialPageOne();
          },
          '/one/two': (_) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(MaterialApp.router(
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: delegate,
    ));

    delegate.push('/one/two');
    await tester.pump();

    expect(queryParamBuilds, ['val1']);
  });

  testWidgets('Unknown startup URL redirects to another page', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: const RouteInformation(location: '/404'),
        ),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(
            onUnknownRoute: (_) {
              return const Redirect('/two');
            },
            routes: {
              '/two': (_) {
                return const MaterialPageTwo();
              },
            },
          ),
        ),
      ),
    );

    expect(find.byType(PageTwo), findsOneWidget);
  });

  test('Can use ternary operator in route map', () {
    const id = 0;

    // This just needs to compile to pass
    RouteMap(
      onUnknownRoute: (_) {
        return id == 0 ? const Redirect('/two') : const MaterialPageOne();
      },
      routes: {
        '/two': (_) {
          return id == 0 ? const NotFound() : const MaterialPageOne();
        },
      },
    );
  });

  testWidgets('Asserts when Page not returned from not found', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        onUnknownRoute: (_) => NotAPage(),
        routes: {'/': (_) => const MaterialPageOne()},
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/404');
    await tester.pump();

    final exception = tester.takeException() as AssertionError;
    expect(
      exception.message,
      "Route builders must return a Page object. The route builder for '/404' instead returned an object of type 'NotAPage'.",
    );
  });

  testWidgets('Asserts when Page not returned from builder', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(routes: {'/': (_) => NotAPage()}),
        ),
      ),
    );

    final exception = tester.takeException() as AssertionError;
    expect(
      exception.message,
      "Route builders must return a Page object. The route builder for '/' instead returned an object of type 'NotAPage'.",
    );
  });

  testWidgets('Can push when context has no associated RouteData',
      (tester) async {
    final pageOne = Builder(
      builder: (context) {
        return Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Routemaster.of(context).push('/two');
                    },
                    child: const Text('Push 2'),
                  ),
                );
              }),
            ),
            child: const Text('Push 1'),
          ),
        );
      },
    );

    final delegate = RoutemasterDelegate(
      routesBuilder: (context) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: pageOne),
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

    await tester.tap(find.text('Push 1'));
    await tester.pumpPageTransition();

    await tester.tap(find.text('Push 2'));
    await tester.pumpPageTransition();

    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Can replace when context has no associated RouteData',
      (tester) async {
    final pageOne = Builder(
      builder: (context) {
        return Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Routemaster.of(context).replace('/two');
                    },
                    child: const Text('Replace'),
                  ),
                );
              }),
            ),
            child: const Text('Push'),
          ),
        );
      },
    );

    final delegate = RoutemasterDelegate(
      routesBuilder: (context) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: pageOne),
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

    await tester.tap(find.text('Push'));
    await tester.pumpPageTransition();

    await tester.tap(find.text('Replace'));
    await tester.pumpPageTransition();

    expect(find.byType(PageTwo), findsOneWidget);
  });
}

class QueryParamEcho extends StatelessWidget {
  final String query;

  const QueryParamEcho({required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text(query));
  }
}

class NotAPage extends RouteSettings {}
