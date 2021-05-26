import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as test;

void main() {
  testWidgets('Can get observer updates from both RouterDelegate and Navigator',
      (tester) async {
    final delegateObserver = LoggingObserver();
    final navigatorObserver = LoggingObserver();

    await tester.pumpWidget(
      ObserverApp(
        delegateObservers: [delegateObserver],
        navigatorObservers: [navigatorObserver],
      ),
    );

    // Verify initial routes updates
    expect(navigatorObserver.log.length, 1);
    expect(navigatorObserver.log[0], isPush(name: 'FeedPage'));

    expect(delegateObserver.log.length, 3);
    expect(delegateObserver.log[0], isDidChangeRoute(path: '/feed'));
    expect(delegateObserver.log[1], isPush(name: null));
    expect(delegateObserver.log[2], isPush(name: 'FeedPage'));

    // Push page
    await tester.tap(find.text('Profile page'));
    await tester.pump();
    await tester.pump(kTransitionDuration);

    // Verify push updates
    expect(navigatorObserver.log.length, 2);
    expect(navigatorObserver.log[1], isPush(name: 'ProfilePage'));

    expect(delegateObserver.log.length, 5);
    expect(delegateObserver.log[3], isDidChangeRoute(path: '/feed/profile/1'));
    expect(delegateObserver.log[4], isPush(name: 'ProfilePage'));

    // Pop page
    await tester.tap(find.text('Pop'));
    await tester.pump();
    await tester.pump(kTransitionDuration);

    // Verify pop updates
    expect(navigatorObserver.log.length, 3);
    expect(navigatorObserver.log[2], isPop(name: 'ProfilePage'));

    expect(delegateObserver.log.length, 7);
    expect(delegateObserver.log[5], isDidChangeRoute(path: '/feed'));
    expect(delegateObserver.log[6], isPop(name: 'ProfilePage'));
  });

  testWidgets('Can switch RouterDelegate observers', (tester) async {
    final delegateObserver1 = LoggingObserver();
    final delegateObserver2 = LoggingObserver();

    await tester.pumpWidget(
      ObserverApp(
        delegateObservers: [delegateObserver1],
        navigatorObservers: const [],
      ),
    );

    expect(delegateObserver1.log.length, 3);

    await tester.pumpWidget(
      ObserverApp(delegateObservers: [delegateObserver2]),
    );

    await tester.tap(find.text('Profile page'));
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegateObserver1.log.length, 3);
    expect(delegateObserver2.log.length, 2);
  });

  testWidgets('Can switch Navigator observers', (tester) async {
    final navigatorObserver1 = LoggingObserver();
    final navigatorObserver2 = LoggingObserver();

    await tester.pumpWidget(
      ObserverApp(navigatorObservers: [navigatorObserver1]),
    );

    // Push page
    await tester.tap(find.text('Profile page'));
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(navigatorObserver1.log.length, 2);

    // Swap observer
    final state = tester.state(find.byType(HomePage)) as _HomePageState;
    // ignore: invalid_use_of_protected_member
    state.setState(() {
      state._observers = [navigatorObserver2];
    });
    await tester.pump();

    // Pop page
    await tester.tap(find.text('Pop'));
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(navigatorObserver1.log.length, 2);
    expect(navigatorObserver2.log.length, 1);
  });

  testWidgets('Observer relays all updates', (tester) async {
    final loggingObserver = LoggingObserver();
    await tester.pumpWidget(ObserverApp(delegateObservers: [loggingObserver]));

    final state = tester
        .stateList(find.byWidgetPredicate((widget) => widget is Navigator))
        .last as NavigatorState;
    final observer = state.widget.observers[0];

    observer.didPush(MockRoute(), MockRoute());
    expect(loggingObserver.log.last.runtimeType, DidPush);

    observer.didPop(MockRoute(), MockRoute());
    expect(loggingObserver.log.last.runtimeType, DidPop);

    observer.didRemove(MockRoute(), MockRoute());
    expect(loggingObserver.log.last.runtimeType, DidRemove);

    observer.didReplace(newRoute: MockRoute(), oldRoute: MockRoute());
    expect(loggingObserver.log.last.runtimeType, DidReplace);

    observer.didStartUserGesture(MockRoute(), MockRoute());
    expect(loggingObserver.log.last.runtimeType, DidStartUserGesture);

    observer.didStopUserGesture();
    expect(loggingObserver.log.last.runtimeType, DidStopUserGesture);
  });
}

class MockRoute extends Route<void> {}

class ObserverApp extends StatelessWidget {
  final List<RoutemasterObserver> delegateObservers;
  final List<NavigatorObserver> navigatorObservers;

