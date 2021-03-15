import 'package:routemaster/routemaster.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  IndexedPageState _pageState;
  final _tabController = CupertinoTabController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageState = IndexedPageState.of(context);
  }

  @override
  void initState() {
    super.initState();

    _tabController.addListener(() {
      _pageState.index = _tabController.index;
    });
  }

  @override
  void didUpdateWidget(NotificationsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    _tabController.index = _pageState.index;
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
        final tabPageState = IndexedPageState.of(context);
        final stack = tabPageState.getStackForIndex(index);

        return Navigator(
          // observers: [HeroController()],
          onPopPage: stack.onPopPage,
          pages: stack.createPages(),
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
                    .setLocation('/notifications/pushed'),
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
