import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter/services.dart';
import 'package:routemaster/src/system_nav.dart';
import 'helpers.dart';

void main() {
  testWidgets('Updates current route on delegate pop', (tester) async {
    await trackRoute((delegate, tracker) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      expect(tracker.systemUrl, '/');
      expect(tracker.buildFullPath, '/');

      delegate.push('/two');
      await tester.pumpPageTransition();
      expect(tracker.buildCount, 2);
      expect(tracker.systemUrl, '/two');
      expect(tracker.buildFullPath, '/two');
      await delegate.pop();
      await tester.pump();

      expect(tracker.buildCount, 3);
      expect(tracker.systemUrl, '/');
      expect(tracker.buildFullPath, '/');
    });
  });

  testWidgets('Updates current route on delegate popRoute', (tester) async {
    await trackRoute((delegate, tracker) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      expect(tracker.systemUrl, '/');
      expect(tracker.buildFullPath, '/');

      delegate.push('/two');
      await tester.pumpPageTransition();
      expect(tracker.buildCount, 2);
      expect(tracker.systemUrl, '/two');
      expect(tracker.buildFullPath, '/two');
      await delegate.popRoute();
      await tester.pump();

      expect(tracker.buildCount, 3);
      expect(tracker.systemUrl, '/');
      expect(tracker.buildFullPath, '/');
    });
  });

  testWidgets('Updates current route on delegate popUntil', (tester) async {
    await trackRoute((delegate, tracker) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      expect(tracker.systemUrl, '/');
      expect(tracker.buildFullPath, '/');

      delegate.push('/two');
      await tester.pumpPageTransition();
      expect(tracker.buildCount, 2);
      expect(tracker.systemUrl, '/two');
      expect(tracker.buildFullPath, '/two');
      await delegate.popUntil((r) => r.fullPath == '/');
      await tester.pump();

      expect(tracker.buildCount, 3);
      expect(tracker.systemUrl, '/');
      expect(tracker.buildFullPath, '/');
    });
  });

  testWidgets('Updates current route on delegate popUntil', (tester) async {
    await trackRoute((delegate, tracker) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      expect(tracker.systemUrl, '/');
      expect(tracker.buildFullPath, '/');

      delegate.push('/two');
      await tester.pumpPageTransition();
      expect(tracker.buildCount, 2);
      expect(tracker.systemUrl, '/two');
      expect(tracker.buildFullPath, '/two');
      await delegate.popUntil((r) => r.fullPath == '/');
      await tester.pump();

      expect(tracker.buildCount, 3);
      expect(tracker.systemUrl, '/');
      expect(tracker.buildFullPath, '/');
    });
  });

  testWidgets('Updates current route with StackPage', (tester) async {
    await trackRoute((delegate, tracker) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      expect(tracker.systemUrl, '/');
      expect(tracker.buildFullPath, '/');

      delegate.push('/stack');
      await tester.pumpPageTransition();
      expect(tracker.outerBuildCount, 1);
      expect(tracker.buildCount, 2);
      expect(tracker.systemUrl, '/stack/one');
      expect(tracker.buildFullPath, '/stack/one');

      delegate.push('/stack/one/two');
      await tester.pumpPageTransition();
      expect(tracker.outerBuildCount, 1);
      expect(tracker.buildCount, 3);
      expect(tracker.systemUrl, '/stack/one/two');
      expect(tracker.buildFullPath, '/stack/one/two');

      await delegate.pop();
      await tester.pump();

      expect(tracker.outerBuildCount, 1);
      expect(tracker.buildCount, 4);
      expect(tracker.systemUrl, '/stack/one');
      expect(tracker.buildFullPath, '/stack/one');
    });
  });
}

class RouteTracker {
  late final RoutemasterDelegate delegate;
  late String systemUrl;
  late String buildFullPath;

  /// Build count of the outer Builder widget. Makes sure only the inner Builder
  /// is being rebuilt.
  int outerBuildCount = 0;

  /// Build count of the inner Builder widget.
  int buildCount = 0;

  int changeUpdateCount = 0;
}

final globalKey = GlobalKey();

Future<void> trackRoute(
    Future Function(RoutemasterDelegate delegate, RouteTracker tracker)
        callback) async {
  try {
    final tracker = RouteTracker();

    // Nested builders - makes sure it's actually the inner builder is being
    // made dirty and rebuilding.
    final trackerWidget = Builder(
      builder: (context) {
        tracker.outerBuildCount++;

        return Builder(
          builder: (context) {
            tracker.buildCount++;
            tracker.buildFullPath =
                Routemaster.of(context).currentRoute.fullPath;
            return const SizedBox();
          },
        );
      },
    );

    final delegate = RoutemasterDelegate.builder(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => const MaterialPageOne(),
          '/two': (_) => const MaterialPageTwo(),
          '/stack': (_) => const StackPage(
                child: StackPageHost(),
                defaultPath: '/stack/one',
              ),
          '/stack/one': (_) => const MaterialPageOne(),
          '/stack/one/two': (_) => const MaterialPageTwo(),
        },
      ),
      navigatorBuilder: (context, stack) {
        return Column(
          children: [
            trackerWidget,
            Expanded(
              child: PageStackNavigator(
                stack: stack,
                transitionDelegate: const DefaultTransitionDelegate<dynamic>(),
              ),
            ),
          ],
        );
      },
    );

    delegate.addListener(() {
      tracker.changeUpdateCount++;
    });

    SystemChannels.navigation.setMockMethodCallHandler(
      (call) async {
        if (call.method == 'routeInformationUpdated') {
          final location = call.arguments['location'] as String;
          tracker.systemUrl = location;
        }
      },
    );

    await callback(delegate, tracker);
  } finally {
    SystemChannels.navigation.setMockMethodCallHandler(null);
    SystemNav.historyProvider = null;
  }
}

class StackPageHost extends StatelessWidget {
  const StackPageHost();

  @override
  Widget build(BuildContext context) {
    return PageStackNavigator(stack: StackPage.of(context).stack);
  }
}
