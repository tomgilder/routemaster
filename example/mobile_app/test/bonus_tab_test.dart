import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

Finder findTab({
  required String title,
  required String hint,
  required bool selected,
}) {
  return find.descendant(
    of: find.byWidgetPredicate((widget) =>
        widget is Semantics &&
        widget.properties.hint == hint &&
        widget.properties.selected == selected),
    matching: find.text(title),
  );
}

void main() {
  testWidgets('Can enable bonus tab', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.tap(find.text('Log in'));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    // Switch to settings tab
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(
      findTab(title: 'Settings', hint: 'Tab 4 of 4', selected: true),
      findsOneWidget,
    );

    // Enable bonus tab
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pump();
    expect(
      findTab(title: 'Bonus!', hint: 'Tab 3 of 5', selected: false),
      findsOneWidget,
    );
    expect(
      findTab(title: 'Settings', hint: 'Tab 5 of 5', selected: true),
      findsOneWidget,
    );

    // Switch to bonus tab
    await tester.tap(find.text('Bonus!'));
    await tester.pump();
    expect(
      findTab(title: 'Bonus!', hint: 'Tab 3 of 5', selected: true),
      findsOneWidget,
    );
    expect(
      findTab(title: 'Settings', hint: 'Tab 5 of 5', selected: false),
      findsOneWidget,
    );

    // Switch back to settings
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(
      findTab(title: 'Bonus!', hint: 'Tab 3 of 5', selected: false),
      findsOneWidget,
    );
    expect(
      findTab(title: 'Settings', hint: 'Tab 5 of 5', selected: true),
      findsOneWidget,
    );

    // Disable bonus tab
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pump();
    expect(find.text('Bonus!'), findsNothing);
    expect(
      findTab(title: 'Settings', hint: 'Tab 4 of 4', selected: true),
      findsOneWidget,
    );
  });
}
