import 'package:book_store/audiobooks_page.dart';
import 'package:book_store/login_page.dart';
import 'package:book_store/wishlist_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';
import 'book_card.dart';
import 'book_page.dart';
import 'category_page.dart';
import 'models.dart';
import 'page_scaffold.dart';
import 'search_page.dart';

final booksDatabase = BooksDatabase();

void main() {
  runApp(BookStoreApp());
}

bool _isValidCategory(String? category) {
  return BookCategory.values.any(
    (e) => e.queryParam == category,
  );
}

bool _isValidBookId(String? id) {
  return booksDatabase.books.any((book) => book.id == id);
}

final routeMap = RouteMap(
  onUnknownRoute: (routeInfo, context) {
    return MaterialPage(
      child: PageScaffold(
        title: 'Page not found',
        body: Center(
          child: Text(
            "Couldn't find page '$routeInfo'",
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
      ),
    );
  },
  routes: {
    '/': (route) => MaterialPage(child: ShopHome()),
    '/login': (route) => MaterialPage(
          child: LoginPage(
            redirectTo: route.queryParameters['redirectTo'],
          ),
        ),
    '/book/:id': (route) => Guard(
          validate: (info, context) => booksDatabase.books.any(
            (book) => book.id == info.pathParameters['id'],
          ),
          child: MaterialPage(
            child: BookPage(id: route.pathParameters['id']!),
          ),
        ),
    '/category/:category': (route) => Guard(
          validate: (info, context) =>
              _isValidCategory(route.pathParameters['category']),
          child: MaterialPage(
            child: CategoryPage(
              category: BookCategory.values.firstWhere(
                (e) => e.queryParam == route.pathParameters['category'],
              ),
            ),
          ),
        ),
    '/category/:category/book/:id': (route) => Guard(
          validate: (info, context) =>
              _isValidCategory(route.pathParameters['category']) &&
              _isValidBookId(route.pathParameters['id']),
          child: MaterialPage(
            child: BookPage(id: route.pathParameters['id']!),
          ),
        ),
    '/audiobooks': (route) => TabPage(
          child: AudiobookPage(),
          paths: ['all', 'picks'],
        ),
    '/audiobooks/all': (route) => MaterialPage(
          child: AudiobookListPage(mode: 'all'),
        ),
    '/audiobooks/picks': (route) => MaterialPage(
          child: AudiobookListPage(mode: 'picks'),
        ),
    '/audiobooks/book/:id': (route) {
      return Guard(
        validate: (info, context) => _isValidBookId(route.pathParameters['id']),
        child: MaterialPage(
          child: BookPage(id: route.pathParameters['id']!),
        ),
      );
    },
    '/search': (route) => MaterialPage(
          child: SearchPage(
            query: route.queryParameters['query'] ?? '',
            sortOrder: SortOrder.values.firstWhere(
              (e) => e.queryParam == route.queryParameters['sort'],
              orElse: () => SortOrder.name,
            ),
          ),
        ),
    '/wishlist': (route) => MaterialPage(child: WishlistHomePage()),
    '/wishlist/add': (route) => AddWishlistPage(),
    '/wishlist/shared/:id': (route) {
      return Guard(
        validate: (info, context) {
          final appState = Provider.of<AppState>(context, listen: false);
          return appState.isLoggedIn;
        },
        onValidationFailed: (route, context) {
          return Redirect(
            '/login',
            queryParameters: {'redirectTo': route.path},
          );
        },
        child: MaterialPage(
          child: WishlistPage(id: route.pathParameters['id']),
        ),
      );
    },
  },
);

final loggedOutRouteMap = RouteMap(
  routes: {
    '/': (route) => MaterialPage(child: LoginPage()),
  },
);

class BookStoreApp extends StatelessWidget {
  final String? username;
  final bool siteBlockedWithoutLogin;
  final RouteInformationProvider? routeInformationProvider;

  BookStoreApp({
    this.username,
    this.siteBlockedWithoutLogin = false,
    this.routeInformationProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(username: username),
      child: MaterialApp.router(
        title: 'Dashazon',
        theme: ThemeData(
          primaryColor: Color(0xFF131921),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: Color(0xfffebd68),
              onPrimary: Color(0xff333333),
            ),
          ),
          platform: TargetPlatform.macOS,
        ),
        routeInformationParser: RoutemasterParser(),
        routeInformationProvider: routeInformationProvider,
        routerDelegate: RoutemasterDelegate(
          transitionDelegate: NoAnimationTransitionDelegate(),
          routesBuilder: (context) {
            final state = Provider.of<AppState>(context);

            return siteBlockedWithoutLogin && !state.isLoggedIn
                ? loggedOutRouteMap
                : routeMap;
          },
        ),
      ),
    );
  }
}

class NoTransitionsTheme extends PageTransitionsTheme {
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return NoAnimationTransitionsBuilder()
        .buildTransitions(route, context, animation, secondaryAnimation, child);
  }
}

class NoAnimationTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class ShopHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "Dash's book shop",
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "All of Dash's lovely books...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Wrap(
            children: [
              for (final book in booksDatabase.books) BookCard(book: book),
            ],
          ),
        ],
      ),
    );
  }
}

class NoAnimationTransitionDelegate extends TransitionDelegate<void> {
  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    Map<RouteTransitionRecord?, List<RouteTransitionRecord>>?
        pageRouteToPagelessRoutes,
  }) {
    final results = <RouteTransitionRecord>[];

    for (final pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }

    for (final exitingPageRoute in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForRemove();
        final pagelessRoutes = pageRouteToPagelessRoutes![exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final pagelessRoute in pagelessRoutes) {
            pagelessRoute.markForRemove();
          }
        }
      }

      results.add(exitingPageRoute);
    }
    return results;
  }
}
