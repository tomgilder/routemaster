import 'package:routemaster/routemaster.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  final IndexedRouteState tabRoute;

  const NotificationsPage({@required this.tabRoute});

  @override
  State<StatefulWidget> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _tabController = CupertinoTabController();

  @override
  void initState() {
    super.initState();

    _tabController.addListener(() {
      widget.tabRoute.index = _tabController.index;
    });
  }

  @override
  void didUpdateWidget(NotificationsPage oldWidget) {
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
            label: 'One',
            icon: Icon(CupertinoIcons.list_bullet),
          ),
          BottomNavigationBarItem(
            label: 'Two',
            icon: Icon(CupertinoIcons.search),
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

class NotificationsContentPage extends StatelessWidget {
  final String message;

  const NotificationsContentPage({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Column(
            children: [
              Text(message),
              ElevatedButton(
                onPressed: () => Routemaster.of(context)
                    .replaceNamed('/notifications/pushed'),
                child: Text('Push on top of tab stack'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class MessagePage extends StatelessWidget {
  final String message;

  const MessagePage({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
          ],
        ),
      ),
    );
  }
}
