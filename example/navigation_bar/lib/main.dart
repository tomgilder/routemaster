import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (context) => RouteMap(
          routes: {
            '/': (_) => const IndexedPage(
                  child: NavigationBarPage(),
                  paths: ['/feed', '/settings'],
                ),
            '/feed': (_) => const MaterialPage(child: FeedPage()),
            '/settings': (_) => const MaterialPage(child: SettingsPage()),
            '/feed/profile/:id': (info) => MaterialPage(
                  child: ProfilePage(title: info.pathParameters['id']!),
                ),
          },
        ),
      ),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}

class NavigationBarPage extends StatelessWidget {
  const NavigationBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final indexedPage = IndexedPage.of(context);

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          indexedPage.index = index;
        },
        selectedIndex: indexedPage.index,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.commute),
            label: 'Settings',
          ),
        ],
      ),
      body: PageStackNavigator(
        stack: indexedPage.currentStack,
      ),
    );
  }
}

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Routemaster.of(context).push('/feed/profile/1'),
          child: const Text('Push profile 1'),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String title;

  const ProfilePage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings page')),
      body: const Center(child: Text('Settings')),
    );
  }
}
