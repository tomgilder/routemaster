import 'package:flutter/cupertino.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (BuildContext context) {
          return RouteMap(
            routes: {
              '/': (_) => const MaterialPage<void>(child: HomePage()),
              '/one': (_) => const MaterialPage<void>(child: PageOne()),
              '/two': (_) => const MaterialPage<void>(child: PageTwo()),
              '/tabs': (_) => const CupertinoTabPage(
                    paths: const ['/tabs/one', '/tabs/two'],
                    child: TabbedPage(),
                  ),
              '/tabs/one': (_) => const MaterialPage<void>(child: PageOne()),
              '/tabs/two': (_) => const MaterialPage<void>(child: PageTwo()),
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () => Routemaster.of(context).replace('/one'),
            child: const Text('Replace page one'),
          ),
          ElevatedButton(
            onPressed: () => Routemaster.of(context).push('/one'),
            child: const Text('Push page one'),
          ),
          ElevatedButton(
            onPressed: () => Routemaster.of(context).push('/tabs'),
            child: const Text('Replace tabs'),
          ),
        ],
      ),
    );
  }
}

class PageOne extends StatelessWidget {
  const PageOne({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () => Routemaster.of(context).replace('/two'),
            child: const Text('Replace page two'),
          ),
          ElevatedButton(
            onPressed: () => Routemaster.of(context).push('/two'),
            child: const Text('Push page two'),
          ),
        ],
      ),
    );
  }
}

class PageTwo extends StatelessWidget {
  const PageTwo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: const [Text('Page two')],
      ),
    );
  }
}

class TabbedPage extends StatelessWidget {
  const TabbedPage({Key key}) : super(key: key);

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
