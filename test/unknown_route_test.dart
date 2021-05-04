import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('By default unknown route shows simple 404 page', (tester) async {
    final delegate = RoutemasterDelegate(
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

    expect(find.byType(DefaultUnknownRoutePage), findsOneWidget);
    expect(find.text("Page '/unknown/nonsense' wasn't found."), findsOneWidget);
  });

  testWidgets('Can show 404 page', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        onUnknownRoute: (_) {
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

    expect(
      await recordUrlChanges(() async {
        delegate.push('/unknown/nonsense');
        await tester.pump();
        await tester.pump(Duration(seconds: 1));

        expect(find.byType(NotFoundPage), findsOneWidget);
      }),
      ['/unknown/nonsense'],
    );
  });

  testWidgets('Can redirect to 404 page', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        onUnknownRoute: (path) => Redirect('/not-found'),
        routes: {
          '/': (_) => MaterialPage<void>(child: PageOne()),
          '/not-found': (_) => MaterialPage<void>(child: NotFoundPage()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(
      await recordUrlChanges(() async {
        delegate.push('/unknown/nonsense');
        await tester.pump();
        await tester.pump(Duration(seconds: 1));

        expect(find.byType(NotFoundPage), findsOneWidget);
      }),
      ['/not-found'],
    );
  });

  testWidgets('Can redirect to 404 stack', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        onUnknownRoute: (path) => Redirect('/not-found/sub-page'),
        routes: {
          '/': (_) => MaterialPage<void>(child: PageOne()),
          '/not-found': (_) => MaterialPage<void>(child: PageTwo()),
          '/not-found/sub-page': (_) =>
              MaterialPage<void>(child: NotFoundPage()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(
      await recordUrlChanges(() async {
        delegate.push('/unknown/nonsense');
        await tester.pump();
        await tester.pump(Duration(seconds: 1));

        expect(find.byType(NotFoundPage), findsOneWidget);
      }),
      ['/not-found/sub-page'],
    );

    expect(
      await recordUrlChanges(() async {
        await delegate.popRoute();
        await tester.pump();
        await tester.pump(Duration(seconds: 1));
        expect(find.byType(PageTwo), findsOneWidget);
      }),
      ['/not-found'],
    );
  });
}

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
