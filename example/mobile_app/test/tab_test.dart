import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can navigate directly to tab two', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.tap(find.text('Log in'));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    await setSystemUrl('/notifications/one');
    await tester.pump();
    expect(find.text('Page one'), findsOneWidget);

    await setSystemUrl('/notifications/two');
    await tester.pump();
    expect(find.text('Page two'), findsOneWidget);
  });
}
