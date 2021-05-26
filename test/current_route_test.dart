import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can get current route', (tester) async {
    RouteData? routeOneCurrentRoute;
    RouteData? routeTwoCurrentRoute;

    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(
              child: Builder(builder: (context) {
                routeOneCurrentRoute = Routemaster.of(context).currentRoute;
                return Container();
              }),
            ),
        '/two/:id': (_) => MaterialPage<void>(
              child: Builder(builder: (context) {
                routeTwoCurrentRoute = Routemaster.of(context).currentRoute;
                return Container();
              }),
            ),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(routeOneCurrentRoute!.path, '/');
    expect(routeTwoCurrentRoute, isNull);

    delegate.push('/two/myId?query=param');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(routeOneCurrentRoute!.path, '/two/myId');
    expect(routeOneCurrentRoute!.fullPath, '/two/myId?query=param');
    expect(routeOneCurrentRoute!.queryParameters['query'], 'param');
    expect(routeOneCurrentRoute!.pathParameters['id'], 'myId');
    expect(routeOneCurrentRoute!.pathTemplate, '/two/:id');

    expect(routeTwoCurrentRoute!.path, '/two/myId');
    expect(routeTwoCurrentRoute!.fullPath, '/two/myId?query=param');
    expect(routeTwoCurrentRoute!.queryParameters['query'], 'param');
    expect(routeTwoCurrentRoute!.pathParameters['id'], 'myId');
    expect(routeTwoCurrentRoute!.pathTemplate, '/two/:id');
  });
}
