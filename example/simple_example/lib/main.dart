import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

void main() => runApp(MyApp());

final plans = [
  CupertinoTabPlan(
    '/',
    (info, routeState) => HomePage(routeState: routeState),
    paths: ['/feed', '/settings'],
  ),
  WidgetPlan('/feed', (info) => FeedPage()),
  WidgetPlan('/feed/profile/:id', (info) => ProfilePage()),
  WidgetPlan('/settings', (info) => SettingsPage()),
];

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Routemaster _delegate = Routemaster(plans: plans);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _delegate,
      routeInformationParser: RoutemasterParser(),
    );
  }
}

class HomePage extends StatelessWidget {
  final CupertinoTabRouteState routeState;

  const HomePage({@required this.routeState});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: routeState.tabController,
      tabBuilder: routeState.tabBuilder,
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
          onPressed: () => Routemaster.of(context).pushNamed('profile/1'),
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
