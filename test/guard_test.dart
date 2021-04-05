import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Guard can return a different page', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => Guard(
                validate: (info, context) => false,
                onValidationFailed: (info, context) {
                  return MaterialPage<void>(child: NotFoundPage());
                },
                child: MaterialPage<void>(child: PageOne()),
              ),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
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
                validate: (info, context) => false,
                onValidationFailed: (info, context) => Redirect('/page-two'),
                child: MaterialPage<void>(child: PageOne()),
              ),
          '/page-two': (info) => MaterialPage<void>(child: PageTwo()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
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
        onUnknownRoute: (route, context) => MaterialPage<void>(
          child: NotFoundPage(),
        ),
        routes: {
          '/': (info) => Guard(
                validate: (info, context) => false,
                child: MaterialPage<void>(child: PageOne()),
              ),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
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
        onUnknownRoute: (route, context) => Redirect('/page-two'),
        routes: {
          '/': (info) => Guard(
                validate: (info, context) => false,
                child: MaterialPage<void>(child: PageOne()),
              ),
          '/page-two': (info) => MaterialPage<void>(child: PageTwo()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
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
                validate: (info, context) => true,
                child: MaterialPage<void>(child: PageOne()),
              ),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
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
          '/': (_) => MaterialPage<void>(child: PageOne()),
          '/:id': (_) => Guard(
                validate: (info, context) {
                  expect(info.path, '/123?query=string');
                  expect(info.pathParameters, {'id': '123'});
                  expect(info.queryParameters, {'query': 'string'});
                  expect(context, builderContext);
                  validateWasCalled = true;
                  return false;
                },
                onValidationFailed: (info, context) {
                  expect(info.path, '/123?query=string');
                  expect(info.pathParameters, {'id': '123'});
                  expect(info.queryParameters, {'query': 'string'});
                  expect(context, builderContext);
                  onValidationFailedWasCalled = true;
                  return Redirect('/');
                },
                child: MaterialPage<void>(child: PageOne()),
              ),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation:
              RouteInformation(location: '/123?query=string'),
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
                validate: (_, __) => true,
                child: Guard(
                  validate: (_, __) => true,
                  child: MaterialPage<void>(child: PageOne()),
                ),
              ),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageOne), findsOneWidget);
  });
}
