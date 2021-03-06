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

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Routemaster _routemaster = Routemaster();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Builder(
        builder: (context) {
          final isLoggedIn = Provider.of<AppState>(context).isLoggedIn;

          return MaterialApp.router(
            title: 'Routemaster Demo',
            routeInformationParser: RoutemasterParser(),
            // We swap out the routing plan at runtime based on app state
            routerDelegate: _routemaster
              ..plans = isLoggedIn ? routeMap : loggedOutRouteMap,
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
}

// This is the logged out route map.
// This only allows the user to navigate to the root path.
final loggedOutRouteMap = [
  WidgetPlan('/', (_) => LoginPage()),
];

// This is the real route map - used if the user is logged in.
final routeMap = [
  CupertinoTabPlan(
    '/',
    (_, tabRoute) {
      return HomePage(tabRoute: tabRoute);
    },
    paths: [
      '/feed',
      '/search',
      '/notifications',
      '/settings',
    ],
  ),
  WidgetPlan('/feed', (_) => FeedPage()),
  WidgetPlan(
    '/feed/profile/:id',
    (info) => ProfilePage(
      id: info.pathParameters['id'],
      message: info.queryParameters['message'],
    ),
    validate: (info) {
      return info.pathParameters['id'] == '1' ||
          info.pathParameters['id'] == '2';
    },
    onValidationFailed: (rm, info) {
      rm.replaceNamed('/feed');
    },
  ),
  PagePlan(
    '/feed/profile/:id/photo',
    (info) => FancyAnimationPage(
      child: PhotoPage(id: info.pathParameters['id']),
    ),
  ),
  WidgetPlan('/search', (_) => SearchPage()),
  WidgetPlan('/settings', (_) => SettingsPage()),

  // Most pages tend to appear only in one place in the app
  // However sometimes you can push them into multiple places, such as different
  // tabs. Use `Plan.routes` for this.
  WidgetPlan.routes(
    ['/search/hero', '/settings/hero'],
    (_) => HeroPage(),
  ),

  // This gets really complicated to test out tested scenarios!
  IndexedPlan(
    '/notifications',
    (_, tabRoute) => NotificationsPage(tabRoute: tabRoute),
    paths: [
      '/notifications/one',
      '/notifications/two',
    ],
  ),
  WidgetPlan(
    '/notifications/one',
    (_) => NotificationsContentPage(
      message: 'Page one',
    ),
  ),
  WidgetPlan(
    '/notifications/two',
    (_) => NotificationsContentPage(message: 'Page two'),
  ),
  WidgetPlan(
    '/notifications/pushed',
    (_) => MessagePage(message: 'Pushed notifications'),
  ),
  IndexedPlan(
    '/bottom-navigation-bar',
    (_, routeState) => BottomNavigationBarPage(routeState: routeState),
    paths: [
      '/bottom-navigation-bar/one',
      '/bottom-navigation-bar/two',
      '/bottom-navigation-bar/three',
    ],
  ),
  WidgetPlan(
    '/bottom-navigation-bar/one',
    (_) => MessagePage(message: 'Page one'),
  ),
  WidgetPlan(
    '/bottom-navigation-bar/two',
    (_) => MessagePage(message: 'Page two'),
  ),
  WidgetPlan(
    '/bottom-navigation-bar/three',
    (_) => MessagePage(message: 'Page three'),
  ),
];

// For custom animations, just use the existing Flutter [Page] and [Route] objects
class FancyAnimationPage extends Page<void> {
  final Widget child;

  FancyAnimationPage({@required this.child});

  Route createRoute(BuildContext context) {
    return PageRouteBuilder<void>(
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
