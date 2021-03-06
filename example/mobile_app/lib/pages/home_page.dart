import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:routemaster/routemaster.dart';

class HomePage extends StatelessWidget {
  final CupertinoTabRouteState tabRoute;

  const HomePage({@required this.tabRoute});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: tabRoute.tabController,
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Feed',
            icon: Icon(CupertinoIcons.list_bullet),
          ),
          BottomNavigationBarItem(
            label: 'Search',
            icon: Icon(CupertinoIcons.search),
          ),
          BottomNavigationBarItem(
            label: 'Notifications',
            icon: Icon(CupertinoIcons.bell),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(CupertinoIcons.settings),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        final stack = tabRoute.getStackForIndex(index);
        final pages = stack.createPages();

        assert(pages.isNotEmpty, "Pages must not be empty");

        return Navigator(
          onPopPage: stack.onPopPage,
          pages: pages,
        );
      },
    );
  }
}

class RoutemasterCupertinoTabController extends CupertinoTabController {
  final IndexedRouteState state;

  RoutemasterCupertinoTabController(this.state) {
    state.addListener(() {
      if (state.index != this.index) {
        this.index = state.index;
      }
    });

    this.addListener(() {
      state.index = this.index;
    });
  }
}
