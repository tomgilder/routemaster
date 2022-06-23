import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can set page states on tabs', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) =>
              TabPage(child: MyTabPage(), paths: const ['one', 'two']),
          '/tabs/one': (_) => const MaterialPageOne(),
          '/tabs/two': (_) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/tabs/one');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets('Can set page states on tabs with absolute paths',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) => TabPage(child: MyTabPage(), paths: const [
                '/tabs/one',
                '/tabs/two',
              ]),
          '/tabs/one': (_) => const MaterialPageOne(),
          '/tabs/two': (_) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/tabs/one');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets('Can navigate from a tab with a query string', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) => TabPage(child: MyTabPage(), paths: const [
                '/tabs/one',
                '/tabs/two',
              ]),
          '/tabs/one': (_) => const MaterialPageOne(),
          '/tabs/two': (_) => const MaterialPageTwo(),
          '/tabs/one/subpage': (_) => const MaterialPageThree(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/tabs/one?query=string');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);

    delegate.push('subpage');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(PageThree), findsOneWidget);
  });

  testWidgets('Can use relative tab paths with query strings', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) => TabPage(child: MyTabPage(), paths: const [
                '/tabs/one?a=b',
                '/tabs/two?c=d',
              ]),
          '/tabs/one': (_) => const MaterialPageOne(),
          '/tabs/two': (_) => const MaterialPageTwo(),
          '/tabs/one/subpage': (_) => const MaterialPageThree(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/tabs/one?query=string');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);

    delegate.push('subpage');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(PageThree), findsOneWidget);
  });

  testWidgets('Can use absolute tab paths with query strings', (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) => TabPage(child: MyTabPage(), paths: const [
                '/tabs/one?a=b',
                '/tabs/two?c=d',
              ]),
          '/tabs/one': (_) => const MaterialPageOne(),
          '/tabs/two': (_) => const MaterialPageTwo(),
          '/tabs/one/subpage': (_) => const MaterialPageThree(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/tabs/one?query=string');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);

    delegate.push('subpage');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(PageThree), findsOneWidget);
  });

  testWidgets('Can set page states on tabs with parameters and query string',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/:id/tabs': (_) =>
              TabPage(child: MyTabPage(), paths: const ['one', 'two']),
          '/:id/tabs/one': (_) => const MaterialPageOne(),
          '/:id/tabs/two': (_) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/myId/tabs/one?query=string');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets(
      'Can set page states on tabs with absolute path, parameters and query string',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/:id/tabs': (routeData) {
            final id = routeData.pathParameters['id'];
            return TabPage(
              child: MyTabPage(),
              paths: ['/$id/tabs/one', '/$id/tabs/two'],
            );
          },
          '/:id/tabs/one': (_) => const MaterialPageOne(),
          '/:id/tabs/two': (_) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/myId/tabs/one?query=string');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets('Can push page on to tabs with route beginning with tab route',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) =>
              TabPage(child: MyTabPage(), paths: const ['one', 'two']),
          '/tabs/one': (_) => const MaterialPageOne(),
          '/tabs/two': (_) => const MaterialPageTwo(),
          '/tabs/onepagethree': (_) => const MaterialPageThree(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/tabs/one');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);

    delegate.push('/tabs/onepagethree');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MyTabPage), findsNothing);
    expect(find.byType(PageThree), findsOneWidget);
  });

  testWidgets(
      'Can push page on to tabs with route beginning with tab route, plus absolute paths',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) => TabPage(
              child: MyTabPage(), paths: const ['/tabs/one', '/tabs/two']),
          '/tabs/one': (_) => const MaterialPageOne(),
          '/tabs/two': (_) => const MaterialPageTwo(),
          '/tabs/onepagethree': (_) => const MaterialPageThree(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/tabs/one');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);

    delegate.push('/tabs/onepagethree');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(PageThree), findsOneWidget);
  });

  testWidgets('TabController syncs with page state', (tester) async {
    final pageKey = GlobalKey();
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => TabPage(
              paths: const ['one', 'two'],
              child: TabbedPage(key: pageKey),
            ),
        '/one': (_) => const MaterialPageOne(),
        '/two': (_) => const MaterialPageTwo(),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final pageState = TabPage.of(pageKey.currentContext!);
    final tabController = pageState.controller;

    expect(pageState.index, 0);
    expect(tabController.index, 0);

    pageState.index = 1;
    expect(pageState.index, 1);
    expect(tabController.index, 1);

    tabController.index = 0;
    expect(pageState.index, 0);
    expect(tabController.index, 0);
  });

  testWidgets('Tab controller gets set on widget update', (tester) async {
    var buildCount = 0;
    TabController? controller;

    final page = TabPage(
      child: Builder(
        builder: (BuildContext context) {
          buildCount++;
          controller = TabPage.of(context).controller;
          return Container();
        },
      ),
      paths: const ['path'],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
          return RouteMap(routes: {
            '/': (_) => page,
            '/path': (_) => const MaterialPageOne(),
          });
        }),
      ),
    );

    expect(buildCount, 1);
    expect(controller, isNotNull);
    final oldController = controller;

    // This causes _TabControllerProvider.didUpdateWidget to be called
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
          return RouteMap(routes: {
            '/': (_) => page,
            '/path': (_) => const MaterialPageOne(),
          });
        }),
      ),
    );

    expect(buildCount, 2);
    expect(oldController, controller);
  });

  testWidgets('Tab controller gets recreated when tab length changes',
      (tester) async {
    TabController? controller;

    // Show one tab
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
          return RouteMap(routes: {
            '/': (_) => TabPage(
                  child: Builder(
                    builder: (BuildContext context) {
                      controller = TabPage.of(context).controller;
                      return Container();
                    },
                  ),
                  paths: const ['/one'],
                ),
            '/one': (_) => const MaterialPageOne(),
          });
        }),
      ),
    );

    expect(controller!.length, 1);

    // Add a second tab
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
          return RouteMap(routes: {
            '/': (_) => TabPage(
                  child: Builder(
                    builder: (BuildContext context) {
                      controller = TabPage.of(context).controller;
                      return Container();
                    },
                  ),
                  paths: const ['/one', '/two'],
                ),
            '/one': (_) => const MaterialPageOne(),
            '/two': (_) => const MaterialPageTwo(),
          });
        }),
      ),
    );

    // Controller should have been recreated
    expect(controller!.length, 2);
  });

  test("CupertinoTabPage.of asserts if it can't find widget", () {
    expect(
      () => CupertinoTabPage.of(FakeBuildContext()),
      throwsA(predicate((e) =>
          e is AssertionError &&
          e.message ==
              "Couldn't find a CupertinoTabPageState from the given context.")),
    );
  });

  test("IndexedPage.of asserts if it can't find widget", () {
    expect(
      () => IndexedPage.of(FakeBuildContext()),
      throwsA(predicate((e) =>
          e is AssertionError &&
          e.message ==
              "Couldn't find an IndexedPageState from the given context.")),
    );
  });

  test("TabPage.of asserts if it can't find widget", () {
    expect(
      () => TabPage.of(FakeBuildContext()),
      throwsA(predicate((e) =>
          e is AssertionError &&
          e.message == "Couldn't find a TabPageState from the given context.")),
    );
  });

  testWidgets('Can use custom page with TabPage', (tester) async {
    const key = Key('custom');
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => TabPage(
                child: MyTabPage(),
                paths: const ['/one', '/two'],
                pageBuilder: (child) => CupertinoPage<void>(
                  child: Container(key: key, child: child),
                ),
              ),
          '/one': (_) => const MaterialPageOne(),
          '/two': (_) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byKey(key), findsOneWidget);
  });

  testWidgets('No history entries created with TabBackBehavior.none',
      (tester) async {
    final pageKey = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => TabPage(
                child: BasicTabPage(key: pageKey),
                paths: const ['one', 'two', 'three'],
              ),
          '/one': (_) => const MaterialPageOne(),
          '/two': (_) => const MaterialPageTwo(),
          '/three': (_) => const MaterialPageThree(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageOne), findsOneWidget);
    final pageState = TabPage.of(pageKey.currentContext!);
    pageState.index = 1;
    await tester.pump();
    expect(find.byType(PageTwo), findsOneWidget);
    expect(delegate.history.canGoBack, isFalse);
    expect(delegate.history.canGoForward, isFalse);
  });

  testWidgets('Creates history entries with TabBackBehavior.history',
      (tester) async {
    final pageKey = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => TabPage(
                child: BasicTabPage(key: pageKey),
                paths: const ['one', 'two', 'three'],
                backBehavior: TabBackBehavior.history,
              ),
          '/one': (_) => const MaterialPageOne(),
          '/two': (_) => const MaterialPageTwo(),
          '/three': (_) => const MaterialPageThree(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final pageState = TabPage.of(pageKey.currentContext!);

    // Go to page 3
    pageState.index = 2;
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);

    // Go to page 2
    pageState.index = 1;
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);
    expect(delegate.history.canGoBack, isTrue);
    expect(delegate.history.canGoForward, isFalse);

    // On page 2, go back to page 3
    delegate.history.back();
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
    expect(delegate.history.canGoBack, isTrue);
    expect(delegate.history.canGoForward, isTrue);

    // On page 3, go back to page 1
    delegate.history.back();
    await tester.pumpPageTransition();
    expect(find.byType(PageOne), findsOneWidget);
    expect(delegate.history.canGoBack, isFalse);
    expect(delegate.history.canGoForward, isTrue);

    // On page 1, go forward to page 3
    delegate.history.forward();
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
    expect(delegate.history.canGoBack, isTrue);
    expect(delegate.history.canGoForward, isTrue);

    // On page 3, go forward to page 2
    delegate.history.forward();
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);
    expect(delegate.history.canGoBack, isTrue);
    expect(delegate.history.canGoForward, isFalse);
  });

  testWidgets('Can get RouteData for first inactive tab', (tester) async {
    final pageOneKey = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const TabPage(
                child: BothTabsPage(),
                paths: ['/one', '/two'],
              ),
          '/one': (_) => MaterialPage<void>(child: PageOne(key: pageOneKey)),
          '/two': (_) => const MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/two');
    await tester.pump();

    expect(find.byType(PageTwo), findsOneWidget);
    final routeData = RouteData.of(pageOneKey.currentContext!);
    expect(routeData.fullPath, '/one');
  });

  testWidgets('Can get RouteData for last inactive tab', (tester) async {
    final pageTwoKey = GlobalKey();
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const TabPage(
                child: BothTabsPage(),
                paths: ['/one', '/two'],
              ),
          '/one': (_) => const MaterialPageOne(),
          '/two': (_) => MaterialPage<void>(child: PageTwo(key: pageTwoKey)),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageOne), findsOneWidget);
    final routeData = RouteData.of(pageTwoKey.currentContext!);
    expect(routeData.fullPath, '/two');
  });
}

