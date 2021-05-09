import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/pages/bottom_navigation_bar_page.dart';
import 'package:mobile_app/pages/home_page.dart';
import 'package:mobile_app/pages/notifications_page.dart';
import 'helpers.dart';

Future pumpBottomNavigationPage(WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.text('Log in'));
  await tester.pump();
  await tester.pump(Duration(seconds: 1));
  await tester.tap(find.text('Bottom Navigation Bar page'));
  await tester.pump();
  await tester.pump(Duration(seconds: 1));
}

void main() {
  testWidgets('Can pop twice', (tester) async {
    await pumpBottomNavigationPage(tester);
    await tester.tap(find.text('Push page Android-style'));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    // This pops twice without a break between
    await tester.tap(find.text('Go back twice'));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(find.byType(DoubleBackPage), findsNothing);
    expect(find.byType(BottomNavigationBarPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('Stays on correct page after push and pop', (tester) async {
    await pumpBottomNavigationPage(tester);
    expect(find.text('Bottom bar page 1'), findsOneWidget);

    await tester.tap(find.text('Two'));
    await tester.pump();
    expect(find.text('Bottom bar page 1'), findsNothing);

    // This pops twice without a break between
    await tester.tap(find.text('Page 2: push page'));
    await tester.pump(Duration(seconds: 1));

    await invokeSystemBack();

    await tester.pump(Duration(seconds: 1));
    expect(find.text('Bottom bar page 2'), findsOneWidget);
    expect(find.text('Bottom bar page 1'), findsNothing);
  });

  testWidgets('Navigating directly to tab path shows tab bar', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.tap(find.text('Log in'));
    await tester.pump();

    await setSystemUrl('/bottom-navigation-bar/one');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(find.text('Bottom bar page 1'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
