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

  testWidgets('Can use custom hero controller', (tester) async {
    final heroController = TestHeroController();

    final app = MaterialApp.router(
      routeInformationParser: RoutemasterParser(),
      routerDelegate: RoutemasterDelegate.builder(
        navigatorBuilder: (context, stack) {
          return StackNavigator(
            stack: stack,
            heroController: heroController,
          );
        },
        routesBuilder: (context) {
          return RouteMap(
            routes: {
              '/': (_) => MaterialPageOne(),
              '/two': (_) => MaterialPageOne(),
            },
          );
        },
      ),
    );
    await tester.pumpWidget(app);
    await setSystemUrl('/two');
    await tester.pump();

    expect(heroController.didPushCount, 2);
  });

  testWidgets('Can swap custom hero controller', (tester) async {
    final heroController1 = TestHeroController();
    final heroController2 = TestHeroController();

    Widget buildApp(HeroController controller) {
      return MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: RoutemasterDelegate.builder(
          navigatorBuilder: (context, stack) {
            return StackNavigator(
              stack: stack,
              heroController: controller,
            );
          },
          routesBuilder: (context) {
            return RouteMap(
              routes: {
                '/': (_) => MaterialPageOne(),
                '/two': (_) => MaterialPageOne(),
                '/two/three': (_) => MaterialPageOne(),
              },
            );
          },
        ),
      );
    }

    await tester.pumpWidget(buildApp(heroController1));
    await setSystemUrl('/two');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(heroController1.didPushCount, 2);

    await tester.pumpWidget(buildApp(heroController2));
    await tester.pump();
    await setSystemUrl('/two/three');
    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(heroController1.didPushCount, 2);
    expect(heroController2.didPushCount, 1);
  });
}

class TestHeroController extends HeroController {
  int didPushCount = 0;
  int didPopCount = 0;

  TestHeroController({
    CreateRectTween? createRectTween,
  }) : super(createRectTween: createRectTween);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    didPushCount++;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    didPopCount++;
    super.didPop(route, previousRoute);
  }
}

final hero1Key = Key('hero1');
final hero2Key = Key('hero2');

class HeroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: RoutemasterParser(),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (context) {
          return RouteMap(
            routes: {
              '/': (_) => CupertinoTabPage(
                    child: HomePage(),
                    paths: ['hero1', 'other'],
                  ),
              '/hero1': (_) => MaterialPage<void>(child: HeroPage1()),
              '/hero1/hero2': (_) => MaterialPage<void>(child: HeroPage2()),
              '/other': (_) => MaterialPageOne(),
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
        items: <BottomNavigationBarItem>[
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
        return StackNavigator(stack: stack);
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
              child: Text('Push page 2'),
            ),
            SizedBox(height: 20),
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
          SizedBox(height: 300),
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
