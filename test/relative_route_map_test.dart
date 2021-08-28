import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';

import 'helpers.dart';

void main() {
  test('Can get relative routes', () {
    final relativeMap = RelativeRouteMap(routes: {
      'one': (_) => const MaterialPageOne(),
      'one/two': (_) => const MaterialPageTwo(),
      'one/two/three': (_) => const MaterialPageThree(),
    });

    final result = relativeMap.getAll(
      path: 'one/two/three',
      parentPath: '/base',
    );
    expect(result!.length, 3);
  });

  test('Can get relative routes 2 times', () {
    final relativeMap = RelativeRouteMap(routes: {
      'one': (_) => const MaterialPageOne(),
      'one/two': (_) => const MaterialPageTwo(),
      'one/two/three': (_) => const MaterialPageThree(),
    });

    final result = relativeMap.getAll(
      path: 'one/two/three/one/two/three',
      parentPath: '/base',
    );
    expect(result!.length, 6);

    expect(result[0].pathSegment, '/base/one');
    expect(result[1].pathSegment, '/base/one/two');
    expect(result[2].pathSegment, '/base/one/two/three');
    expect(result[3].pathSegment, '/base/one/two/three/one');
    expect(result[4].pathSegment, '/base/one/two/three/one/two');
    expect(result[5].pathSegment, '/base/one/two/three/one/two/three');
  });

  test('Can get relative routes 3 times', () {
    final relativeMap = RelativeRouteMap(routes: {
      'one': (_) => const MaterialPageOne(),
      'one/two': (_) => const MaterialPageTwo(),
      'one/two/three': (_) => const MaterialPageThree(),
    });

    final result = relativeMap.getAll(
      path: 'one/two/three/one/two/three/one/two/three',
      parentPath: '/base',
    );
    expect(result!.length, 9);

    expect(result[0].pathSegment, '/base/one');
    expect(result[1].pathSegment, '/base/one/two');
    expect(result[2].pathSegment, '/base/one/two/three');
    expect(result[3].pathSegment, '/base/one/two/three/one');
    expect(result[4].pathSegment, '/base/one/two/three/one/two');
    expect(result[5].pathSegment, '/base/one/two/three/one/two/three');
    expect(result[6].pathSegment, '/base/one/two/three/one/two/three/one');
    expect(result[7].pathSegment, '/base/one/two/three/one/two/three/one/two');
    expect(
      result[8].pathSegment,
      '/base/one/two/three/one/two/three/one/two/three',
    );
  });

  test('Can get relative routes without parent path', () {
    final relativeMap = RelativeRouteMap(routes: {
      'one': (_) => const MaterialPageOne(),
      'one/two': (_) => const MaterialPageTwo(),
      'one/two/three': (_) => const MaterialPageThree(),
    });

    final result = relativeMap.getAll(
      path: 'one/two/three',
      parentPath: null,
    );
    expect(result!.length, 3);
  });

  test('Can get relative routes without parent path with initial slash', () {
    final relativeMap = RelativeRouteMap(routes: {
      'one': (_) => const MaterialPageOne(),
      'one/two': (_) => const MaterialPageTwo(),
      'one/two/three': (_) => const MaterialPageThree(),
    });

    final result = relativeMap.getAll(
      path: '/one/two/three',
      parentPath: null,
    );
    expect(result!.length, 3);
  });

  testWidgets('Can combine wildcards and relative routes', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/feed': (_) => const MaterialPageOne(),
          '/*': (_) {
            return RelativeRouteMap(
              routes: {
                'one': (_) => const MaterialPageOne(),
                'one/two': (_) => const MaterialPageTwo(),
                'one/two/three': (_) => const MaterialPageThree(),
              },
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

    delegate.push('/feed/one/two');
  });

  testWidgets('Can combine root wildcard and relative routes', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/*': (_) {
            return RelativeRouteMap(
              routes: {
                'one': (_) => const MaterialPageOne(),
                'one/two': (_) => const MaterialPageTwo(),
                'one/two/three': (_) => const MaterialPageThree(),
              },
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

    delegate.push('/one/two');
  });

  testWidgets('Can combine unknown route with relative routes', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
        },
        onUnknownRoute: (route) {
          return RelativeRouteMap(
            routes: {
              'one': (_) => const MaterialPageOne(),
              'one/two': (_) => const MaterialPageTwo(),
              'one/two/three': (_) => const MaterialPageThree(),
            },
          );
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/one/two');
  });
}
