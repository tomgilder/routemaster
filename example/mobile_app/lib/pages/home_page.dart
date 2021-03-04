import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:routemaster/routemaster.dart';

class HomePage extends StatefulWidget {
  final TabRouteState tabRoute;

  const HomePage({@required this.tabRoute});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tabController = CupertinoTabController();

  @override
  void initState() {
    super.initState();

    _tabController.addListener(() {
      widget.tabRoute.didSwitchTab(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
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
        final stackRoute = widget.tabRoute.routes[index];
        final pages = stackRoute.createPages();

        assert(pages.isNotEmpty, "Pages must not be empty");

        return Navigator(
          onPopPage: stackRoute.onPopPage,
          pages: pages,
        );
      },
    );
  }
}
