import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets("Doesn't rebuild root tab page when page pushed on top",
      (tester) async {
    await recordUrlChanges((systemUrl) async {
      final delegate = RoutemasterDelegate(
        routesBuilder: (BuildContext context) {
          return RouteMap(
            routes: {
              '/': (_) => const Redirect('/home/1'),
              '/home/:homeId': (_) {
                return TabPage(
                  child: HomePage(),
                  paths: const ['one', 'two'],
                );
              },
              '/home/:homeId/one': (_) => const MaterialPageOne(),
              '/home/:homeId/two': (_) => const MaterialPageTwo(),
              '/home/:homeId/two/edit': (_) => const MaterialPageThree(),
              '/home/:homeId/eq/:eqId': (route) {
                return MaterialPage<void>(
                  key: ValueKey(route.pathParameters['eqId']!),
                  child: const EchoPage(),
                );
              },
            },
          );
        },
      );

      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: delegate,
      ));

      expect(find.byType(PageOne), findsOneWidget);
      expect(find.byType(PageTwo), findsNothing);

      // Switch to second tab

      delegate.push('/home/1/two');
      await tester.pumpPageTransition();

      expect(find.byType(PageOne), findsNothing);
      expect(find.byType(PageTwo), findsOneWidget);

      expect(systemUrl.current, '/home/1/two');

      // Push within tab view

      delegate.push('/home/1/two/edit');
      await tester.pumpPageTransition();
      expect(find.byType(PageThree), findsOneWidget);

      expect(systemUrl.current, '/home/1/two/edit');

      // Push over tab view

      delegate.push('/home/1/eq/1');
      await tester.pumpPageTransition();
      expect(find.byType(EchoPage), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      expect(systemUrl.current, '/home/1/eq/1');

      // Replace pushed page with another

      delegate.push('/home/1/eq/2');
      await tester.pumpPageTransition();
      expect(find.byType(EchoPage), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      expect(systemUrl.current, '/home/1/eq/2');

      await delegate.pop();
      await tester.pumpPageTransition();

      expect(systemUrl.current, '/home/1/two/edit');

      await delegate.pop();
      await tester.pumpPageTransition();
      expect(find.byType(HomePage), findsOneWidget);

      expect(systemUrl.current, '/home/1/two');

      expect(find.byType(PageOne), findsNothing);
      expect(find.byType(PageTwo), findsOneWidget);
    });
  });
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = TabPage.of(context);

    return Scaffold(
      body: TabBarView(
        controller: tabState.controller,
        children: [
          for (final stack in tabState.stacks) PageStackNavigator(stack: stack)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabState.index,
        onTap: (index) => tabState.controller.animateTo(index),
        items: const [
          BottomNavigationBarItem(
            label: 'one',
            icon: Icon(CupertinoIcons.add),
          ),
          BottomNavigationBarItem(
            label: 'two',
            icon: Icon(CupertinoIcons.building_2_fill),
          ),
        ],
      ),
    );
  }
}

class EchoPage extends StatelessWidget {
  const EchoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(RouteData.of(context).pathParameters['eqId']!),
    );
  }
}
