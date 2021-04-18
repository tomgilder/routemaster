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
          '/tabs': (_) => TabPage(child: MyTabPage(), paths: ['one', 'two']),
          '/tabs/one': (_) => MaterialPage<void>(child: PageOne()),
          '/tabs/two': (_) => MaterialPage<void>(child: PageTwo()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/tabs/one');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets('Can set page states on with parameters and query string',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/:id/tabs': (_) =>
              TabPage(child: MyTabPage(), paths: ['one', 'two']),
          '/:id/tabs/one': (_) => MaterialPage<void>(child: PageOne()),
          '/:id/tabs/two': (_) => MaterialPage<void>(child: PageTwo()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/myId/tabs/one?query=string');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);
  });

  testWidgets('Can push page on to tabs with route beginning with tab route',
      (tester) async {
    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(child: Container()),
          '/tabs': (_) => TabPage(child: MyTabPage(), paths: ['one', 'two']),
          '/tabs/one': (_) => MaterialPage<void>(child: PageOne()),
          '/tabs/two': (_) => MaterialPage<void>(child: PageTwo()),
          '/tabs/onepagethree': (_) => MaterialPage<void>(child: PageThree()),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.push('/tabs/one');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(find.byType(MyTabPage), findsOneWidget);
    expect(find.byType(PageOne), findsOneWidget);

    delegate.push('/tabs/onepagethree');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    expect(find.byType(PageThree), findsOneWidget);
  });

  testWidgets('TabController syncs with page state', (tester) async {
    final pageKey = GlobalKey();
    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      return RouteMap(routes: {
        '/': (_) => TabPage(
              paths: ['one', 'two'],
              child: TabbedPage(key: pageKey),
            ),
        '/one': (_) => MaterialPageOne(),
        '/two': (_) => MaterialPageTwo(),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    final pageState = TabPage.of(pageKey.currentContext!);
    final tabController = pageState.tabController;

    expect(pageState.index, 0);
    expect(tabController.index, 0);

    pageState.index = 1;
    expect(pageState.index, 1);
    expect(tabController.index, 1);

    tabController.index = 0;
    expect(pageState.index, 0);
    expect(tabController.index, 0);
  });
}

class TabbedPage extends StatelessWidget {
  TabbedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class MyTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stack = TabPage.of(context).stacks[0];

    return Container(
      height: 300,
      child: StackNavigator(stack: stack),
    );
  }
}
