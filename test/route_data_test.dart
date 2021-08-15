import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';
import 'dart:convert';

MaterialPage<void> builder(RouteData info) {
  return MaterialPage<void>(child: Container());
}

void main() {
  test('Provides correct path without query string', () {
    final data = RouteData(
      '/path',
      pathParameters: {},
      pathTemplate: '/template',
      isReplacement: false,
      requestSource: RequestSource.system,
    );

    expect(data.path, '/path');
    expect(data.fullPath, '/path');
  });

  test('Provides correct path with query string', () {
    final data = RouteData(
      '/path?hello=world',
      pathParameters: {},
      pathTemplate: '/template',
      isReplacement: false,
      requestSource: RequestSource.system,
    );

    expect(data.path, '/path');
    expect(data.fullPath, '/path?hello=world');
  });

  test('Route info with different paths are not equal', () {
    final one = RouteData(
      '/one/two',
      pathParameters: {},
      pathTemplate: '/template',
      isReplacement: false,
      requestSource: RequestSource.system,
    );
    final two = RouteData(
      '/one',
      pathParameters: {},
      pathTemplate: '/template',
      isReplacement: false,
      requestSource: RequestSource.system,
    );

    expect(one == two, isFalse);
    expect(one.hashCode == two.hashCode, isFalse);
  });

  test('Route info with same paths are equal', () {
    final one = RouteData(
      '/',
      pathParameters: {},
      pathTemplate: '/',
      isReplacement: false,
      requestSource: RequestSource.system,
    );
    final two = RouteData(
      '/',
      pathParameters: {},
      pathTemplate: '/',
      isReplacement: false,
      requestSource: RequestSource.system,
    );

    expect(one == two, isTrue);
    expect(one.hashCode == two.hashCode, isTrue);
  });

  test('Route info with different query strings are not equal', () {
    final one = RouteData(
      '/?a=b',
      pathParameters: {},
      pathTemplate: '/',
      isReplacement: false,
      requestSource: RequestSource.system,
    );
    final two = RouteData(
      '/',
      pathParameters: {},
      pathTemplate: '/',
      isReplacement: false,
      requestSource: RequestSource.system,
    );

    expect(one == two, isFalse);
    expect(one.hashCode == two.hashCode, isFalse);
  });

  test('Route info with same query strings are equal', () {
    final one = RouteData(
      '/?a=b',
      pathParameters: {},
      pathTemplate: '/',
      isReplacement: false,
      requestSource: RequestSource.system,
    );
    final two = RouteData(
      '/?a=b',
      pathParameters: {},
      pathTemplate: '/',
      isReplacement: false,
      requestSource: RequestSource.system,
    );

    expect(one == two, isTrue);
    expect(one.hashCode == two.hashCode, isTrue);
  });

  test('Route info with same path params are equal', () {
    final one = RouteData(
      '/',
      pathTemplate: '/',
      pathParameters: {'a': 'b'},
      isReplacement: false,
      requestSource: RequestSource.system,
    );
    final two = RouteData(
      '/',
      pathParameters: {'a': 'b'},
      pathTemplate: '/',
      isReplacement: false,
      requestSource: RequestSource.system,
    );

    expect(one == two, isTrue);
    expect(one.hashCode == two.hashCode, isTrue);
  });

  test('RouteData.toString() is correct', () {
    expect(
      RouteData('/', pathTemplate: '').toString(),
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
    expect(page2RouteData.requestSource, RequestSource.internal);

    final currentRoute = Routemaster.of(pageKey2.currentContext!).currentRoute;
    expect(currentRoute.path, '/two/myId');
    expect(currentRoute.fullPath, '/two/myId?query=param');
    expect(currentRoute.pathTemplate, '/two/:id');
    expect(currentRoute.pathParameters['id'], 'myId');
    expect(currentRoute.queryParameters['query'], 'param');
    expect(currentRoute.requestSource, RequestSource.internal);
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

  test('Can serialize route data', () {
    final routeInfo1 = RouteData(
      '/public/_private',
      pathParameters: {},
      isReplacement: true,
      pathTemplate: '/public/_private',
      requestSource: RequestSource.system,
    ).toRouteInformation();

    final state1 = routeInfo1.state as Map;
    expect(routeInfo1.location, '/public');
    expect(state1['internalPath'], '/public/_private');
    expect(state1['isReplacement'], true);
    expect(state1['pathParameters'], <String, String>{});
    expect(state1['requestSource'], 'RequestSource.system');

    final routeInfo2 = RouteData(
      '/public/_private?hello=world',
      pathParameters: {},
      isReplacement: false,
      pathTemplate: '/public/_private',
      requestSource: RequestSource.internal,
    ).toRouteInformation();

    final state2 = routeInfo2.state as Map;
    expect(routeInfo2.location, '/public');
    expect(state2['internalPath'], '/public/_private?hello=world');
    expect(state2['isReplacement'], false);
    expect(state2['pathParameters'], <String, String>{});
    expect(state2['requestSource'], 'RequestSource.internal');

    final routeInfo3 = RouteData(
      '/product/1',
      pathParameters: {'_id': '1'},
      isReplacement: false,
      pathTemplate: '/product/_id',
      requestSource: RequestSource.internal,
    ).toRouteInformation();

    final state3 = routeInfo3.state as Map;
    expect(routeInfo3.location, '/product');
    expect(state3['internalPath'], '/product/1');
    expect(state3['pathParameters'], <String, String>{'_id': '1'});
  });

  test('Can deserialize route data', () {
    final routeData = RouteData.fromRouteInformation(const RouteInformation(
      location: '/public',
      state: {
        'pathTemplate': '/public/_private',
        'internalPath': '/public/_private',
        'isReplacement': true,
        'requestSource': 'RequestSource.internal',
        'pathParameters': <String, String>{},
      },
    ));

    expect(routeData.publicPath, '/public');
    expect(routeData.fullPath, '/public/_private');
    expect(routeData.pathTemplate, '/public/_private');
    expect(routeData.isReplacement, true);
    expect(routeData.requestSource, RequestSource.internal);
    expect(routeData.queryParameters, isEmpty);

    final routeData2 = RouteData.fromRouteInformation(const RouteInformation(
      location: '/public',
      state: {
        'pathTemplate': '/public/_private',
        'internalPath': '/public/_private?hello=world',
        'isReplacement': false,
        'requestSource': 'RequestSource.system',
        'pathParameters': <String, String>{},
      },
    ));

    expect(routeData2.publicPath, '/public');
    expect(routeData2.fullPath, '/public/_private?hello=world');
    expect(routeData2.pathTemplate, '/public/_private');
    expect(routeData2.isReplacement, false);
    expect(routeData2.requestSource, RequestSource.system);
    expect(routeData2.queryParameters['hello'], 'world');

    final routeData3 = RouteData.fromRouteInformation(const RouteInformation(
      location: '/product/1',
      state: {
        'pathTemplate': '/product/:_id',
        'internalPath': '/product/1',
        'isReplacement': false,
        'requestSource': 'RequestSource.system',
        'pathParameters': {'_id': '1'}
      },
    ));

    expect(routeData3.pathTemplate, '/product/:_id');
    expect(routeData3.publicPath, '/product');
    expect(routeData3.fullPath, '/product/1');
    expect(routeData3.pathParameters['_id'], '1');
  });

  test('Can deserialize route from JSON', () {
    const jsonStr = '''
    {
        "pathTemplate": "/public/_private/hello",
        "internalPath": "/public/_private/hello",
        "isReplacement": true,
        "requestSource": "RequestSource.internal",
        "pathParameters": {"path": "param"}
      }
    ''';

    final routeData = RouteData.fromRouteInformation(RouteInformation(
      location: '/public',
      state: json.decode(jsonStr),
    ));

    expect(routeData.publicPath, '/public');
    expect(routeData.fullPath, '/public/_private/hello');
    expect(routeData.pathTemplate, '/public/_private/hello');
    expect(routeData.isReplacement, true);
    expect(routeData.requestSource, RequestSource.internal);
    expect(routeData.pathParameters, {'path': 'param'});
  });
}
