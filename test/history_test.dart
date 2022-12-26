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

    // Push: / -> /two
    delegate.push('/two');
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);

    // Push: /two -> /two/three
    delegate.push('/two/three');
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);

    // Current page is three
    // History stack should be: ['/', '/two', '/two/three']
    // History index should be 2
    // Pop: /two/three -> /two
    navigator.pop();
    await tester.pumpPageTransition();
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isTrue);
    expect(find.byType(PageTwo), findsOneWidget);

    // Current page is two
    // History stack should be: ['/', '/two', '/two/three']
    // History index should be 1
    // Pop: two -> one
    navigator.pop();
    await tester.pumpPageTransition();

    // Current page is one
    // History stack should be: ['/', '/two', '/two/three']
    // History index should be 0
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isFalse);
    expect(history.canGoForward, isTrue);

    // History stack should be: ['/', '/two', '/two/three']
    // History index should be 0
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

  testWidgets('Changing second route works correctly', (tester) async {
    final delegate = RoutemasterDelegate(routesBuilder: (_) => routeMap);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final routemaster = Routemaster.of(pageOneKey.currentContext!);
    final history = routemaster.history;

    // Go to /two
    routemaster.push('/two');
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);

    // Go back to /
    history.back();
    await tester.pumpPageTransition();
    expect(find.byType(PageOne), findsOneWidget);

    // Go to /three
    routemaster.push('/three');
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);

    // Go back to /
    history.back();
    await tester.pumpPageTransition();
    expect(find.byType(PageOne), findsOneWidget);

    // Go forward to /three
    history.forward();
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
  });

  testWidgets('Check clearing history behavior', (tester) async {
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

    // Push: / -> /two
    delegate.push('/two');
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);

    // Push: /two -> /two/three
    delegate.push('/two/three');
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);

    // Back to page /two
    history.back();
    await tester.pumpPageTransition();

    // Can go back -> /
    expect(history.canGoBack, isTrue);
    // Can go forward -> /two/three
    expect(history.canGoForward, isTrue);

    // Clear the history
    history.clear();

    // Cannot go back
    expect(history.canGoBack, isFalse);
    // Cannot go forward
    expect(history.canGoForward, isFalse);
  });
}
