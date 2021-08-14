import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/not_found_page.dart';

import 'helpers.dart';

const urls = {
  // Actual, expected
  '/test/_one': '/test',
  '/test/_': '/test',
  '/test/_one/_two': '/test',
  '/test/_/_two': '/test',
  '/test/_one/two': '/test',
  '/test/_/two': '/test',
  '/test/one/_two': '/test/one',
  '/test/one/_': '/test/one',
  '/_': '/',
  '/_test': '/',
  '/_/test': '/',
  '/_one/two': '/',
  '/:_id': '/',
};

void main() {
  for (final mapEntry in urls.entries) {
    testWidgets(
        'Pushed private URL reported to system correctly: ${mapEntry.key}',
        (tester) async {
      await _expectPushedPrivateUrl(tester, mapEntry.key, mapEntry.value);
    });

    testWidgets('Trying to load private URL shows 404: ${mapEntry.key}',
        (tester) async {
      await _expectPrivateUrlNotFound(tester, mapEntry.key);
    });
  }

  testWidgets('Can use query string on pushed private URL', (tester) async {
    await recordUrlChanges((systemUrl) async {
      final delegate = RoutemasterDelegate(
        routesBuilder: (BuildContext context) => RouteMap(
          routes: {
            '/': (routeData) => const MaterialPageOne(),
            '/test/_private': (routeData) {
              return EchoPage(text: routeData.queryParameters['message']);
            },
          },
        ),
      );

      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ));

      delegate.push('/test/_private', queryParameters: {'message': 'hello'});
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.text('hello'), findsOneWidget);

      expect(systemUrl.current, '/test');
    });
  });

  testWidgets("Private URLs don't break route params", (tester) async {
    await recordUrlChanges((systemUrl) async {
      final delegate = RoutemasterDelegate(
        routesBuilder: (BuildContext context) => RouteMap(
          routes: {
            '/': (routeData) => const MaterialPageOne(),
            '/product/:id': (routeData) {
              return EchoPage(text: routeData.pathParameters['id']);
            },
          },
        ),
      );

      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ));

      delegate.push('/product/_myId');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.text('_myId'), findsOneWidget);

      expect(systemUrl.current, '/product/_myId');
    });
  });

  testWidgets('Can have private path parameter', (tester) async {
    await recordUrlChanges((systemUrl) async {
      final delegate = RoutemasterDelegate(
        routesBuilder: (BuildContext context) => RouteMap(
          routes: {
            '/': (routeData) => const MaterialPageOne(),
            '/product/:_id': (routeData) {
              return EchoPage(text: routeData.pathParameters['_id']);
            },
          },
        ),
      );

      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ));

      delegate.push('/product/myId');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.text('myId'), findsOneWidget);

      expect(systemUrl.current, '/product');
    });
  });

  testWidgets('Shows path with underscore in middle', (tester) async {
    await recordUrlChanges((systemUrl) async {
      final delegate = RoutemasterDelegate(
        routesBuilder: (BuildContext context) => RouteMap(
          routes: {
            '/': (routeData) => const MaterialPageOne(),
            '/test_ing': (routeData) => const MaterialPageTwo(),
          },
        ),
      );

      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ));

      await setSystemUrl('/test_ing');
      await tester.pump();
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(PageTwo), findsOneWidget);

      await delegate.pop();
      await tester.pump();
      await tester.pump(kTransitionDuration);

      delegate.push('/test_ing');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(PageTwo), findsOneWidget);

      expect(systemUrl.current, '/test_ing');
    });
  });

  testWidgets('Shows 404 page with unknown private url', (tester) async {
    await recordUrlChanges((systemUrl) async {
      final delegate = RoutemasterDelegate(
        routesBuilder: (_) => RouteMap(
          routes: {'/': (_) => const MaterialPageOne()},
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      delegate.push('/test/_private');
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(DefaultNotFoundPage), findsOneWidget);
      expect(
        find.text("Page '/test/_private' wasn't found."),
        findsOneWidget,
      );

      expect(systemUrl.current, '/test/_private');
    });
  });

  test('parseRouteInformation returns correct data for private path', () async {
    const parser = RoutemasterParser();
    final routeData = await parser.parseRouteInformation(
      const RouteInformation(
        location: '/public-path',
        state: {
          'internalPath': '/internal-path',
          'pathTemplate': '/internal-path',
          'isReplacement': true,
          'requestSource': 'RequestSource.internal',
          'pathParameters': <String, String>{},
        },
      ),
    );
    expect(routeData.fullPath, '/internal-path');
  });
}

Future<void> _expectPushedPrivateUrl(
    WidgetTester tester, String actual, String expected) async {
  await recordUrlChanges((systemUrl) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (BuildContext context) => RouteMap(
        routes: {
          '/': (routeData) => const MaterialPageOne(),
          actual: (routeData) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(MaterialApp.router(
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: delegate,
    ));

    delegate.push(actual);
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(systemUrl.current, expected);
  });
}

Future<void> _expectPrivateUrlNotFound(WidgetTester tester, String url) async {
  final delegate = RoutemasterDelegate(
    routesBuilder: (BuildContext context) => RouteMap(
      routes: {
        '/': (routeData) => const MaterialPageOne(),
        url: (routeData) => const MaterialPageTwo(),
      },
    ),
  );

  await tester.pumpWidget(MaterialApp.router(
    routeInformationParser: const RoutemasterParser(),
    routerDelegate: delegate,
  ));

  await setSystemUrl(url);
  await tester.pump();
  await tester.pump();
  await tester.pump(kTransitionDuration);

  expect(
    find.byType(DefaultNotFoundPage),
    findsOneWidget,
    reason: "Not found page not shown with '$url'",
  );
  expect(find.byType(PageTwo), findsNothing);
}
