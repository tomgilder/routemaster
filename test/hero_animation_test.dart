import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Hero animations work with app bar back button', (tester) async {
    await tester.pumpWidget(HeroApp());

    expect(find.byKey(hero1Key), findsOneWidget);
    await tester.tap(find.text('Push page 2'));
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byKey(hero2Key), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(find.byKey(hero1Key), findsOneWidget);
  });

  testWidgets('Hero animations work with system back button', (tester) async {
    await tester.pumpWidget(HeroApp());

    expect(find.byKey(hero1Key), findsOneWidget);
    await tester.tap(find.text('Push page 2'));
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byKey(hero2Key), findsOneWidget);

    await invokeSystemBack();
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(find.byKey(hero1Key), findsOneWidget);
  });
}

const hero1Key = Key('hero1');
const hero2Key = Key('hero2');

class HeroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (context) {
          return RouteMap(
            routes: {
              '/': (_) => CupertinoTabPage(
                    child: HomePage(),
                    paths: const ['hero1', 'other'],
                  ),
              '/hero1': (_) => MaterialPage<void>(child: HeroPage1()),
              '/hero1/hero2': (_) => MaterialPage<void>(child: HeroPage2()),
              '/other': (_) => const MaterialPageOne(),
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Heros',
            icon: Icon(CupertinoIcons.list_bullet),
          ),
          BottomNavigationBarItem(
            label: 'Other',
            icon: Icon(CupertinoIcons.search),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        final stack = tabState.stacks[index];
        return PageStackNavigator(stack: stack);
      },
    );
  }
}

class HeroPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Routemaster.of(context).push('hero2'),
              child: const Text('Push page 2'),
            ),
            const SizedBox(height: 20),
            Hero(
              tag: 'my-hero',
              child: Container(
                key: hero1Key,
                color: Colors.red,
                width: 50,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeroPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          const SizedBox(height: 300),
          Center(
            child: Hero(
              tag: 'my-hero',
              child: Container(
                key: hero2Key,
                color: Colors.red,
                width: 100,
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
