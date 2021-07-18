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

RouteMap _buildRouteMap(BuildContext context) {
  return RouteMap(
    onUnknownRoute: (path) {
      return NoAnimationPage(
        child: PageScaffold(
          title: 'Page not found',
          body: Center(
            child: Text(
              "Couldn't find page '$path'",
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
        ),
      );
    },
    routes: {
      '/': (route) => NoAnimationPage(child: ShopHome()),
      '/login': (route) => NoAnimationPage(
            child: LoginPage(
              redirectTo: route.queryParameters['redirectTo'],
            ),
          ),
      '/book/:id': (route) => _isValidBookId(route.pathParameters['id'])
          ? NoAnimationPage(child: BookPage(id: route.pathParameters['id']!))
          : NotFound(),
      '/category/:category': (route) =>
          _isValidCategory(route.pathParameters['category'])
              ? NoAnimationPage(
                  child: CategoryPage(
                    category: BookCategory.values.firstWhere(
                      (e) => e.queryParam == route.pathParameters['category'],
                    ),
                  ),
                )
              : NotFound(),
      '/category/:category/book/:id': (route) => _isValidCategory(
                  route.pathParameters['category']) &&
              _isValidBookId(route.pathParameters['id'])
          ? NoAnimationPage(child: BookPage(id: route.pathParameters['id']!))
          : NotFound(),
      '/audiobooks': (route) => TabPage(
            child: AudiobookPage(),
            paths: ['all', 'picks'],
            pageBuilder: (child) => NoAnimationPage(child: child),
          ),
      '/audiobooks/all': (route) => NoAnimationPage(
            child: AudiobookListPage(mode: 'all'),
          ),
      '/audiobooks/picks': (route) => NoAnimationPage(
            child: AudiobookListPage(mode: 'picks'),
          ),
      '/audiobooks/book/:id': (route) =>
          _isValidBookId(route.pathParameters['id'])
              ? NoAnimationPage(
                  child: BookPage(id: route.pathParameters['id']!),
                )
              : NotFound(),
      '/search': (route) => NoAnimationPage(
              child: SearchPage(
            query: route.queryParameters['query'] ?? '',
            sortOrder: SortOrder.values.firstWhere(
              (e) => e.queryParam == route.queryParameters['sort'],
              orElse: () => SortOrder.name,
            ),
          )),
      '/wishlist': (route) => NoAnimationPage(child: WishlistHomePage()),
      '/wishlist/add': (route) => AddWishlistPage(),
      '/wishlist/shared/:id': (route) {
        final appState = Provider.of<AppState>(context, listen: false);

        if (appState.isLoggedIn) {
          return NoAnimationPage(
            child: WishlistPage(id: route.pathParameters['id']),
          );
        }

        return Redirect('/login', queryParameters: {'redirectTo': route.path});
      },
    },
  );
}

final loggedOutRouteMap = RouteMap(
  routes: {
    '/': (route) => NoAnimationPage(child: LoginPage()),
  },
);

class NoAnimationPage<T> extends TransitionPage<T> {
  NoAnimationPage({required Widget child})
      : super(
          child: child,
          pushTransition: PageTransition.none,
          popTransition: PageTransition.none,
        );
}

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
          routesBuilder: (context) {
            final state = Provider.of<AppState>(context);

            return siteBlockedWithoutLogin && !state.isLoggedIn
                ? loggedOutRouteMap
                : _buildRouteMap(context);
          },
        ),
      ),
    );
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