class StubRoutemaster implements Routemaster {
  @override
  Future<bool> pop<T extends Object?>([T? result]) {
    throw UnimplementedError();
  }

  @override
  NavigationResult<T> push<T extends Object?>(String path,
      {Map<String, String>? queryParameters}) {
    return StubNavigationResult<T>();
  }

  @override
  void replace(String path, {Map<String, String>? queryParameters}) {}

  @override
  RouteData get currentRoute => throw UnimplementedError();

  @override
  Future<void> popUntil(bool Function(RouteData routeData) predicate) {
    throw UnimplementedError();
  }

  @override
  RouteHistory get history => throw UnimplementedError();
}

class StubNavigationResult<T> implements NavigationResult<T> {
  @override
  Future<Route> get route => throw UnimplementedError();

  @override
  Future<T?> get result => throw UnimplementedError();
}

class TabbedPage extends StatelessWidget {
  const TabbedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class MyTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stack = TabPage.of(context).stacks[0];

    return SizedBox(
      height: 300,
      child: PageStackNavigator(stack: stack),
    );
  }
}

class BasicTabPage extends StatelessWidget {
  const BasicTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stack = TabPage.of(context).currentStack;

    return Scaffold(
      body: PageStackNavigator(stack: stack),
    );
  }
}

class BothTabsPage extends StatelessWidget {
  const BothTabsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageStackNavigator(stack: TabPage.of(context).stacks[0]),
        ),
        Expanded(
            child: PageStackNavigator(stack: TabPage.of(context).stacks[1])),
      ],
    );
  }
}
