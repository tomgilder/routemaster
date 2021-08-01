@TestOn('dart-vm')
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

// These tests don't work if run from Chrome, as they use the browser's
// native navigation functions.

void main() {
  testWidgets('Can push a page via replace()', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => const MaterialPageOne(),
        '/two': (_) => const MaterialPageTwo(),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/', pathTemplate: '/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.replace('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(
        delegate.currentConfiguration, RouteData('/two', pathTemplate: '/two'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Can replace via Routemaster.of()', (tester) async {
    final page1Key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
          return RouteMap(routes: {
            '/': (_) => MaterialPage<void>(child: PageOne(key: page1Key)),
            '/two': (_) => const MaterialPageTwo(),
          });
        }),
      ),
    );

    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    final routemaster = Routemaster.of(page1Key.currentContext!);
    routemaster.replace('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);
  });
}
