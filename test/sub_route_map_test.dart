import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

Future<RoutemasterDelegate> pumpRouteMap(WidgetTester tester, RouteMap map,
    {String path = '/'}) async {
  final delegate = RoutemasterDelegate(
    routesBuilder: (_) => map,
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: delegate,
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: RouteInformation(location: path),
      ),
    ),
  );

  return delegate;
}

void main() {
  testWidgets('Can use root child map without initial slash', (tester) async {
    final delegate = await pumpRouteMap(
      tester,
      RouteMap(routes: {
        '/*': (_) => RouteMap(
              routes: {
                'one': (_) => const MaterialPageOne(),
                'one/two': (_) => const MaterialPageTwo(),
              },
            ),
      }),
      path: '/one/two',
    );

    expect(find.byType(PageTwo), findsOneWidget);
    await delegate.pop();
    await tester.pumpPageTransition();

    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets('Can use root child map with initial slash', (tester) async {
    final delegate = await pumpRouteMap(
      tester,
      RouteMap(routes: {
        '/*': (_) => RouteMap(
              routes: {
                '/': (_) => const MaterialPageOne(),
                '/two': (_) => const MaterialPageTwo(),
                '/two/three': (_) => const MaterialPageThree(),
              },
            ),
      }),
      path: '/two/three',
    );

    expect(find.byType(PageThree), findsOneWidget);
    await delegate.pop();
    await tester.pumpPageTransition();

    expect(find.byType(PageTwo), findsOneWidget);
    await delegate.pop();
    await tester.pumpPageTransition();

    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets('Can use root child map', (tester) async {
    final delegate = await pumpRouteMap(
      tester,
      RouteMap(routes: {
        '/sub/*': (_) => RouteMap(
              routes: {
                'one': (_) => const MaterialPageOne(),
                'one/two': (_) => const MaterialPageTwo(),
              },
            ),
      }),
      path: '/sub/one/two',
    );

    expect(find.byType(PageTwo), findsOneWidget);
    await delegate.pop();
    await tester.pumpPageTransition();

    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets('Can use sub child map with initial slash', (tester) async {
    final delegate = await pumpRouteMap(
      tester,
      RouteMap(routes: {
        '/sub/*': (_) => RouteMap(
              routes: {
                '/': (_) => const MaterialPageOne(),
                '/two': (_) => const MaterialPageTwo(),
                '/two/three': (_) => const MaterialPageThree(),
              },
            ),
      }),
      path: '/sub/two/three',
    );

    expect(find.byType(PageThree), findsOneWidget);
    await delegate.pop();
    await tester.pumpPageTransition();

    expect(find.byType(PageTwo), findsOneWidget);
    await delegate.pop();
    await tester.pumpPageTransition();

    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets('Can use sub child map with sub root but no initial slashes',
      (tester) async {
    final delegate = await pumpRouteMap(
      tester,
      RouteMap(routes: {
        '/sub/*': (_) => RouteMap(
              routes: {
                '/': (_) => const MaterialPageOne(),
                'two': (_) => const MaterialPageTwo(),
                'two/three': (_) => const MaterialPageThree(),
              },
            ),
      }),
      path: '/sub/two/three',
    );

    expect(find.byType(PageThree), findsOneWidget);
    await delegate.pop();
    await tester.pumpPageTransition();

    expect(find.byType(PageTwo), findsOneWidget);
    await delegate.pop();
    await tester.pumpPageTransition();

    expect(find.byType(PageOne), findsOneWidget);
  });
}
