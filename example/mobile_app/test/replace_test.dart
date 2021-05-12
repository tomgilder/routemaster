import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';
import 'helpers.dart';

Future pumpBottomNavigationPage(WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.text('Log in'));
  await tester.pump();
  await tester.pump(Duration(seconds: 1));
  await tester.tap(find.text('Replace test'));
  await tester.pump();
  await tester.pump(Duration(seconds: 1));
}

void main() {
  testWidgets('Can replace', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.tap(find.text('Log in'));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    await tester.tap(find.text('Replace test'));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(
      await recordUrlChanges(() async {
        await tester.tap(find.text('Replace: Bottom Navigation Bar page'));
        await tester.pump();
        await tester.pump(Duration(seconds: 1));
      }),
      ['/bottom-navigation-bar/one'],
    );

    expect(
      await recordUrlChanges(() async {
        await invokeSystemBack();
        await tester.pump();
        await tester.pump(Duration(seconds: 1));
      }),
      ['/feed'],
    );
  });
}
