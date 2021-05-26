import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can get return value via Navigator.pop()', (tester) async {
    final key = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (_) => MaterialPage<void>(child: Container(key: key)),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final result = delegate.push<String>('/two');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    Navigator.of(key.currentContext!).pop('result');
    expect(await result.result, 'result');
  });

  testWidgets('Can get null return value via Navigator.pop()', (tester) async {
    final key = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (_) => MaterialPage<void>(child: Container(key: key)),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final result = delegate.push<String>('/two');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    Navigator.of(key.currentContext!).pop(null);
    expect(await result.result, isNull);
  });

  testWidgets('Can get return value via Routemaster.pop()', (tester) async {
    final key = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (_) => MaterialPage<void>(child: Container(key: key)),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final result = delegate.push<String>('/two');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    await Routemaster.of(key.currentContext!).pop('result');
    expect(await result.result, 'result');
  });

  testWidgets('Can get null return value via Routemaster.pop()',
      (tester) async {
    final key = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (_) => MaterialPage<void>(child: Container(key: key)),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final result = delegate.push<String>('/two');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    await Routemaster.of(key.currentContext!).pop(null);
    expect(await result.result, isNull);
  });

  testWidgets('Can get route when pushing a new page', (tester) async {
    final key = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (_) => MaterialPage<void>(child: Container(key: key)),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final result = delegate.push<String>('/two');
    await tester.pump();
    expect(await result.route, ModalRoute.of(key.currentContext!));
  });

  testWidgets('Can get route when pushing multiple new pages', (tester) async {
    final key = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (_) => const MaterialPageTwo(),
          '/two/three': (_) => MaterialPage<void>(child: Container(key: key)),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final result = delegate.push<String>('/two/three');
    await tester.pump();
    expect(await result.route, ModalRoute.of(key.currentContext!));
  });
}
