import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/trie_router/trie_router.dart';
import 'helpers.dart';

MaterialPage<void> builder(RouteData info) {
  return MaterialPage<void>(child: Container());
}

void main() {
  test('Provides correct path without query string', () {
    final data = RouteData.fromRouterResult(
      const RouterResult(
        builder: builder,
        pathParameters: {},
        pathSegment: '/path',
        pathTemplate: '/template',
      ),
      Uri.parse('/path'),
      source: NavigationSource.app,
    );

    expect(data.path, '/path');
    expect(data.fullPath, '/path');
  });

  test('Provides correct path with query string', () {
    final data = RouteData.fromRouterResult(
      const RouterResult(
        builder: builder,
        pathParameters: {},
        pathSegment: '/path',
        pathTemplate: '/template',
      ),
      Uri.parse('/path?hello=world'),
      source: NavigationSource.app,
    );

    expect(data.path, '/path');
    expect(data.fullPath, '/path?hello=world');
  });

  test('Route info with different paths are not equal', () {
    final one = RouteData.fromRouterResult(
      const RouterResult(
        builder: builder,
        pathParameters: {},
        pathSegment: '/one',
        pathTemplate: '/template',
      ),
      Uri.parse('/one/two'),
      source: NavigationSource.app,
    );
    final two = RouteData.fromRouterResult(
      const RouterResult(
        builder: builder,
        pathParameters: {},
        pathSegment: '/two',
        pathTemplate: '/template',
      ),
      Uri.parse('/one'),
      source: NavigationSource.app,
    );

    expect(one == two, isFalse);
    expect(one.hashCode == two.hashCode, isFalse);
  });

  test('Route info with same paths are equal', () {
    final one = RouteData.fromRouterResult(
      const RouterResult(
        builder: builder,
        pathParameters: {},
        pathSegment: '/',
        pathTemplate: '/',
      ),
      Uri.parse('/'),
      source: NavigationSource.app,
    );
    final two = RouteData.fromRouterResult(
      const RouterResult(
        builder: builder,
        pathParameters: {},
        pathSegment: '/',
        pathTemplate: '/',
      ),
      Uri.parse('/'),
      source: NavigationSource.app,
    );

    expect(one == two, isTrue);
    expect(one.hashCode == two.hashCode, isTrue);
  });

  test('Route info with different query strings are not equal', () {
    final one = RouteData.fromRouterResult(
        const RouterResult(
          builder: builder,
          pathParameters: {},
          pathSegment: '/',
          pathTemplate: '/',
        ),
        Uri.parse('/?a=b'));
    final two = RouteData.fromRouterResult(
        const RouterResult(
          builder: builder,
          pathParameters: {},
          pathSegment: '/',
          pathTemplate: '/',
        ),
        Uri.parse('/'));

    expect(one == two, isFalse);
    expect(one.hashCode == two.hashCode, isFalse);
  });

  test('Route info with same query strings are equal', () {
    final one = RouteData.fromRouterResult(
        const RouterResult(
          builder: builder,
          pathParameters: {},
          pathSegment: '/',
          pathTemplate: '/',
        ),
        Uri.parse('/?a=b'));
    final two = RouteData.fromRouterResult(
        const RouterResult(
          builder: builder,
          pathParameters: {},
          pathSegment: '/',
          pathTemplate: '/',
        ),
        Uri.parse('/?a=b'));

    expect(one == two, isTrue);
    expect(one.hashCode == two.hashCode, isTrue);
  });

  test('Route info with same path params are equal', () {
    final one = RouteData.fromRouterResult(
        const RouterResult(
          builder: builder,
          pathParameters: {'a': 'b'},
          pathSegment: '/',
          pathTemplate: '/',
        ),
        Uri.parse('/'));
    final two = RouteData.fromRouterResult(
        const RouterResult(
          builder: builder,
          pathParameters: {'a': 'b'},
          pathSegment: '/',
          pathTemplate: '/',
        ),
        Uri.parse('/'));

    expect(one == two, isTrue);
    expect(one.hashCode == two.hashCode, isTrue);
  });

  test('RouteData.toString() is correct', () {
    expect(
      RouteData('/', source: NavigationSource.app).toString(),
      '/',
    );
  });

  testWidgets('Can get RouteData from context', (tester) async {
    final pageKey1 = GlobalKey();
    final pageKey2 = GlobalKey();

    final delegate = RoutemasterDelegate(
      routesBuilder: (context) {
        return RouteMap(
          routes: {
            '/': (_) => MaterialPage<void>(child: Container(key: pageKey1)),
            '/two/:id': (_) => MaterialPage<void>(
                  child: Container(key: pageKey2),
                ),
          },
        );
      },
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(RouteData.of(pageKey1.currentContext!).fullPath, '/');
    expect(RouteData.of(pageKey1.currentContext!).pathTemplate, '/');

    delegate.push('/two/myId?query=param');
    await tester.pump();

    final page2RouteData = RouteData.of(pageKey2.currentContext!);
    expect(page2RouteData.path, '/two/myId');
    expect(page2RouteData.fullPath, '/two/myId?query=param');
    expect(page2RouteData.pathTemplate, '/two/:id');
    expect(page2RouteData.pathParameters['id'], 'myId');
    expect(page2RouteData.queryParameters['query'], 'param');

    final currentRoute = Routemaster.of(pageKey2.currentContext!).currentRoute;
    expect(currentRoute.path, '/two/myId');
    expect(currentRoute.fullPath, '/two/myId?query=param');
    expect(currentRoute.pathTemplate, '/two/:id');
    expect(currentRoute.pathParameters['id'], 'myId');
    expect(currentRoute.queryParameters['query'], 'param');
  });

  testWidgets('Can get RouteData from context when navigating back',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (context) {
        return RouteMap(
          routes: {
            '/': (_) => MaterialPage<void>(child: Container()),
            '/two': (_) => MaterialPage<void>(
                  child: Builder(
                    builder: (context) {
                      RouteData.of(context);
                      return Container();
                    },
                  ),
                ),
          },
        );
      },
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    // Simulates navigating back in a web browser
    await setSystemUrl('/');
    await tester.pumpAndSettle();
  });

  testWidgets('Asserts if unable to get modal route', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(Builder(builder: (c) {
      context = c;
      return const SizedBox();
    }));

    expect(
      () => RouteData.of(context),
      throwsA(predicate((e) =>
          e is AssertionError && e.message == "Couldn't get modal route")),
    );
  });
}
