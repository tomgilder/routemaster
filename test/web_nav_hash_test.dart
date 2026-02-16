@TestOn('browser')
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Replaces URL when redirecting to tabs', (tester) async {
    await recordUrlChanges((systemUrl) async {
      final routes1 = RouteMap(
        routes: {'/': (_) => MaterialPage<void>(child: Container())},
      );

      final routes2 = RouteMap(
        routes: {
          '/': (_) => CupertinoTabPage(
            child: Container(),
            paths: const ['/one', '/two'],
          ),
          '/one': (_) => const MaterialPageOne(),
          '/two': (_) => const MaterialPageTwo(),
        },
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: RoutemasterDelegate(routesBuilder: (_) => routes1),
          routeInformationParser: const RoutemasterParser(),
        ),
      );
      expect(systemUrl.current, '/');

      final delegate2 = RoutemasterDelegate(routesBuilder: (_) => routes2);
      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: delegate2,
          routeInformationParser: const RoutemasterParser(),
        ),
      );
      await tester.pump();
      expect(delegate2.currentConfiguration!.fullPath, '/one');
      expect(systemUrl.current, '/one');
    });
  });
}
