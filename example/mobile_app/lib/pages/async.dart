import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Text('Loading...'),
    );
  }
}

final asyncRoutes = <String, PageBuilder>{
  '/async': (_) => AsyncPageBuilder(
        pageBuilder: (_) async* {
          await Future.delayed(Duration(seconds: 1));
          yield MaterialPage(
            child: Scaffold(
              appBar: AppBar(),
              body: Text('Loading...'),
            ),
          );
          await Future.delayed(Duration(seconds: 2));
          yield MaterialPage(
            child: Scaffold(
              appBar: AppBar(),
              body: Text('Welcome!'),
            ),
          );
        },
      ),
  '/async-redirect': (_) => AsyncPageBuilder(
        pageBuilder: (_) async* {
          yield MaterialPage(child: LoadingPage());
          await Future.delayed(Duration(seconds: 1));
          yield Redirect('/');
        },
      ),
  '/async-not-found': (_) => AsyncPageBuilder(
        pageBuilder: (_) async* {
          yield MaterialPage(child: LoadingPage());
          await Future.delayed(Duration(seconds: 1));
          yield NotFound();
        },
      ),
  '/async-tabs': (_) => AsyncPageBuilder(
        pageBuilder: (_) async* {
          yield TransitionPage(
            pushTransition: PageTransition.zoom,
            child: LoadingPage(),
          );
          await Future.delayed(Duration(seconds: 1));
          yield CupertinoTabPage(
            child: AsyncTabsPage(),
            paths: [
              '/search',
              '/search',
              '/search',
            ],
          );
        },
      ),
  '/async-cancel': (_) => AsyncPageBuilder(
        pageBuilder: (_) async* {
          yield MaterialPage(child: LoadingPage());
          await Future.delayed(Duration(seconds: 3));
          print('Redirecting...');
          yield Redirect('/search');
        },
      ),
  '/async-cancel-2': (_) {
    return AsyncPageBuilder(
      pageBuilder: (state) async* {
        yield MaterialPage(child: LoadingPage());

        if (state.isCancelled) {
          return;
        }

        await Future.delayed(Duration(seconds: 3));
        print('Redirecting...');
        yield Redirect('/search');
      },
    );
  },
};

class AsyncTabsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Test 1',
            icon: Icon(CupertinoIcons.list_bullet),
          ),
          BottomNavigationBarItem(
            label: 'Test 2',
            icon: Icon(CupertinoIcons.search),
          ),
          BottomNavigationBarItem(
            label: 'Test 3',
            icon: Icon(CupertinoIcons.bell),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return PageStackNavigator(
          key: ValueKey(tabState.page.paths[index]),
          stack: tabState.stacks[index],
        );
      },
    );
  }
}
