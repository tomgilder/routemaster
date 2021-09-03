import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';

import 'helpers.dart';

void main() {
  testWidgets('Background page can push relative route', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(
            routes: {
              '/': (_) => StackPage(
                    child: MyStackPage(),
                    defaultPath: 'one',
                  ),
              '/one': (_) => const MaterialPageOne(),
              '/one/two': (_) => const MaterialPageTwo(),
              '/three': (_) => const MaterialPageThree(),
            },
          ),
        ),
      ),
    );

    await setSystemUrl('/one/two');
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);

    await tester.tap(find.text('Push three'));
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
  });

  testWidgets('Background page can replace relative route', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (_) => RouteMap(
            routes: {
              '/': (_) => StackPage(
                    child: MyStackPage(),
                    defaultPath: 'one',
                  ),
              '/one': (_) => const MaterialPageOne(),
              '/one/two': (_) => const MaterialPageTwo(),
              '/three': (_) => const MaterialPageThree(),
            },
          ),
        ),
      ),
    );

    await setSystemUrl('/one/two');
    await tester.pumpPageTransition();
    expect(find.byType(PageTwo), findsOneWidget);

    await tester.tap(find.text('Replace three'));
    await tester.pumpPageTransition();
    expect(find.byType(PageThree), findsOneWidget);
  });
}

class MyStackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Routemaster.of(context).push('three'),
            child: const Text('Push three'),
          ),
          ElevatedButton(
            onPressed: () => Routemaster.of(context).push('three'),
            child: const Text('Replace three'),
          ),
          Expanded(
            child: PageStackNavigator(stack: StackPage.of(context).stack),
          ),
        ],
      ),
    );
  }
}
