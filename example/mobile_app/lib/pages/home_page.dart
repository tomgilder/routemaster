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
      widget.tabRoute.index = _tabController.index;
    });
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    _tabController.index = widget.tabRoute.index;
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
        final stack = widget.tabRoute.getStackForIndex(index);
        final pages = stack.createPages();

        assert(pages.isNotEmpty, "Pages must not be empty");

        return Navigator(
          // observers: [HeroController()],
          onPopPage: stack.onPopPage,
          pages: pages,
        );
      },
    );
  }
}
