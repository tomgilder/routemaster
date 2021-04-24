import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

void main() => runApp(MyApp());

final routes = RouteMap(
  routes: {
    '/': (_) => CupertinoTabPage(
          child: HomePage(),
          paths: ['feed', 'settings'],
        ),
    '/feed': (_) => MaterialPage(child: FeedPage()),
    '/feed/profile/:id': (_) => MaterialPage(child: ProfilePage()),
    '/settings': (_) => MaterialPage(child: SettingsPage()),
  },
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: RoutemasterDelegate(routesBuilder: (_) => routes),
      routeInformationParser: RoutemasterParser(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: tabState.tabBuilder,
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            label: 'Feed',
            icon: Icon(CupertinoIcons.list_bullet),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(CupertinoIcons.search),
          ),
        ],
      ),
    );
  }
}

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Routemaster.of(context).push('profile/1'),
          child: Text('Feed page'),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Profile page')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Settings page')));
  }
}
