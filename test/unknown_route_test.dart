import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('By default unknown route redirects to default route',
      (tester) async {
    final delegate = Routemaster(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: PageOne()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/unknown/nonsense');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets('Can show 404 page', (tester) async {
    final delegate = Routemaster(
      routesBuilder: (_) => RouteMap(
        onUnknownRoute: (_, __, ___) {
          return MaterialPage<void>(child: NotFoundPage());
        },
        routes: {
          '/': (_) => MaterialPage<void>(child: PageOne()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/unknown/nonsense');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(find.byType(NotFoundPage), findsOneWidget);
  });
}

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
