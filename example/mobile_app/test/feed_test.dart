import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/pages/feed_page.dart';
import 'helpers.dart';

Future pumpFeedPage(WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.text('Log in'));
  await tester.pump();
  await tester.pump(Duration(seconds: 1));
}

void main() {
  testWidgets('Shows profile page 1, photo page, and back to feed home',
      (tester) async {
    await recordUrlChanges((systemUrl) async {
      await pumpFeedPage(tester);

      expect(find.byType(CupertinoTabBar), findsOneWidget);

      // Go to profile page
      await tester.tap(find.text('Push profile page with ID 1'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
      expect(systemUrl.current, '/feed/profile/1');

      expect(
        find.text('Profile page, ID = 1, message = null'),
        findsOneWidget,
      );

      // Verify page is being shown within tab bar
      expect(find.byType(CupertinoTabBar), findsOneWidget);

      // Go to photo page
      await tester.tap(find.text('Photo page (custom animation)'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/feed/profile/1/photo');
      expect(
        find.text('This would be a lovely picture of user 1'),
        findsOneWidget,
      );

      // Switch to search tab and back to verify stack stays in place
      await tester.tap(find.text('Search'));
      await tester.pump();
      await tester.tap(find.text('Feed'));
      await tester.pump();
      expect(systemUrl.current, '/feed/profile/1/photo');

      await invokeSystemBack();
      await tester.pumpAndSettle();
      expect(systemUrl.current, '/feed/profile/1');

      expect(find.byType(PhotoPage), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(ProfilePage),
          matching: find.byType(BackButton),
        ),
      );
      await tester.pump();
      expect(systemUrl.current, '/feed');
    });
  });

  testWidgets('Shows profile page 2', (tester) async {
    await recordUrlChanges((systemUrl) async {
      await pumpFeedPage(tester);

      await tester.tap(
        find.text('Push profile page with ID 2 and query string'),
      );
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/feed/profile/2?message=hello');

      expect(
        find.text('Profile page, ID = 2, message = hello'),
        findsOneWidget,
      );

      // Go to photo page
      await tester.tap(find.text('Photo page (custom animation)'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/feed/profile/2/photo');
    });
  });

  testWidgets('Test skipping stacks', (tester) async {
    await recordUrlChanges((systemUrl) async {
      await pumpFeedPage(tester);

      await tester.tap(
        find.text("Go to user 1's photo page (skipping stacks)"),
      );
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/feed/profile/1/photo');
      expect(
        find.text('This would be a lovely picture of user 1'),
        findsOneWidget,
      );

      // Goes back to profile
      await invokeSystemBack();

      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/feed/profile/1');
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.byType(PhotoPage), findsNothing);

      // Goes back to feed home
      await invokeSystemBack();
      await tester.pumpAndSettle();
      expect(systemUrl.current, '/feed');
    });
  });

  testWidgets('Can jump to settings tab', (tester) async {
    await recordUrlChanges((systemUrl) async {
      await pumpFeedPage(tester);
      await tester.tap(find.text('Jump to settings tab'));
      await tester.pump();
      expect(systemUrl.current, '/settings');
    });
  });

  testWidgets('Can push and go back from non-Page route', (tester) async {
    await pumpFeedPage(tester);

    await tester.scrollUntilVisible(find.text('Push non-Page route'), 100);
    await tester.pump();
    await tester.tap(
      find.text('Push non-Page route'),
    );
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(find.text('Non-Page route'), findsOneWidget);

    await invokeSystemBack();
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(find.text('Non-Page route'), findsNothing);
  });
}
