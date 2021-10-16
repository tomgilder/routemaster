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
    await recordUrlChanges((systemUrl) async {
      await tester.pumpWidget(flowApp);

      Routemaster.of(rootPageKey.currentContext!).push('/flow/one');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(FlowPageOne), findsOneWidget);
      expect(systemUrl.current, '/flow/one');

      FlowPage.of(flowPageOneKey.currentContext!).pushNext();
      await tester.pump();
      await tester.pump(kTransitionDuration);
      expect(find.byType(FlowPageTwo), findsOneWidget);
      expect(systemUrl.current, '/flow/two');

      Routemaster.of(flowPageOneKey.currentContext!).push('/');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(FlowPageTwo), findsNothing);
      expect(systemUrl.current, '/');
    });
  });

  testWidgets('Can open flow via root flow page path', (tester) async {
    await tester.pumpWidget(flowApp);
    await recordUrlChanges((systemUrl) async {
      Routemaster.of(rootPageKey.currentContext!).push('/flow');
      await tester.pump();
      await tester.pump(kTransitionDuration);
      expect(find.byType(FlowPageOne), findsOneWidget);
      expect(systemUrl.current, '/flow/one');
    });
  });

  testWidgets('Can open flow at end and pop backwards', (tester) async {
    await tester.pumpWidget(flowApp);

    await recordUrlChanges((systemUrl) async {
      Routemaster.of(rootPageKey.currentContext!).push('/flow/two');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(FlowPageTwo), findsOneWidget);
      expect(systemUrl.current, '/flow/two');

      FlowPage.of(flowPageOneKey.currentContext!).pop();
      await tester.pump();
      await tester.pump(kTransitionDuration);
      expect(find.byType(FlowPageOne), findsOneWidget);
      expect(systemUrl.current, '/flow/one');

      Routemaster.of(flowPageOneKey.currentContext!).push('/');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(FlowPageTwo), findsNothing);
      expect(systemUrl.current, '/');
    });
  });

  testWidgets('Global pop pops flow', (tester) async {
    await tester.pumpWidget(flowApp);

    await recordUrlChanges((systemUrl) async {
      Routemaster.of(rootPageKey.currentContext!).push('/flow/two');
      await tester.pumpPageTransition();

      expect(find.byType(FlowPageTwo), findsOneWidget);
      expect(systemUrl.current, '/flow/two');

      await Routemaster.of(rootPageKey.currentContext!).pop();
      await tester.pumpPageTransition();
      expect(find.byType(FlowPageOne), findsOneWidget);
      expect(systemUrl.current, '/flow/one');
    });
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
    await recordUrlChanges((systemUrl) async {
      Routemaster.of(rootPageKey.currentContext!).push('/flow');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(FlowPageOne), findsOneWidget);
      expect(systemUrl.current, '/flow/one');

      FlowPage.of(flowPageOneKey.currentContext!).pushNext();
      await tester.pump();
      await tester.pump(kTransitionDuration);
      expect(find.byType(FlowPageTwo), findsOneWidget);
      expect(systemUrl.current, '/flow/two');

      Routemaster.of(flowPageOneKey.currentContext!).push('/');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(FlowPageTwo), findsNothing);
      expect(systemUrl.current, '/');
    });
  });

  testWidgets('Asserts when no FlowPage widget found', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(Builder(
      builder: (c) {
        context = c;
        return const SizedBox();
      },
    ));

    expect(
        () => FlowPage.of(context),
        throwsA(predicate((e) =>
            e is AssertionError &&
            e.message ==
                "Couldn't find an FlowPageState from the given context.")));
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
