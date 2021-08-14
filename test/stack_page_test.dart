import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

final rootPageKey = GlobalKey();
final stackPageOneKey = GlobalKey();
final stackPageTwoKey = GlobalKey();

final stackApp = MaterialApp.router(
  routeInformationParser: const RoutemasterParser(),
  routerDelegate: RoutemasterDelegate(
    routesBuilder: (_) => RouteMap(
      routes: {
        '/': (_) => MaterialPage<void>(child: PageOne(key: rootPageKey)),
        '/stack': (_) => StackPage(
              pageBuilder: (child) => BottomSheetPage(child: child),
              child: StackBottomSheetContents(),
              defaultPath: 'one',
            ),
        '/stack/one': (_) => MaterialPage<void>(child: StackPageOne()),
        '/stack/one/two': (_) => MaterialPage<void>(child: StackPageTwo()),
      },
    ),
  ),
);

void main() {
  testWidgets('Can step through stack and close it', (tester) async {
    await recordUrlChanges((systemUrl) async {
      await tester.pumpWidget(stackApp);

      Routemaster.of(rootPageKey.currentContext!).push('/stack/one');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(StackPageOne), findsOneWidget);

      expect(systemUrl.current, '/stack/one');

      Routemaster.of(rootPageKey.currentContext!).push('/stack/one/two');
      await tester.pump();
      await tester.pump(kTransitionDuration);
      expect(find.byType(StackPageTwo), findsOneWidget);

      expect(systemUrl.current, '/stack/one/two');

      Routemaster.of(stackPageOneKey.currentContext!).push('/');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(StackPageTwo), findsNothing);

      expect(systemUrl.current, '/');
    });
  });

  testWidgets('Can open stack via root stack page path', (tester) async {
    await recordUrlChanges((systemUrl) async {
      await tester.pumpWidget(stackApp);

      Routemaster.of(rootPageKey.currentContext!).push('/stack');
      await tester.pump();
      await tester.pump(kTransitionDuration);
      expect(find.byType(StackPageOne), findsOneWidget);

      expect(systemUrl.current, '/stack/one');
    });
  });

  testWidgets('Can open stack at end and pop backwards', (tester) async {
    await recordUrlChanges((systemUrl) async {
      await tester.pumpWidget(stackApp);

      Routemaster.of(rootPageKey.currentContext!).push('/stack/one/two');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(StackPageTwo), findsOneWidget);

      expect(systemUrl.current, '/stack/one/two');

      await Routemaster.of(stackPageOneKey.currentContext!).pop();
      await tester.pump();
      await tester.pump(kTransitionDuration);
      expect(find.byType(StackPageOne), findsOneWidget);

      expect(systemUrl.current, '/stack/one');

      Routemaster.of(stackPageOneKey.currentContext!).push('/');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(StackPageTwo), findsNothing);

      expect(systemUrl.current, '/');
    });
  });

  testWidgets('Back button pops stack', (tester) async {
    await recordUrlChanges((systemUrl) async {
      await tester.pumpWidget(stackApp);

      Routemaster.of(rootPageKey.currentContext!).push('/stack/one/two');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      expect(find.byType(StackPageTwo), findsOneWidget);

      expect(systemUrl.current, '/stack/one/two');

      await invokeSystemBack();
      await tester.pump();
      await tester.pump(kTransitionDuration);
      expect(find.byType(StackPageOne), findsOneWidget);

      expect(systemUrl.current, '/stack/one');
    });
  });

  testWidgets('Asserts if unable to find StackPage', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(builder: (c) {
        context = c;
        return const SizedBox();
      }),
    );

    expect(
      () => StackPage.of(context),
      throwsA(predicate((e) =>
          e is AssertionError &&
          e.message ==
              "Couldn't find an StackPageState from the given context.")),
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

class StackBottomSheetContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageStackNavigator(stack: StackPage.of(context).stack);
  }
}

class StackPageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: stackPageOneKey,
      appBar: AppBar(),
      body: const SizedBox(),
    );
  }
}

class StackPageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: stackPageTwoKey,
      appBar: AppBar(),
      body: const SizedBox(),
    );
  }
}
