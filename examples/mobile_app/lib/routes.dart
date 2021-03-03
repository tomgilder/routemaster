import 'package:mobile_app/pages/login_page.dart';
import 'package:routemaster/routemaster.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/search_page.dart';
import 'pages/feed_page.dart';
import 'pages/notifications_page.dart';

final loggedOutRouteMap = [
  WidgetRoute('/', (_) => LoginPage()),
];

final routeMap = [
  TabRoute(
    '/',
    (_, tabRoute) => HomePage(tabRoute: tabRoute),
    paths: [
      '/feed',
      '/search',
      '/notifications',
      '/settings',
    ],
  ),
  WidgetRoute('/feed', (_) => FeedPage()),
  WidgetRoute(
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
  WidgetRoute(
    '/feed/profile/:id/photo',
    (info) => PhotoPage(id: info.pathParameters['id']),
  ),
  WidgetRoute('/search', (_) => SearchPage()),
  WidgetRoute('/notifications', (_) => NotificationsPage()),
  WidgetRoute('/settings', (_) => SettingsPage()),
];
