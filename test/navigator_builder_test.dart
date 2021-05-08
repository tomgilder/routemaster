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
          '/': (_) => MaterialPageOne(),
          '/two': (_) => MaterialPageTwo(),
        },
      ),
      navigatorBuilder: (BuildContext context, PageStack stack) {
        return StackNavigator(stack: stack);
      },
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/two');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Can listen to custom navigator', (tester) async {
    final observer = LoggingNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: RoutemasterDelegate.builder(
          routesBuilder: (_) => RouteMap(
            routes: {
              '/': (_) => MaterialPageOne(),
              '/two': (_) => MaterialPageTwo(),
            },
          ),
          navigatorBuilder: (BuildContext context, PageStack stack) {
            return StackNavigator(
              stack: stack,
              observers: [observer],
            );
          },
        ),
      ),
    );

    await setSystemUrl('/two');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(find.byType(PageTwo), findsOneWidget);
    expect(observer.log.length, 2);
    expect(observer.log[0], isPush());
    expect(observer.log[1], isPush());
  });

  testWidgets('Can swap navigatorBuilder', (tester) async {
    var builder1Called = 0;
    var builder2Called = 0;

    final builder1 = (BuildContext context, PageStack stack) {
      builder1Called++;
      return StackNavigator(stack: stack);
    };

    final builder2 = (BuildContext context, PageStack stack) {
      builder2Called++;
      return StackNavigator(stack: stack);
    };

    Widget buildApp(NavigatorBuilder builder) {
      return MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: RoutemasterDelegate.builder(
          routesBuilder: (_) => RouteMap(
            routes: {'/': (_) => MaterialPageOne()},
          ),
          navigatorBuilder: builder,
        ),
      );
    }

    await tester.pumpWidget(buildApp(builder1));
    expect(builder1Called, 1);

    await tester.pumpWidget(buildApp(builder2));
    expect(builder2Called, 1);
  });
}
