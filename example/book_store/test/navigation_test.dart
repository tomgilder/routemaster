import 'package:book_store/book_page.dart';
import 'package:book_store/category_page.dart';
import 'package:book_store/login_page.dart';
import 'package:book_store/main.dart';
import 'package:book_store/models.dart';
import 'package:book_store/search_page.dart';
import 'package:book_store/wishlist_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can navigate to book by tapping', (tester) async {
    await recordUrlChanges((systemUrl) async {
      // Scenario #1: Deep Linking - Path Parameters

      await tester.pumpWidget(BookStoreApp());

      await tester.tap(find.text('Of Hummingbirds And Men'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/book/2');

      expect(
        find.byWidgetPredicate(
          (widget) => widget is BookPage && widget.id == '2',
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('Can navigate to book by by setting URL', (tester) async {
    // Scenario #1: Deep Linking - Path Parameters

    await tester.pumpWidget(BookStoreApp());
    await setSystemUrl('/book/2');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(
      find.byWidgetPredicate(
        (widget) => widget is BookPage && widget.id == '2',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Can search for a book via search bar', (tester) async {
    await recordUrlChanges((systemUrl) async {
      // Scenario #2: Deep Linking - Query Parameters

      await tester.pumpWidget(BookStoreApp());
      await tester.enterText(find.byType(CupertinoTextField), 'gone with');

      await tester.tap(find.text('Search'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/search?query=gone+with');

      expect(
        find.byWidgetPredicate(
          (widget) => widget is SearchPage && widget.query == 'gone with',
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('Can search for a book by setting URL', (tester) async {
    // Scenario #2: Deep Linking - Query Parameters

    await tester.pumpWidget(BookStoreApp());
    await setSystemUrl('/search?query=gone+with');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(
      find.byWidgetPredicate(
        (widget) => widget is SearchPage && widget.query == 'gone with',
      ),
      findsOneWidget,
    );
  });

  testWidgets('User can view wish list when logged in already', (tester) async {
    // Scenario #3: Login/Logout/Sign-up Routing - Deep link

    await tester.pumpWidget(BookStoreApp(username: 'dash'));
    await setSystemUrl('/wishlist/shared/123');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    // Expect wishlist page is shown
    expect(
      find.byWidgetPredicate(
        (widget) => widget is WishlistPage && widget.id == '123',
      ),
      findsOneWidget,
    );
  });

  testWidgets('User has to log in to view wishlist', (tester) async {
    await recordUrlChanges((systemUrl) async {
      // Scenario #3: Login/Logout/Sign-up Routing - Deep link

      await tester.pumpWidget(BookStoreApp());

      // Redirects to login page

      await setSystemUrl('/wishlist/shared/123');
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/login?redirectTo=%2Fwishlist%2Fshared%2F123');

      // User logs in
      await tester.enterText(find.byKey(LoginPage.usernameFieldKey), 'dash');
      await tester.pump();

      await tester.tap(find.byKey(LoginPage.loginButtonKey));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/wishlist/shared/123');

      // Expect wishlist page is shown
      expect(
        find.byWidgetPredicate(
          (widget) => widget is WishlistPage && widget.id == '123',
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('Can require user to be logged in to view site', (tester) async {
    await recordUrlChanges((systemUrl) async {
      // Scenario #3: Login/Logout/Sign-up Routing - Home requires logging in

      await tester.pumpWidget(BookStoreApp(siteBlockedWithoutLogin: true));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // User logs in
      await tester.enterText(find.byKey(LoginPage.usernameFieldKey), 'dash');
      await tester.pump();
      await tester.tap(find.byKey(LoginPage.loginButtonKey));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(find.byType(ShopHome), findsOneWidget);
    });
  });

  // TODO: Skipped due to API changing in Flutter master
  // testWidgets('Nested routing with tabs', (tester) async {
  //   await recordUrlChanges((systemUrl) async {
  //     // Scenario #4: Nested Routing (with Tabs)

  //     final routeInfoProvider = BrowserEmulatorRouteInfoProvider();
  //     await tester.pumpWidget(BookStoreApp(
  //       routeInformationProvider: routeInfoProvider,
  //     ));
  //     await tester.pump();

  //     // Go to audiobooks page

  //     await tester.tap(find.text('Audiobooks'));
  //     await tester.pump();

  //     expect(systemUrl.current, '/audiobooks/all');

  //     // Verify audiobooks page
  //     expect(find.byType(AudiobookPage), findsOneWidget);
  //     expect(find.byType(BookCard), findsNWidgets(4));

  //     // Switch to staff picks tab

  //     await tester.tap(find.text('Staff picks'));
  //     await tester.pump();
  //     await tester.pump(Duration(seconds: 1));
  //     expect(find.byType(BookCard), findsNWidgets(2));

  //     expect(systemUrl.current, '/audiobooks/picks');

  //     // Navigate to fiction section

  //     await tester.tap(find.text('Fiction'));
  //     await tester.pump();
  //     expect(find.byType(CategoryPage), findsOneWidget);

  //     expect(systemUrl.current, '/category/fiction');

  //     // Pop to go back to /audiobooks/picks
  //     routeInfoProvider.pop();
  //     await tester.pump();

  //     expect(find.byType(CategoryPage), findsNothing);
  //     expect(find.byType(BookCard), findsNWidgets(2));
  //   });
  // });

  testWidgets('Nested routing modal dialog', (tester) async {
    await recordUrlChanges((systemUrl) async {
      // Scenario #4: Nested Routing with Modal Dialog

      await tester.pumpWidget(BookStoreApp(username: 'dash'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Go to wishlists page

      await tester.tap(find.text('Wishlists'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/wishlist');

      // Tap add wishlist

      await tester.tap(find.text('Add a new wishlist'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/wishlist/add');

      expect(find.byType(AddWishlistDialog), findsOneWidget);

      await invokeSystemBack();
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/wishlist');
    });
  });

  testWidgets('Can skip navigation stacks', (tester) async {
    await recordUrlChanges((systemUrl) async {
      // Scenario #5: Skipping Stacks

      await tester.pumpWidget(BookStoreApp());

      // Search for "non-fiction"
      await tester.enterText(find.byType(CupertinoTextField), 'non-fiction');

      await tester.tap(find.text('Search'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/search?query=non-fiction');

      // Go to book page

      await tester.tap(find.text('Hummingbirds for Dummies'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/category/nonfiction/book/1');

      // Tap back button

      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/category/nonfiction');

      // Verify non-fiction category page
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CategoryPage &&
              widget.category == BookCategory.nonFiction,
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('Can create new wishlist', (tester) async {
    await recordUrlChanges((systemUrl) async {
      // Scenario #6: Dynamic Linking

      await tester.pumpWidget(BookStoreApp(username: 'dash'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Go to wishlists page

      await tester.tap(find.text('Wishlists'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/wishlist');

      // Tap add wishlist

      await tester.tap(find.text('Add a new wishlist'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/wishlist/add');

      expect(find.byType(AddWishlistDialog), findsOneWidget);

      // Enter wishlist details
      await tester.enterText(
        find.byKey(AddWishlistDialog.nameFieldKey),
        'Wishlist name',
      );
      await tester.tap(find.text('Hummingbirds for Dummies'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Click add wishlist

      await tester.tap(find.text('Add wishlist'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
      expect(find.byType(AddWishlistDialog), findsNothing);

      expect(systemUrl.current, '/wishlist');

      // Navigate to wishlist

      await tester.tap(find.text('Wishlist name'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/wishlist/shared/list-2');

      // Expect wishlist page is shown
      expect(
        find.byWidgetPredicate(
          (widget) => widget is WishlistPage && widget.id == 'list-2',
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets("History doesn't have duplicate pages", (tester) async {
    await recordUrlChanges((systemUrl) async {
      // Scenario appendix: Manipulation of the History Stack - Remove Duplicate Pages

      await tester.pumpWidget(BookStoreApp());

      await tester.tap(find.text('Non-fiction'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/category/nonfiction');

      await tester.tap(find.text('Fiction'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/category/fiction');

      await tester.tap(find.text('Non-fiction'));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/category/nonfiction');

      // Tap back button, expect to go back to home page

      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(systemUrl.current, '/');
    });
  });

  testWidgets('Shows 404 page for unknown book', (tester) async {
    await tester.pumpWidget(BookStoreApp());
    await setSystemUrl('/book/123');
    await tester.pump();
    expect(find.text("Couldn't find page '/book/123'"), findsOneWidget);
  });

  testWidgets('Can log in', (tester) async {
    // Login and redirect to root
    await tester.pumpWidget(BookStoreApp());
    await tester.pump();

    await tester.tap(find.text('Log in'));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    // User logs in
    await tester.enterText(find.byKey(LoginPage.usernameFieldKey), 'dash');
    await tester.pump();
    await tester.tap(find.byKey(LoginPage.loginButtonKey));
    await tester.pump();

    expect(find.byType(ShopHome), findsOneWidget);
  });
}
