import 'package:flutter/material.dart';
import 'package:mobile_app/pages/login_page.dart';
import 'package:routemaster/routemaster.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/search_page.dart';
import 'pages/feed_page.dart';
import 'pages/notifications_page.dart';

final loggedOutRouteMap = [
  WidgetPlan('/', (_) => LoginPage()),
];

final routeMap = [
  TabPlan(
    '/',
    (_, tabRoute) => HomePage(tabRoute: tabRoute),
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
  WidgetPlan('/notifications', (_) => NotificationsPage()),
  WidgetPlan('/settings', (_) => SettingsPage()),
];

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
