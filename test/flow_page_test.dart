import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

final rootPageKey = GlobalKey();
final flowPageOneKey = GlobalKey();
final flowPageTwoKey = GlobalKey();

final flowApp = MaterialApp.router(
  routeInformationParser: const RoutemasterParser(),
  routerDelegate: RoutemasterDelegate(
    routesBuilder: (_) => RouteMap(
      routes: {
        '/': (_) => MaterialPage<void>(child: PageOne(key: rootPageKey)),
        '/flow': (_) {
          return FlowPage(
            pageBuilder: (child) => BottomSheetPage(child: child),
            child: FlowBottomSheetContents(),
            paths: const ['one', 'two'],
          );
        },
        '/flow/one': (_) => MaterialPage<void>(child: FlowPageOne()),
        '/flow/two': (route) {
          return MaterialPage<void>(child: FlowPageTwo());
        },
      },
    ),
  ),
);

void main() {
  testWidgets('Can step through flow and close it', (tester) async {
    await tester.pumpWidget(flowApp);

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(rootPageKey.currentContext!).push('/flow/one');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(FlowPageOne), findsOneWidget);
      }),
      ['/flow/one'],
    );

    expect(
      await recordUrlChanges(() async {
        FlowPage.of(flowPageOneKey.currentContext!).pushNext();
        await tester.pump();
        await tester.pump(kTransitionDuration);
        expect(find.byType(FlowPageTwo), findsOneWidget);
      }),
      ['/flow/two'],
    );

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(flowPageOneKey.currentContext!).push('/');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(FlowPageTwo), findsNothing);
      }),
      ['/'],
    );
  });

  testWidgets('Can open flow via root flow page path', (tester) async {
    await tester.pumpWidget(flowApp);
    expect(
      await recordUrlChanges(() async {
        Routemaster.of(rootPageKey.currentContext!).push('/flow');
        await tester.pump();
        await tester.pump(kTransitionDuration);
        expect(find.byType(FlowPageOne), findsOneWidget);
      }),
      ['/flow/one'],
    );
  });

  testWidgets('Can open flow at end and pop backwards', (tester) async {
    await tester.pumpWidget(flowApp);

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(rootPageKey.currentContext!).push('/flow/two');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(FlowPageTwo), findsOneWidget);
      }),
      ['/flow/two'],
    );

    expect(
      await recordUrlChanges(() async {
        FlowPage.of(flowPageOneKey.currentContext!).pop();
        await tester.pump();
        await tester.pump(kTransitionDuration);
        expect(find.byType(FlowPageOne), findsOneWidget);
      }),
      ['/flow/one'],
    );

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(flowPageOneKey.currentContext!).push('/');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(FlowPageTwo), findsNothing);
      }),
      ['/'],
    );
  });

  testWidgets('Back button pops flow', (tester) async {
    await tester.pumpWidget(flowApp);

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(rootPageKey.currentContext!).push('/flow/two');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(FlowPageTwo), findsOneWidget);
      }),
      ['/flow/two'],
    );

    expect(
      await recordUrlChanges(() async {
        await invokeSystemBack();
        await tester.pump();
        await tester.pump(kTransitionDuration);
        expect(find.byType(FlowPageOne), findsOneWidget);
      }),
      ['/flow/one'],
    );
  });

  testWidgets('Can specify absolute paths for flow', (tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (_) => RouteMap(
          routes: {
            '/': (_) => MaterialPage<void>(child: PageOne(key: rootPageKey)),
            '/flow': (_) {
              return FlowPage(
                pageBuilder: (child) => BottomSheetPage(child: child),
                child: FlowBottomSheetContents(),
                paths: const ['/flow/one', '/flow/two'],
              );
            },
            '/flow/one': (_) => MaterialPage<void>(child: FlowPageOne()),
            '/flow/two': (route) {
              return MaterialPage<void>(child: FlowPageTwo());
            },
          },
        ),
      ),
    ));

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(rootPageKey.currentContext!).push('/flow');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(FlowPageOne), findsOneWidget);
      }),
      ['/flow/one'],
    );

    expect(
      await recordUrlChanges(() async {
        FlowPage.of(flowPageOneKey.currentContext!).pushNext();
        await tester.pump();
        await tester.pump(kTransitionDuration);
        expect(find.byType(FlowPageTwo), findsOneWidget);
      }),
      ['/flow/two'],
    );

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(flowPageOneKey.currentContext!).push('/');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(FlowPageTwo), findsNothing);
      }),
      ['/'],
    );
  });
}

class BottomSheetPage extends Page<void> {
  final Widget child;

  const BottomSheetPage({required this.child});

  @override
  Route<void> createRoute(BuildContext context) {
    return CupertinoModalPopupRoute(
      builder: (context) {
        final page = ModalRoute.of(context)!.settings as BottomSheetPage;
        return page.child;
      },
      settings: this,
    );
  }
}

class FlowBottomSheetContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageStackNavigator(stack: FlowPage.of(context).stack);
  }
}

class FlowPageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: flowPageOneKey,
      appBar: AppBar(),
      body: const SizedBox(),
    );
  }
}

class FlowPageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: flowPageTwoKey,
      appBar: AppBar(),
      body: const SizedBox(),
    );
  }
}
