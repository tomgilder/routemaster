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
              initialPath: 'one',
            ),
        '/stack/one': (_) => MaterialPage<void>(child: StackPageOne()),
        '/stack/one/two': (_) => MaterialPage<void>(child: StackPageTwo()),
      },
    ),
  ),
);

void main() {
  testWidgets('Can step through stack and close it', (tester) async {
    await tester.pumpWidget(stackApp);

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(rootPageKey.currentContext!).push('/stack/one');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(StackPageOne), findsOneWidget);
      }),
      ['/stack/one'],
    );

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(rootPageKey.currentContext!).push('/stack/one/two');
        await tester.pump();
        await tester.pump(kTransitionDuration);
        expect(find.byType(StackPageTwo), findsOneWidget);
      }),
      ['/stack/one/two'],
    );

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(stackPageOneKey.currentContext!).push('/');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(StackPageTwo), findsNothing);
      }),
      ['/'],
    );
  });

  testWidgets('Can open stack via root stack page path', (tester) async {
    await tester.pumpWidget(stackApp);
    expect(
      await recordUrlChanges(() async {
        Routemaster.of(rootPageKey.currentContext!).push('/stack');
        await tester.pump();
        await tester.pump(kTransitionDuration);
        expect(find.byType(StackPageOne), findsOneWidget);
      }),
      ['/stack/one'],
    );
  });

  testWidgets('Can open stack at end and pop backwards', (tester) async {
    await tester.pumpWidget(stackApp);

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(rootPageKey.currentContext!).push('/stack/one/two');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(StackPageTwo), findsOneWidget);
      }),
      ['/stack/one/two'],
    );

    expect(
      await recordUrlChanges(() async {
        await Routemaster.of(stackPageOneKey.currentContext!).pop();
        await tester.pump();
        await tester.pump(kTransitionDuration);
        expect(find.byType(StackPageOne), findsOneWidget);
      }),
      ['/stack/one'],
    );

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(stackPageOneKey.currentContext!).push('/');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(StackPageTwo), findsNothing);
      }),
      ['/'],
    );
  });

  testWidgets('Back button pops stack', (tester) async {
    await tester.pumpWidget(stackApp);

    expect(
      await recordUrlChanges(() async {
        Routemaster.of(rootPageKey.currentContext!).push('/stack/one/two');
        await tester.pump();
        await tester.pump(kTransitionDuration);

        expect(find.byType(StackPageTwo), findsOneWidget);
      }),
      ['/stack/one/two'],
    );

    expect(
      await recordUrlChanges(() async {
        await invokeSystemBack();
        await tester.pump();
        await tester.pump(kTransitionDuration);
        expect(find.byType(StackPageOne), findsOneWidget);
      }),
      ['/stack/one'],
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
