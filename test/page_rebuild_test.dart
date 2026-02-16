import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  testWidgets('Stateful widgets are not recreated when delegate changes',
      (tester) async {
    final tracker1 = Tracker();
    final tracker2 = Tracker();
    final tracker3 = Tracker();

    final routes = <String, PageBuilder>{
      '/': (_) => CupertinoTabPage(
            child: HomePage(tracker: tracker1),
            paths: const ['feed', 'settings'],
          ),
      '/feed': (_) => MaterialPage<void>(
            child: InitStateTracker(tracker: tracker2),
          ),
      '/settings': (_) => MaterialPage<void>(
            child: InitStateTracker(tracker: tracker3),
          ),
    };

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(routes: routes),
        ),
      ),
    );

    expect(tracker1.initStateCount, 1);
    expect(tracker2.initStateCount, 1);
    expect(tracker3.initStateCount, 0);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(routes: routes),
        ),
      ),
    );

    expect(tracker1.initStateCount, 1);
    expect(tracker2.initStateCount, 1);
    expect(tracker3.initStateCount, 0);
  });

  testWidgets(
      'Stateful widgets are not recreated when same delegate is rebuilt',
      (tester) async {
    final tracker1 = Tracker();
    final tracker2 = Tracker();
    final tracker3 = Tracker();

    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(routes: {
        '/': (_) => CupertinoTabPage(
              child: HomePage(tracker: tracker1),
              paths: const ['feed', 'settings'],
            ),
        '/feed': (_) => MaterialPage<void>(
              child: InitStateTracker(tracker: tracker2),
            ),
        '/settings': (_) => MaterialPage<void>(
              child: InitStateTracker(tracker: tracker3),
            ),
      }),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(tracker1.initStateCount, 1);
    expect(tracker2.initStateCount, 1);
    expect(tracker3.initStateCount, 0);

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(tracker1.initStateCount, 1);
    expect(tracker2.initStateCount, 1);
    expect(tracker3.initStateCount, 0);
  });
}

class Tracker {
  var initStateCount = 0;
}

class InitStateTracker extends StatefulWidget {
  final Tracker tracker;

  const InitStateTracker({required this.tracker});

  @override
  _InitStateTrackerState createState() => _InitStateTrackerState();
}

class _InitStateTrackerState extends State<InitStateTracker> {
  @override
  void initState() {
    super.initState();
    widget.tracker.initStateCount++;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class HomePage extends StatefulWidget {
  final Tracker tracker;

  const HomePage({required this.tracker});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.tracker.initStateCount++;
  }

  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: tabState.tabBuilder,
      tabBar: CupertinoTabBar(
        items: const [
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
          child: const Text('Profile page'),
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
      body: Center(
        child: Column(
          children: const [
            Text('Profile page'),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Settings page')));
  }
}

class TabbedPage extends StatelessWidget {
  const TabbedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
