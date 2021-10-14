import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';
import 'observer_test.dart';

void main() {
  testWidgets('Can use custom navigator', (tester) async {
    final delegate = RoutemasterDelegate.builder(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (_) => const MaterialPageTwo(),
        },
      ),
      navigatorBuilder: (BuildContext context, PageStack stack) {
        return PageStackNavigator(stack: stack);
      },
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/two');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Can listen to custom navigator', (tester) async {
    final observer = LoggingNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate.builder(
          routesBuilder: (_) => RouteMap(
            routes: {
              '/': (_) => const MaterialPageOne(),
              '/two': (_) => const MaterialPageTwo(),
            },
          ),
          navigatorBuilder: (BuildContext context, PageStack stack) {
            return PageStackNavigator(
              stack: stack,
              observers: [observer],
            );
          },
        ),
      ),
    );

    await setSystemUrl('/two');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(PageTwo), findsOneWidget);
    expect(observer.log.length, 2);
    expect(observer.log[0], isPush());
    expect(observer.log[1], isPush());
  });

  testWidgets('Can filter pages using PageStackNavigator.builder',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(
            routes: {
              '/': (_) => StackPage(
                    child: SimpleStackPage(builder: (pages) => pages.take(1)),
                    defaultPath: '/one/two',
                  ),
              '/one': (_) => const MaterialPageOne(),
              '/one/two': (_) => const MaterialPageTwo(),
            },
          ),
        ),
      ),
    );

    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);
  });

  testWidgets('PageStackNavigator.builder with no filter shows all pages',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => StackPage(
                child: SimpleStackPage(builder: (pages) => pages),
                defaultPath: '/one',
              ),
          '/one': (_) => const MaterialPageOne(),
          '/one/two': (_) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageOne), findsOneWidget);
    delegate.push('/one/two');
    await tester.pumpPageTransition();

    expect(find.byType(PageTwo), findsOneWidget);
  });
}

class SimpleStackPage extends StatelessWidget {
  const SimpleStackPage({required this.builder});

  final Iterable<Page> Function(List<Page>) builder;

  @override
  Widget build(BuildContext context) {
    return PageStackNavigator.builder(
      stack: StackPage.of(context).stack,
      builder: builder,
    );
  }
}
