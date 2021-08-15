import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/not_found_page.dart';
import 'helpers.dart';

void main() {
  testWidgets('By default unknown route shows simple 404 page', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/unknown/nonsense');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(DefaultNotFoundPage), findsOneWidget);
    expect(find.text("Page '/unknown/nonsense' wasn't found."), findsOneWidget);
  });

  testWidgets('Can show 404 page', (tester) async {
    await recordUrlChanges((systemUrl) async {
      final delegate = RoutemasterDelegate(
        routesBuilder: (_) => RouteMap(
          onUnknownRoute: (_) {
            return MaterialPage<void>(child: NotFoundPage());
          },
          routes: {
            '/': (_) => const MaterialPageOne(),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      delegate.push('/unknown/nonsense');
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(NotFoundPage), findsOneWidget);

      expect(systemUrl.current, '/unknown/nonsense');
    });
  });

  testWidgets('Can redirect to 404 page', (tester) async {
    await recordUrlChanges((systemUrl) async {
      final delegate = RoutemasterDelegate(
        routesBuilder: (_) => RouteMap(
          onUnknownRoute: (path) => const Redirect('/not-found'),
          routes: {
            '/': (_) => const MaterialPageOne(),
            '/not-found': (_) => MaterialPage<void>(child: NotFoundPage()),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      delegate.push('/unknown/nonsense');
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(NotFoundPage), findsOneWidget);

      expect(systemUrl.current, '/not-found');
    });
  });

  testWidgets('Can redirect to 404 stack', (tester) async {
    await recordUrlChanges((systemUrl) async {
      final delegate = RoutemasterDelegate(
        routesBuilder: (_) => RouteMap(
          onUnknownRoute: (path) => const Redirect('/not-found/sub-page'),
          routes: {
            '/': (_) => const MaterialPageOne(),
            '/not-found': (_) => const MaterialPageTwo(),
            '/not-found/sub-page': (_) =>
                MaterialPage<void>(child: NotFoundPage()),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      delegate.push('/unknown/nonsense');
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(NotFoundPage), findsOneWidget);

      expect(systemUrl.current, '/not-found/sub-page');

      await delegate.popRoute();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(PageTwo), findsOneWidget);

      expect(systemUrl.current, '/not-found');
    });
  });
}

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
