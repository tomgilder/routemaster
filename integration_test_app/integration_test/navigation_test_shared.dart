import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_app/main.dart' as app;
import 'package:integration_test_app/app.dart';
import 'dart:html';

void replaceTests({required void Function(String) expectUrl}) {
  testWidgets('After replace, skips page going back', (tester) async {
    app.main();

    await tester.pumpAndSettle();
    await tester.tap(find.text('Push page one'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);
    expectUrl('/one');

    await tester.tap(find.text('Replace page two'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);
    expectUrl('/two');

    window.history.back();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(PageTwo), findsNothing);
    expect(find.byType(PageOne), findsNothing);
    expectUrl('/');
  });

  testWidgets("Doesn't skip going back with push", (tester) async {
    app.main();

    await tester.pumpAndSettle();
    await tester.tap(find.text('Push page one'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);
    expectUrl('/one');

    await tester.tap(find.text('Push page two'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsOneWidget);
    expectUrl('/two');

    window.history.back();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsNothing);
    expect(find.byType(PageOne), findsOneWidget);
    expectUrl('/one');

    window.history.back();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PageTwo), findsNothing);
    expect(find.byType(PageOne), findsNothing);
    expectUrl('/');
  });

  testWidgets('Has correct URL when replacing with tabs', (tester) async {
    app.main();

    await tester.pumpAndSettle();
    await tester.tap(find.text('Replace tabs'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(TabbedPage), findsOneWidget);
    expectUrl('/tabs/one');
  });

  testWidgets('Can replace to private page', (tester) async {
    // Starts on home page
    app.main();

    // Go to page one
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push page one'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);
    expectUrl('/one');

    // Replace with private page
    await tester.tap(find.text('Replace private page'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PrivatePage), findsOneWidget);
    expect(find.text('hello from private page'), findsOneWidget);
    expectUrl('/');

    // Go back to home page
    window.history.back();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(PrivatePage), findsNothing);
    expect(find.byType(PageOne), findsNothing);
    expectUrl('/');

    // Go forward to private page
    window.history.forward();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(PrivatePage), findsOneWidget);
    expect(find.text('hello from private page'), findsOneWidget);
    expectUrl('/');
  });

  testWidgets('Can push private page with different URL', (tester) async {
    app.main();

    await tester.pumpAndSettle();
    await tester.tap(find.text('Push page one'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);
    expectUrl('/one');

    // Push private page
    await tester.tap(find.text('Push private page'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PrivatePage), findsOneWidget);
    expect(find.text('hello from private page'), findsOneWidget);
    expectUrl('/');

    // Goes back to start page
    window.history.back();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PrivatePage), findsNothing);
    expect(find.byType(PageOne), findsOneWidget);
    expectUrl('/one');

    // Goes forward to private page
    window.history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PrivatePage), findsOneWidget);
    expect(find.text('hello from private page'), findsOneWidget);
    expectUrl('/');
  });

  testWidgets('Can push private page with same URL', (tester) async {
    app.main();

    // Push private page
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push private page'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PrivatePage), findsOneWidget);
    expect(find.text('private page pushed from home'), findsOneWidget);
    expectUrl('/');

    // Goes back to home page
    window.history.back();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PrivatePage), findsNothing);
    expectUrl('/');

    // Goes forward to private page
    window.history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PrivatePage), findsOneWidget);
    expect(find.text('private page pushed from home'), findsOneWidget);
    expectUrl('/');
  });

  testWidgets('Can navigate with Routemaster history back and forward',
      (tester) async {
    final app = MyApp();
    runApp(app);
    await tester.pumpAndSettle();

    final history = app.delegate.history;

    await tester.tap(find.text('Push page one'));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one');
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);

    await tester.tap(find.text('Push page two'));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/two');
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);

    history.back();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one');
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isTrue);

    history.back();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/');
    expect(find.byType(HomePage), findsOneWidget);
    expect(history.canGoBack, isFalse);
    expect(history.canGoForward, isTrue);

    history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one');
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isTrue);

    history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/two');
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);
  });

  testWidgets('Can navigate with browser history back and forward',
      (tester) async {
    final app = MyApp();
    runApp(app);
    await tester.pumpAndSettle();

    final history = app.delegate.history;

    // Push: root -> one
    await tester.tap(find.text('Push page one'));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one');
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);

    // Push: one -> two
    await tester.tap(find.text('Push page two'));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/two');
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);

    // Go back: two -> one
    window.history.back();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one');
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isTrue);

    // Go back: one -> root
    window.history.back();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/');
    expect(find.byType(HomePage), findsOneWidget);
    expect(history.canGoBack, isFalse);
    expect(history.canGoForward, isTrue);

    // Go forward: root -> one
    window.history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one');
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isTrue);

    // Go forward: one -> two
    window.history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/two');
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);
  });

  testWidgets('Can navigate with browser history go()', (tester) async {
    final app = MyApp();
    runApp(app);
    await tester.pumpAndSettle();

    final history = app.delegate.history;

    // Push: root -> one
    await tester.tap(find.text('Push page one'));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one');
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);

    // Push: one -> two
    await tester.tap(find.text('Push page two'));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/two');
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);

    // Back twice: two -> root
    window.history.go(-2);
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/');
    expect(find.byType(HomePage), findsOneWidget);
    expect(history.canGoBack, isFalse);
    expect(history.canGoForward, isTrue);

    // Forward twice: two -> root
    window.history.go(2);
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/two');
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);
  });

  testWidgets('Navigator pop then forward works correctly', (tester) async {
    final app = MyApp();
    runApp(app);
    await tester.pumpAndSettle();

    final history = app.delegate.history;

    // Push: / -> /one
    await tester.tap(find.text('Push page one'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    // Push: /one -> /one/two
    await tester.tap(find.text('Push /one/two'));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one/two');
    expect(find.byType(PageTwo), findsOneWidget);

    // Pop with navigator: /one/two -> /one
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one');
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isTrue);

    // Go forward: /one -> /one/two
    window.history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one/two');
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);
    expect(history.forward(), isFalse);

    // Try to go forward again: shouldn't do anything
    window.history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one/two');
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Navigator pop then forward works correctly via delegate',
      (tester) async {
    final app = MyApp();
    runApp(app);
    await tester.pumpAndSettle();

    final history = app.delegate.history;

    // Push: / -> /one
    await tester.tap(find.text('Push page one'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    // Push: /one -> /one/two
    await tester.tap(find.text('Push /one/two'));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one/two');
    expect(find.byType(PageTwo), findsOneWidget);

    // Pop with delegate: /one/two -> /one
    app.delegate.pop();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one');
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isTrue);

    // Go forward: /one -> /one/two
    window.history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one/two');
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);
    expect(history.forward(), isFalse);

    // Try to go forward again: shouldn't do anything
    window.history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one/two');
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets(
      'Navigator pop then forward works correctly via delegate popUntil',
      (tester) async {
    final app = MyApp();
    runApp(app);
    await tester.pumpAndSettle();

    final history = app.delegate.history;

    // Push: / -> /one
    await tester.tap(find.text('Push page one'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(PageOne), findsOneWidget);

    // Push: /one -> /one/two
    await tester.tap(find.text('Push /one/two'));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one/two');
    expect(find.byType(PageTwo), findsOneWidget);

    // Pop with delegate: /one/two -> /one
    app.delegate.popUntil((r) => r.fullPath == '/one');
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one');
    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isTrue);

    // Go forward: /one -> /one/two
    window.history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one/two');
    expect(find.byType(PageTwo), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);
    expect(history.forward(), isFalse);

    // Try to go forward again: shouldn't do anything
    window.history.forward();
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one/two');
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets(
      'Pop does not use history.back() if previous route not in history stack',
      (tester) async {
    final app = MyApp();
    runApp(app);
    await tester.pumpAndSettle();

    final history = app.delegate.history;

    // Push: / -> /one/two
    app.delegate.push('/tabs');
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(TabbedPage), findsOneWidget);

    app.delegate.push('/one/two');
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one/two');

    // Pop with navigator: /one/two -> /one
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/one');

    expect(find.byType(PageOne), findsOneWidget);
    expect(history.canGoBack, isTrue);
    expect(history.canGoForward, isFalse);

    // Pop with navigator: /one -> /
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pumpAndSettle();
    expectUrl('/');
    expect(find.byType(HomePage), findsOneWidget);
  });
}
