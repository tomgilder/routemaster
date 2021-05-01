import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/pages/login_page.dart';
import 'pages/bottom_navigation_bar_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/search_page.dart';
import 'pages/feed_page.dart';
import 'pages/notifications_page.dart';
import 'pages/tab_bar_page.dart';

void main() {
  Routemaster.setPathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Routemaster Demo',
            routeInformationParser: RoutemasterParser(),
            routerDelegate: RoutemasterDelegate(
              routesBuilder: (context) {
                // We swap out the routing map at runtime based on app state
                final appState = Provider.of<AppState>(context);
                final isLoggedIn = appState.isLoggedIn;
                return isLoggedIn
                    ? _buildRouteMap(appState)
                    : loggedOutRouteMap;
              },
            ),
          );
        },
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  bool _showBonusTab = false;
  bool get showBonusTab => _showBonusTab;
  set showBonusTab(bool value) {
    _showBonusTab = value;
    notifyListeners();
  }
}

// This is the logged out route map.
// This only allows the user to navigate to the root path.
// Note: building the route map from methods allows hot reload to work
final loggedOutRouteMap = RouteMap(
  onUnknownRoute: (route, context) => Redirect('/'),
  routes: {
    '/': (_) => MaterialPage(child: LoginPage()),
  },
);

// This is the real route map - used if the user is logged in.
RouteMap _buildRouteMap(AppState appState) {
  return RouteMap(
    routes: {
      '/': (_) => CupertinoTabPage(
            child: HomePage(),
            paths: [
              '/feed',
              '/search',
              if (appState.showBonusTab) '/bonus',
              '/notifications',
              '/settings',
            ],
          ),
      '/feed': (_) => MaterialPage(child: FeedPage()),
      '/feed/profile/:id': (info) {
        return Guard(
          validate: (info, context) {
            return info.pathParameters['id'] == '1' ||
                info.pathParameters['id'] == '2';
          },
          onValidationFailed: (info, context) => Redirect('/feed'),
          pageBuilder: () => MaterialPage(
            child: ProfilePage(
              id: info.pathParameters['id'],
              message: info.queryParameters['message'],
            ),
          ),
        );
      },
      '/feed/profile/:id/photo': (info) => FancyAnimationPage(
            child: PhotoPage(id: info.pathParameters['id']),
          ),

      '/search': (_) => MaterialPage(child: SearchPage()),
      '/settings': (_) => MaterialPage(
            key: ValueKey('settings'),
            child: SettingsPage(),
          ),

      // Most pages tend to appear only in one place in the app
      // However sometimes you can push them into multiple places.
      // TODO: Is there a better way to do this? Such as an `Alias` page class?
      '/search/hero': (_) => MaterialPage(child: HeroPage()),
      '/settings/hero': (_) => MaterialPage(child: HeroPage()),

      // This gets really complicated to test out tested scenarios!
      '/notifications': (_) => IndexedPage(
            child: NotificationsPage(),
            paths: ['one', 'two'],
          ),
      '/notifications/one': (_) => MaterialPage(
            child: NotificationsContentPage(
              message: 'Page one',
            ),
          ),
      '/notifications/two': (_) => MaterialPage(
            child: NotificationsContentPage(message: 'Page two'),
          ),
      '/notifications/pushed': (_) => MaterialPage(
            child: MessagePage(message: 'Pushed notifications'),
          ),
      '/tab-bar': (_) => TabPage(
            child: TabBarPage(),
            paths: [
              'one',
              if (appState.showBonusTab) 'bonus',
              'settings',
            ],
          ),
      '/tab-bar/one': (_) => MaterialPage(child: MessagePage(message: 'One')),
      '/tab-bar/bonus': (_) => MaterialPage(
            child: MessagePage(message: 'BONUS!!'),
          ),
      '/tab-bar/settings': (_) => MaterialPage(child: SettingsPage()),
      '/bottom-navigation-bar-replace': (_) => MaterialPage(
            child: BottomNavigationBarReplacementPage(),
          ),
      '/bottom-navigation-bar': (_) => IndexedPage(
            child: BottomNavigationBarPage(),
            paths: ['one', 'two', 'three'],
          ),
      '/bottom-navigation-bar/one': (_) => MaterialPage(
            child: BottomContentPage(),
          ),
      '/bottom-navigation-bar/two': (_) => MaterialPage(
            child: BottomContentPage2(),
          ),
      '/bottom-navigation-bar/three': (_) => MaterialPage(
            child: MessagePage(message: 'Page three'),
          ),
      '/bottom-navigation-bar/sub-page': (_) => MaterialPage(
            child: DoubleBackPage(),
          ),
      '/bottom-navigation-bar/replaced': (_) => MaterialPage(
            child: MessagePage(message: 'Replaced'),
          ),
      '/bonus': (_) => MaterialPage(
            child: MessagePage(message: 'You found the bonus page!!!'),
          ),
    },
  );
}

// For custom animations, just use the existing Flutter [Page] and [Route] objects
class FancyAnimationPage extends Page {
  final Widget child;

  FancyAnimationPage({required this.child});

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, animation2) {
        final tween = Tween(begin: 0.0, end: 1.0);
        final curveTween = CurveTween(curve: Curves.easeInOut);

        return FadeTransition(
          opacity: animation.drive(curveTween).drive(tween),
          child: child,
        );
      },
    );
  }
}
