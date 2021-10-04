import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';

import 'helpers.dart';

final pageOneKey = GlobalKey();
final routeMap = RouteMap(
  routes: {
    '/': (_) => MaterialPage<void>(child: PageOne(key: pageOneKey)),
    '/two': (_) => const MaterialPageTwo(),
    '/three': (_) => const MaterialPageThree(),
  },
);

void main() {
  testWidgets('Cannot go forward or back with no navigation', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (_) => routeMap);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.history.canGoBack, isFalse);
    expect(delegate.history.canGoForward, isFalse);
    expect(delegate.history.back(), false);
    expect(delegate.history.forward(), false);

    final routemaster = Routemaster.of(pageOneKey.currentContext!);
    expect(routemaster.history.canGoBack, isFalse);
    expect(routemaster.history.canGoForward, isFalse);
    expect(routemaster.history.back(), false);
    expect(routemaster.history.forward(), false);
  });

  testWidgets('Popping navigator also goes back in history', (tester) async {
    final pageOneKey = GlobalKey();
    final routeMap = RouteMap(
      routes: {
        '/': (_) => MaterialPage<void>(child: PageOne(key: pageOneKey)),
        '/two': (_) => const MaterialPageTwo(),
        '/two/three': (_) => const MaterialPageThree(),
      },
    );
    final delegate = RoutemasterDelegate(routesBuilder: (_) => routeMap);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    await tester.pump();

    final history = delegate.history;
    final navigator = Navigator.of(pageOneKey.currentContext!);

    // Push: one -> two
    delegate.push('/two');
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);

    // Push: two -> tree
    delegate.push('/two/three');
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);

    // Pop: three -> two
    navigator.pop();
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isTrue);

    // Pop: two -> one
    navigator.pop();
    await tester.pumpPageTransition();
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isFalse);
    expect(history.canGoForward, isTrue);

    // Forward: one -> two
    final forwardResult1 = history.forward();
    await tester.pumpPageTransition();
    expect(forwardResult1, isTrue);
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isTrue);

    // Forward: two -> three
    final forwardResult2 = history.forward();
    await tester.pumpPageTransition();
    expect(forwardResult2, isTrue);
    expect(find.byType(PageThree), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);

    // Back: three -> two
    history.back();
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isTrue);

    // Back: two -> one
    history.back();
    await tester.pumpPageTransition();
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isFalse);
    expect(history.canGoForward, isTrue);
  });

  testWidgets('Can go forward or back with push (delegate)', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (_) => routeMap);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final history = delegate.history;

    expect(history.canGoBack, isFalse);
    expect(history.canGoForward, isFalse);
    expect(history.back(), isFalse);
    expect(history.forward(), isFalse);

    delegate.push('/two');
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);
    expect(history.forward(), isFalse);

    delegate.push('/three');
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);
    expect(history.forward(), isFalse);

    // Go back: three -> two
    await recordUrlChanges((systemUrl) async {
      final backResult1 = delegate.history.back();
      await tester.pumpPageTransition();
      expect(systemUrl.current, '/two');
      expect(find.byType(PageTwo), findsOneWidget);
      expect(backResult1, isTrue);
      expect(history.canGoBack, isTrue);
      expect(history.canGoForward, isTrue);

      // Go back: two -> one
      final backResult2 = history.back();
      await tester.pumpPageTransition();
      expect(systemUrl.current, '/');
      expect(find.byType(PageOne), findsOneWidget);
      expect(backResult2, backResult2);
      expect(history.canGoBack, isFalse);
      expect(history.canGoForward, isTrue);
      expect(history.back(), isFalse);

      // Go forward: one -> two
      final forwardResult1 = history.forward();
      await tester.pumpPageTransition();
      expect(systemUrl.current, '/two');
      expect(find.byType(PageTwo), findsOneWidget);
      expect(forwardResult1, isTrue);
      expect(delegate.history.canGoBack, isTrue);
      expect(delegate.history.canGoBack, isTrue);

      // Go forward: two -> three
      final forwardResult2 = history.forward();
      await tester.pumpPageTransition();
      expect(systemUrl.current, '/three');
      expect(find.byType(PageThree), findsOneWidget);
      expect(forwardResult2, isTrue);
      expect(history.canGoBack, isTrue);
      expect(history.canGoForward, isFalse);
      expect(history.forward(), isFalse);
    });
  });

  testWidgets('Can go forward or back with push (Routemaster)', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (_) => routeMap);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final routemaster = Routemaster.of(pageOneKey.currentContext!);
    final history = routemaster.history;

    expect(history.canGoBack, isFalse);
    expect(history.canGoForward, isFalse);
    expect(history.back(), isFalse);
    expect(history.forward(), isFalse);

    routemaster.push('/two');
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);
    expect(history.forward(), isFalse);

    routemaster.push('/three');
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);
    expect(history.forward(), isFalse);

    // Go back: three -> two
    await recordUrlChanges((systemUrl) async {
      final backResult1 = history.back();
      await tester.pumpPageTransition();
      expect(systemUrl.current, '/two');
      expect(find.byType(PageTwo), findsOneWidget);
      expect(backResult1, isTrue);
      expect(history.canGoBack, isTrue);
      expect(history.canGoForward, isTrue);

      // Go back: two -> one
      final backResult2 = history.back();
      await tester.pumpPageTransition();
      expect(systemUrl.current, '/');
      expect(find.byType(PageOne), findsOneWidget);
      expect(backResult2, backResult2);
      expect(history.canGoBack, isFalse);
      expect(history.canGoForward, isTrue);
      expect(history.back(), isFalse);

      // Go forward: one -> two
      final forwardResult1 = history.forward();
      await tester.pumpPageTransition();
      expect(systemUrl.current, '/two');
      expect(find.byType(PageTwo), findsOneWidget);
      expect(forwardResult1, isTrue);
      expect(history.canGoBack, isTrue);
      expect(history.canGoForward, isTrue);

      // Go forward: two -> three
      final forwardResult2 = history.forward();
      await tester.pumpPageTransition();
      expect(systemUrl.current, '/three');
      expect(find.byType(PageThree), findsOneWidget);
      expect(forwardResult2, isTrue);
      expect(history.canGoBack, isTrue);
      expect(history.canGoForward, isFalse);
      expect(history.forward(), isFalse);
    });
  });

  testWidgets('Replace removes first entry', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (_) => routeMap);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final routemaster = Routemaster.of(pageOneKey.currentContext!);
    final history = routemaster.history;
    routemaster.replace('/two');
    await tester.pumpPageTransition();

    expect(history.canGoBack, isFalse);
    expect(history.canGoForward, isFalse);
  });

  testWidgets('Replace removes second entry', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (_) => routeMap);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final routemaster = Routemaster.of(pageOneKey.currentContext!);
    final history = routemaster.history;

    routemaster.push('/two');
    await tester.pumpPageTransition();
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);

    routemaster.replace('/three');
    await tester.pumpPageTransition();
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);

    await recordUrlChanges((systemUrl) async {
      // Back: three -> one
      final backResult = history.back();
      await tester.pumpPageTransition();
      expect(backResult, isTrue);
      expect(systemUrl.current, '/');
      expect(history.canGoBack, isFalse);
      expect(history.canGoForward, isTrue);

      // Forward: one -> three
      final forwardResult = history.forward();
      await tester.pumpPageTransition();
      expect(forwardResult, isTrue);
      expect(systemUrl.current, '/three');
      expect(history.canGoBack, isTrue);
      expect(history.canGoForward, isFalse);
    });
  });

  testWidgets('Clears forward stack on push', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (_) => routeMap);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final routemaster = Routemaster.of(pageOneKey.currentContext!);
    final history = routemaster.history;

    routemaster.push('/two');
    await tester.pumpPageTransition();

    routemaster.push('/three');
    await tester.pumpPageTransition();

    // Back to page one
    history.back();
    await tester.pumpPageTransition();
    history.back();
    await tester.pumpPageTransition();

    // Go to page three
    routemaster.push('/three');
    expect(history.canGoForward, isFalse);
    expect(history.forward(), isFalse);
  });

  testWidgets('Clears forward stack on replace', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (_) => routeMap);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final routemaster = Routemaster.of(pageOneKey.currentContext!);
    final history = routemaster.history;

    routemaster.push('/two');
    await tester.pumpPageTransition();

    routemaster.push('/three');
    await tester.pumpPageTransition();

    // Back to page one
    history.back();
    await tester.pumpPageTransition();
    history.back();
    await tester.pumpPageTransition();

    // Go to page three
    routemaster.replace('/three');
    expect(routemaster.history.canGoForward, isFalse);
    expect(routemaster.history.forward(), isFalse);
  });
}
