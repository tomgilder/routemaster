import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can use navigatorKey to navigate', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    final delegate = RoutemasterDelegate(
      navigatorKey: navigatorKey,
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (_) => const MaterialPageTwo(),
        },
      ),
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
    expect(find.byType(PageTwo), findsOneWidget);

    navigatorKey.currentState!.pop();
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageTwo), findsNothing);
  });

  testWidgets('Can use navigatorKey.currentContext', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    final delegate = RoutemasterDelegate(
      navigatorKey: navigatorKey,
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (_) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final routemaster = Routemaster.of(navigatorKey.currentContext!);
    expect(routemaster, isNotNull);
  });
}
