import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/route_dart.dart';
import 'helpers.dart';

void main() {
  testWidgets("Can push and pop a page", (tester) async {
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (_) => MaterialPage<void>(child: PageTwo()),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.pushNamed('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets("Can push and pop a page with query string", (tester) async {
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (_) => MaterialPage<void>(child: PageTwo()),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.pushNamed('two?query=string');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two?query=string'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);
  });
}
