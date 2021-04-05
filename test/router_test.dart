import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';

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
}