  const ObserverApp({
    this.delegateObservers = const [],
    this.navigatorObservers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (_) => RouteMap(
          routes: {
            '/': (_) => CupertinoTabPage(
                  child: HomePage(navigatorObservers: navigatorObservers),
                  paths: const ['feed', 'settings'],
                ),
            '/feed': (_) => MaterialPage<void>(
                  child: FeedPage(),
                  name: 'FeedPage',
                ),
            '/feed/profile/:id': (_) => MaterialPage<void>(
                  child: ProfilePage(),
                  name: 'ProfilePage',
                ),
            '/settings': (_) => MaterialPage<void>(
                  child: SettingsPage(),
                  name: 'SettingsPage',
                ),
          },
        ),
        observers: delegateObservers,
      ),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<NavigatorObserver> navigatorObservers;

  const HomePage({required this.navigatorObservers});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NavigatorObserver>? _observers;

  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: (BuildContext context, int index) {
        final stack = tabState.stacks[index];
        return PageStackNavigator(
          stack: stack,
          observers: _observers ?? widget.navigatorObservers,
        );
      },
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
          children: [
            const Text('Profile page'),
            CupertinoButton(
              onPressed: () => Routemaster.of(context).pop(),
              child: const Text('Pop'),
            ),
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

class LoggingObserver extends RoutemasterObserver {
  final log = <ObserverLog>[];

  @override
  void didPush(Route route, Route? previousRoute) {
    log.add(DidPush(route: route, previousRoute: previousRoute));
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    log.add(DidPop(route: route, previousRoute: previousRoute));
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log.add(DidRemove(route: route, previousRoute: previousRoute));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    log.add(DidReplace(newRoute: newRoute, oldRoute: oldRoute));
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    log.add(DidStartUserGesture(route: route, previousRoute: previousRoute));
  }

  @override
  void didStopUserGesture() {
    log.add(DidStopUserGesture());
  }

  void expect(List<Type> expected) {
    test.expect(
      log.map((e) => e.runtimeType).toList(),
      expected,
    );
  }

  @override
  void didChangeRoute(RouteData routeData, Page page) {
    super.didChangeRoute(routeData, page);
    log.add(DidChangeRoute(routeData: routeData, page: page));
  }
}

class LoggingNavigatorObserver extends NavigatorObserver {
  final log = <ObserverLog>[];

  @override
  void didPush(Route route, Route? previousRoute) {
    log.add(DidPush(route: route, previousRoute: previousRoute));
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    log.add(DidPop(route: route, previousRoute: previousRoute));
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log.add(DidRemove(route: route, previousRoute: previousRoute));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    log.add(DidReplace(newRoute: newRoute, oldRoute: oldRoute));
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    log.add(DidStartUserGesture(route: route, previousRoute: previousRoute));
  }

  @override
  void didStopUserGesture() {
    log.add(DidStopUserGesture());
  }

  void expect(List<Type> expected) {
    test.expect(
      log.map((e) => e.runtimeType).toList(),
      expected,
    );
  }
}

abstract class ObserverLog {}

class DidPush extends ObserverLog {
  final Route route;
  final Route? previousRoute;

  DidPush({required this.route, required this.previousRoute});
}

class DidPop extends ObserverLog {
  final Route route;
  final Route? previousRoute;

  DidPop({required this.route, required this.previousRoute});
}

class DidRemove extends ObserverLog {
  final Route route;
  final Route? previousRoute;

  DidRemove({required this.route, required this.previousRoute});
}

class DidReplace extends ObserverLog {
  final Route<dynamic>? newRoute;
  final Route<dynamic>? oldRoute;

  DidReplace({required this.newRoute, required this.oldRoute});
}

class DidStartUserGesture extends ObserverLog {
  final Route route;
  final Route? previousRoute;

  DidStartUserGesture({required this.route, required this.previousRoute});
}

class DidStopUserGesture extends ObserverLog {}

class DidChangeRoute extends ObserverLog {
  final RouteData routeData;
  final Page page;

  DidChangeRoute({required this.routeData, required this.page});
}

IsPush isPush({String? name}) => IsPush(name);

class IsPush extends Matcher {
  final String? name;

  const IsPush(this.name);

  @override
  bool matches(dynamic item, Map matchState) =>
      item is DidPush && item.route.settings.name == name;

  @override
  Description describe(Description description) =>
      description.add(name ?? 'null');
}

IsPop isPop({String? name}) => IsPop(name);

class IsPop extends Matcher {
  final String? name;

  const IsPop(this.name);

  @override
  bool matches(dynamic item, Map matchState) =>
      item is DidPop && item.route.settings.name == name;

  @override
  Description describe(Description description) =>
      description.add(name ?? 'null');
}

IsDidChangeRoute isDidChangeRoute({required String path}) {
  return IsDidChangeRoute(path);
}

class IsDidChangeRoute extends Matcher {
  final String path;

  const IsDidChangeRoute(this.path);

  @override
  bool matches(dynamic item, Map matchState) =>
      item is DidChangeRoute && item.routeData.fullPath == path;

  @override
  Description describe(Description description) => description.add(path);
}
