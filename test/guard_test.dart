import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/not_found_page.dart';
import 'helpers.dart';

void main() {
  testWidgets('Guard can return a different page', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => Guard(
                canNavigate: (info, context) => false,
                onNavigationFailed: (info, context) {
                  return MaterialPage<void>(child: NotFoundPage());
                },
                builder: () => const MaterialPage<void>(child: PageOne()),
              ),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(NotFoundPage), findsOneWidget);
  });

  testWidgets('Guard can redirect to a new page', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => Guard(
                canNavigate: (info, context) => false,
                onNavigationFailed: (info, context) =>
                    const Redirect('/page-two'),
                builder: () => const MaterialPage<void>(child: PageOne()),
              ),
          '/page-two': (info) => const MaterialPage<void>(child: PageTwo()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Guard can fall back to onUnknownRoute with new page',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        onUnknownRoute: (route) => MaterialPage<void>(child: NotFoundPage()),
        routes: {
          '/': (info) => Guard(
                canNavigate: (info, context) => false,
                builder: () => const MaterialPage<void>(child: PageOne()),
              ),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(NotFoundPage), findsOneWidget);
  });

  testWidgets('Guard can fall back to onUnknownRoute with redirect',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        onUnknownRoute: (route) => const Redirect('/page-two'),
        routes: {
          '/': (info) => Guard(
                canNavigate: (info, context) => false,
                builder: () => const MaterialPage<void>(child: PageOne()),
              ),
          '/page-two': (info) => const MaterialPage<void>(child: PageTwo()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Guard does nothing when validate returns true', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => Guard(
                canNavigate: (info, context) => true,
                builder: () => const MaterialPage<void>(child: PageOne()),
              ),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets('Guard gets correct parameters', (tester) async {
    var validateWasCalled = false;
    var onValidationFailedWasCalled = false;

    late RoutemasterDelegate delegate;
    delegate = RoutemasterDelegate(
      routesBuilder: (builderContext) => RouteMap(
        routes: {
          '/': (_) => const MaterialPage<void>(child: PageOne()),
          '/:id': (_) => Guard(
                canNavigate: (info, context) {
                  expect(info.path, '/123');
                  expect(info.fullPath, '/123?query=string');
                  expect(info.pathParameters, {'id': '123'});
                  expect(info.queryParameters, {'query': 'string'});
                  validateWasCalled = true;
                  return false;
                },
                onNavigationFailed: (info, context) {
                  expect(info.path, '/123');
                  expect(info.fullPath, '/123?query=string');
                  expect(info.pathParameters, {'id': '123'});
                  expect(info.queryParameters, {'query': 'string'});
                  onValidationFailedWasCalled = true;
                  return const Redirect('/');
                },
                builder: () => const MaterialPage<void>(child: PageOne()),
              ),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation:
              const RouteInformation(location: '/123?query=string'),
        ),
        routerDelegate: delegate,
      ),
    );

    // Ensure callbacks completed
    expect(validateWasCalled, isTrue);
    expect(onValidationFailedWasCalled, isTrue);
  });

  testWidgets('Can use multiple guards', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => Guard(
                canNavigate: (_, __) => true,
                builder: () => Guard(
                  canNavigate: (_, __) => true,
                  builder: () => const MaterialPage<void>(child: PageOne()),
                ),
              ),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageOne), findsOneWidget);
  });

  test('Guard createRoute throws', () {
    final guard = Guard(
      canNavigate: (_, __) => false,
      builder: () => const MaterialPageOne(),
    );

    expect(
      () => guard.createRoute(FakeBuildContext()),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('NotFound createRoute throws', () {
    expect(
      () => const NotFound().createRoute(FakeBuildContext()),
      throwsA(isA<UnsupportedError>()),
    );
  });

  testWidgets('NotFound defaults to DefaultNotFoundPage', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => const NotFound(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(DefaultNotFoundPage), findsOneWidget);
  });

  testWidgets('NotFound shows custom not found page', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        onUnknownRoute: (route) => MaterialPage<void>(child: NotFoundPage()),
        routes: {
          '/': (info) => const NotFound(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(NotFoundPage), findsOneWidget);
  });

  testWidgets('NotFound can redirect', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        onUnknownRoute: (route) => const Redirect('/404'),
        routes: {
          '/': (info) => const NotFound(),
          '/404': (info) => MaterialPage<void>(child: NotFoundPage()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(NotFoundPage), findsOneWidget);
  });
}
