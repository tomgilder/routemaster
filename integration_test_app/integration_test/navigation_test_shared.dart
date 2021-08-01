import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test_app/main.dart' as app;
import 'package:integration_test_app/app.dart';
import 'dart:html';

// Work-around for Flutter running with with null-safety enabled
void _default(String _) {
  throw 'required';
}

void replaceTests({void Function(String) expectUrl = _default}) {
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
}
