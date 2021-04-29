import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/system_nav.dart';

import 'helpers.dart';

void main() {
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
    await tester.pump(Duration(seconds: 1));

    expect(find.byType(PageTwo), findsOneWidget);
  });

  test('Throws after dispose', () {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {},
      ),
    );
    delegate.dispose();

    expect(() => delegate.currentConfiguration, throwsAssertionError);
    expect(
      () => delegate.setInitialRoutePath(RouteData('')),
      throwsAssertionError,
    );
    expect(
      () => delegate.setNewRoutePath(RouteData('path')),
      throwsAssertionError,
    );
    expect(() => delegate.push(''), throwsAssertionError);
    expect(() => delegate.replace(''), throwsAssertionError);
    expect(() => delegate.popRoute(), throwsAssertionError);
  });

  testWidgets('Asserts when no RoutemasterWidget found', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(Builder(
      builder: (c) {
        context = c;
        return SizedBox();
      },
    ));

    expect(
        () => Routemaster.of(context),
        throwsA(predicate((e) =>
            e is AssertionError &&
            e.message ==
                "Couldn't get a Routemaster object from the given context.")));
  });

  test('isReplacement returns correct values', () {
    expect(isReplacementNavigation('blah'), isFalse);

    expect(isReplacementNavigation({'state': null}), isFalse);

    expect(
      isReplacementNavigation({'state': null}),
      isFalse,
    );

    expect(
      isReplacementNavigation({
        'state': {'isReplacement': null}
      }),
      isFalse,
    );

    expect(
      isReplacementNavigation({
        'state': {'isReplacement': false}
      }),
      isFalse,
    );

    expect(
      isReplacementNavigation({
        'state': {'isReplacement': true}
      }),
      isTrue,
    );
  });

  testWidgets('Can push relative path when current page has query string',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPageOne(),
          '/two': (_) => MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/?query=string');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageOne), findsOneWidget);

    delegate.push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Can replace relative path when current page has query string',
      (tester) async {
    SystemNav.setFakePathUrlStrategy();

    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPageOne(),
          '/two': (_) => MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.replace('/?query=string');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageOne), findsOneWidget);

    delegate.replace('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Can push just a query string', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPageOne(),
          '/two': (_) => MaterialPageTwo(),
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
        delegate.push('?query=string');
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/?query=string'],
    );
  });

  testWidgets('Can replace just a query string', (tester) async {
    SystemNav.setFakePathUrlStrategy();

    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPageOne(),
          '/two': (_) => MaterialPageTwo(),
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
        delegate.replace('?query=string');
        await tester.pump();
        await tester.pump(kTransitionDuration);
      }),
      ['/?query=string'],
    );
  });
}
