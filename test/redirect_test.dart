import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can use redirect as a regular page', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => Redirect('/two'),
          '/two': (info) => Guard(
                canNavigate: (info, context) => true,
                builder: () => MaterialPage<void>(child: PageTwo()),
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

    expect(find.byType(PageTwo), findsOneWidget);
    expect(delegate.currentConfiguration!.fullPath, '/two');
  });

  testWidgets('Deals with redirect loop', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => Redirect('/two'),
          '/two': (info) => Redirect('/'),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final dynamic exception = tester.takeException();
    expect(
      exception,
      isInstanceOf<RedirectLoopError>(),
    );
    expect(
      exception.toString(),
      """Routemaster is stuck in an endless redirect loop:

  * '/' redirected to '/two'
  * '/two' redirected to '/'

This is an error in your routing map.""",
    );
  });

  testWidgets('Can combine redirect and guard', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => Guard(
                canNavigate: (_, __) => true,
                builder: () => Redirect('/two'),
              ),
          '/two': (info) => MaterialPage<void>(child: PageTwo()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageTwo), findsOneWidget);
    expect(delegate.currentConfiguration!.fullPath, '/two');
  });

  testWidgets('Redirect createRoute throws', (tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          expect(
            () => Redirect('/').createRoute(context),
            throwsA(isA<UnimplementedError>()),
          );
          return SizedBox();
        },
      ),
    );
  });
}
