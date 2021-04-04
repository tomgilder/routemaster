import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/route_dart.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can push and pop a page via delegate pop()', (tester) async {
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (_) => MaterialPage<void>(child: PageTwo()),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);

    delegate.pop();
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);
  });

  testWidgets('Can push and pop a page via Navigator', (tester) async {
    final page2Key = GlobalKey();
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (_) => MaterialPage<void>(child: PageTwo(key: page2Key)),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);

    Navigator.of(page2Key.currentContext!).pop();
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);
  });

  testWidgets('Can push and pop a page via delegate', (tester) async {
    final page1Key = GlobalKey();
    final page2Key = GlobalKey();
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne(key: page1Key)),
        '/two': (_) => MaterialPage<void>(child: PageTwo(key: page2Key)),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    Routemaster.of(page1Key.currentContext!).push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);

    Routemaster.of(page2Key.currentContext!).pop();
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);
  });

  testWidgets('Can push and pop a page via system back button', (tester) async {
    final page1Key = GlobalKey();
    final page2Key = GlobalKey();
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne(key: page1Key)),
        '/two': (_) => MaterialPage<void>(child: PageTwo(key: page2Key)),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);

    await invokeSystemBack();
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);
  });

  testWidgets('Can push and pop a page with query string', (tester) async {
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (_) => MaterialPage<void>(child: PageTwo()),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.push('two?query=string');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two?query=string'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  test('popRoute returns false before stack built', () async {
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
      });
    });

    expect(await delegate.popRoute(), isFalse);
  });

  testWidgets('Can push a page via replace()', (tester) async {
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (_) => MaterialPage<void>(child: PageTwo()),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.currentConfiguration, RouteData('/'));
    expect(find.byType(PageOne), findsOneWidget);
    expect(find.byType(PageTwo), findsNothing);

    delegate.replace('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(delegate.currentConfiguration, RouteData('/two'));
    expect(find.byType(PageOne), findsNothing);
    expect(find.byType(PageTwo), findsOneWidget);
  });

  testWidgets('Can push a page with query string', (tester) async {
    late RouteInfo routeInfo;
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (info) {
          routeInfo = info;
          return MaterialPage<void>(child: PageTwo());
        },
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('two', queryParameters: {'query': 'string'});
    await tester.pump();

    expect(routeInfo.queryParameters['query'], 'string');
  });

  test('Stack routeInfo delegates to last child', () {
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {});
    });

    final lastRouteInfo = RouteInfo('/last');
    final stack = StackPageState(
      delegate: delegate,
      routes: [
        StatelessPage(
          page: MaterialPageOne(),
          routeInfo: RouteInfo('/'),
        ),
        StatelessPage(
          page: MaterialPageTwo(),
          routeInfo: lastRouteInfo,
        ),
      ],
    );

    expect(stack.routeInfo, lastRouteInfo);
  });

  test('Stack.maybePop() pops with no navigator', () async {
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {});
    });

    final lastRouteInfo = RouteInfo('/last');
    final stack = StackPageState(
      delegate: delegate,
      routes: [
        StatelessPage(
          page: MaterialPageOne(),
          routeInfo: RouteInfo('/'),
        ),
        StatelessPage(
          page: MaterialPageTwo(),
          routeInfo: lastRouteInfo,
        ),
      ],
    );

    expect(await stack.maybePop(), isTrue);
  });

  test('Stack.maybePop() returns false with one child', () async {
    final delegate = Routemaster(routesBuilder: (context) {
      return RouteMap(routes: {});
    });

    final stack = StackPageState(
      delegate: delegate,
      routes: [
        StatelessPage(page: MaterialPageOne(), routeInfo: RouteInfo('/')),
      ],
    );

    expect(await stack.maybePop(), isFalse);
  });

  testWidgets('Can pop stack within tabs via system back', (tester) async {
    final delegate = Routemaster(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) => TabPage(child: MyTabPage(), paths: ['one', 'two']),
          '/tabs/one': (_) => MaterialPageOne(),
          '/tabs/one/subpage': (_) => MaterialPageThree(),
          '/tabs/two': (_) => MaterialPageTwo(),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(
            location: '/tabs/one/subpage',
          ),
        ),
        routerDelegate: delegate,
      ),
    );

    expect(find.byType(PageThree), findsOneWidget);
    await invokeSystemBack();
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageThree), findsNothing);
  });
}

class MyTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tab = TabPage.of(context).stacks[0];

    return Container(
      height: 300,
      child: Navigator(
        pages: tab.createPages(),
        onPopPage: tab.onPopPage,
        key: tab.navigatorKey,
      ),
    );
  }
}
