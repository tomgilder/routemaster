import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/route_dart.dart';

import 'helpers.dart';

void main() {
  testWidgets('Can use custom navigator', (tester) async {
    final key = Key('custom');
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPageOne(),
          '/two': (_) => MaterialPageTwo(),
        },
      ),
      builder: (context, pages, onPopPage, navigatorKey) {
        return Container(
          key: key,
          child: Navigator(
            pages: pages,
            onPopPage: onPopPage,
            key: navigatorKey,
          ),
        );
      },
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byKey(key), findsOneWidget);
  });

  testWidgets('Can set system URL', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(
            routes: {
              '/': (_) => MaterialPageOne(),
              '/two': (_) => MaterialPageTwo(),
            },
          ),
        ),
      ),
    );

    await setSystemUrl('/two');
    await tester.pump();
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('currentPath is set immediately', (tester) async {
    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(
            routes: {'/': (_) => MaterialPage<void>(child: SizedBox(key: key))},
          ),
        ),
      ),
    );

    expect(Routemaster.of(key.currentContext!).currentPath, '/');
  });

  testWidgets('Non-default currentPath is set immediately', (tester) async {
    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(location: '/two'),
        ),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(
            routes: {
              '/': (_) => MaterialPage<void>(child: SizedBox()),
              '/two': (_) => MaterialPage<void>(child: SizedBox(key: key)),
            },
          ),
        ),
      ),
    );

    expect(Routemaster.of(key.currentContext!).currentPath, '/two');
  });

  test('Throws after dispose', () {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {},
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
}
