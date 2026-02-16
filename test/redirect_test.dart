import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can use redirect as a regular page', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => const Redirect('/two'),
          '/two': (info) => Guard(
                canNavigate: (info, context) => true,
                builder: () => const MaterialPageTwo(),
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

    expect(find.byType(PageTwo), findsOneWidget);
    expect(delegate.currentConfiguration!.fullPath, '/two');
  });

  testWidgets('Can use transitive redirect', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => const Redirect('/two'),
          '/two': (info) => const Redirect('/tree'),
          '/tree': (info) => Guard(
            canNavigate: (info, context) => true,
            builder: () => const MaterialPageTwo(),
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

    expect(find.byType(PageTwo), findsOneWidget);
    expect(delegate.currentConfiguration!.fullPath, '/tree');
  });

  testWidgets('Deals with redirect loop', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => const Redirect('/two'),
          '/two': (info) => const Redirect('/'),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
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
                builder: () => const Redirect('/two'),
              ),
          '/two': (info) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
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
            () => const Redirect('/').createRoute(context),
            throwsA(isA<UnimplementedError>()),
          );
          return const SizedBox();
        },
      ),
    );
  });

  testWidgets('Redirect path parameters are filled', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => const Redirect('/two/hello/boo'),
          '/two/:id/boo': (info) => const Redirect('/tree/:id'),
          '/tree/:id': (info) => Guard(
            canNavigate: (info, context) => true,
            builder: () => const MaterialPageThree(),
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

    expect(find.byType(PageThree), findsOneWidget);
    expect(delegate.currentConfiguration!.fullPath, '/tree/hello');
  });

  testWidgets('Multiple redirect path parameters are filled', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (info) => const Redirect('/two/hello/123'),
          '/:tab/hello/:id': (info) => const Redirect('/tree/:id/:tab/:id'),
          '/tree/:/two/:id': (info) => const MaterialPageThree(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageThree), findsOneWidget);
    expect(delegate.currentConfiguration!.fullPath, '/tree/123/two/123');
  });
}
