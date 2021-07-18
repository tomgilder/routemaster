import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';

import 'helpers.dart';

const kAndroidDuration = Duration(milliseconds: 300);
const kCupertinoDuration = Duration(milliseconds: 400);
const kTestDuration = Duration(milliseconds: 42);

void main() {
  test('platformDefault returns correct transition per platform', () {
    expect(
      PageTransition.platformDefault(TargetPlatform.android).runtimeType,
      PageTransition.fadeUpwards.runtimeType,
    );

    expect(
      PageTransition.platformDefault(TargetPlatform.linux).runtimeType,
      PageTransition.fadeUpwards.runtimeType,
    );

    expect(
      PageTransition.platformDefault(TargetPlatform.windows).runtimeType,
      PageTransition.fadeUpwards.runtimeType,
    );

    expect(
      PageTransition.platformDefault(TargetPlatform.fuchsia).runtimeType,
      PageTransition.fadeUpwards.runtimeType,
    );

    expect(
      PageTransition.platformDefault(TargetPlatform.iOS).runtimeType,
      PageTransition.cupertino.runtimeType,
    );

    expect(
      PageTransition.platformDefault(TargetPlatform.macOS).runtimeType,
      PageTransition.cupertino.runtimeType,
    );
  });

  test('Zoom transition is correct', () {
    final zoomTransition = PageTransition.zoom;
    expect(zoomTransition.duration, const Duration(milliseconds: 300));
    expect(
      zoomTransition.transitionsBuilder,
      isA<ZoomPageTransitionsBuilder>(),
    );
  });

  testWidgets(
    'TransitionPage uses default transition if push and pop are null on Android',
    (tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        Theme(
          data: ThemeData(platform: TargetPlatform.android),
          child: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      const page = TransitionPage<void>(child: SizedBox());

      final pushTransition = page.buildPushTransition(context);
      expect(
          pushTransition.runtimeType, PageTransition.fadeUpwards.runtimeType);
      expect(pushTransition.duration, kAndroidDuration);

      final popTransition = page.buildPopTransition(context);
      expect(popTransition.runtimeType, PageTransition.fadeUpwards.runtimeType);
      expect(popTransition.duration, kAndroidDuration);
    },
  );

  testWidgets(
    'TransitionPage uses default transition if push and pop are null on iOS',
    (tester) async {
      late final BuildContext context;

      await tester.pumpWidget(
        Theme(
          data: ThemeData(platform: TargetPlatform.iOS),
          child: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      const page = TransitionPage<void>(child: SizedBox());

      final pushTransition = page.buildPushTransition(context);
      expect(pushTransition.runtimeType, PageTransition.cupertino.runtimeType);
      expect(pushTransition.duration, kCupertinoDuration);

      final popTransition = page.buildPopTransition(context);
      expect(popTransition.runtimeType, PageTransition.cupertino.runtimeType);
      expect(popTransition.duration, kCupertinoDuration);
    },
  );

  testWidgets(
    'TransitionPage uses default transition if just pop is null',
    (tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        Theme(
          data: ThemeData(platform: TargetPlatform.android),
          child: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      const pushTransition = TestPageTransition();
      const page = TransitionPage<void>(
        child: SizedBox(),
        pushTransition: pushTransition,
        popTransition: null,
      );

      expect(page.buildPushTransition(context), pushTransition);

      final popTransition = page.buildPopTransition(context);
      expect(popTransition.runtimeType, PageTransition.fadeUpwards.runtimeType);
      expect(popTransition.duration, kAndroidDuration);
    },
  );

  testWidgets(
    'TransitionPage uses default transition if just push is null',
    (tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        Theme(
          data: ThemeData(platform: TargetPlatform.android),
          child: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      const popTransition = TestPageTransition();
      const page = TransitionPage<void>(
        child: SizedBox(),
        pushTransition: null,
        popTransition: popTransition,
      );

      final pushTransition = page.buildPushTransition(context);
      expect(
          pushTransition.runtimeType, PageTransition.fadeUpwards.runtimeType);
      expect(pushTransition.duration, kAndroidDuration);

      expect(page.buildPopTransition(context), popTransition);
    },
  );

  testWidgets(
    'TransitionPage can use custom push and pop animations',
    (tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        Theme(
          data: ThemeData(platform: TargetPlatform.android),
          child: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      const pushTransition = TestPageTransition();
      const popTransition = TestPageTransition();
      const page = TransitionPage<void>(
        child: SizedBox(),
        pushTransition: pushTransition,
        popTransition: popTransition,
      );

      expect(page.buildPushTransition(context), pushTransition);
      expect(page.buildPopTransition(context), popTransition);
    },
  );

  testWidgets(
    'No transition pops and pushes immediately',
    (tester) async {
      // Pump routemaster with two pages
      final delegate = RoutemasterDelegate(
        routesBuilder: (_) => RouteMap(
          routes: {
            '/': (info) => const MaterialPageOne(),
            '/subpage': (info) => TransitionPage<void>(
                  child: const PageTwo(),
                  pushTransition: PageTransition.none,
                  popTransition: PageTransition.none,
                ),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      // Finds first page
      expect(find.byType(PageOne), findsOneWidget);
      expect(find.byType(PageTwo), findsNothing);

      delegate.push('/subpage');
      final pushFrames = await tester.pumpAndSettle();
      expect(pushFrames, 2);

      // Finds second page
      expect(find.byType(PageOne), findsNothing);
      expect(find.byType(PageTwo), findsOneWidget);

      await delegate.pop();

      final popFrames = await tester.pumpAndSettle();
      expect(popFrames, 2);

      expect(find.byType(PageOne), findsOneWidget);
      expect(find.byType(PageTwo), findsNothing);
    },
  );

  testWidgets(
    'Can use different push animation and swipe back on Cupertino pop transition',
    (tester) async {
      // Pump routemaster with two pages
      final delegate = RoutemasterDelegate(
        routesBuilder: (_) => RouteMap(
          routes: {
            '/': (info) => const MaterialPageOne(),
            '/subpage': (info) => TransitionPage<void>(
                  child: const PageTwo(),
                  pushTransition: PageTransition.fadeUpwards,
                  popTransition: PageTransition.cupertino,
                ),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      // Finds first page
      expect(find.byType(PageOne), findsOneWidget);
      expect(find.byType(PageTwo), findsNothing);

      // Navigate
      delegate.push('/subpage');
      await tester.pump();
      await tester.pump(kTransitionDuration);

      // Finds second page
      expect(find.byType(PageOne), findsNothing);
      expect(find.byType(PageTwo), findsOneWidget);

      // Swipe back from left edge
      final gesture = await tester.startGesture(const Offset(5.0, 200.0));
      await gesture.moveBy(const Offset(500.0, 0.0));
      await gesture.up();
      await tester.pump();
      await tester.pump(kTransitionDuration);

      // Page 1 visible
      expect(find.byType(PageOne), findsOneWidget);
      expect(find.byType(PageTwo), findsNothing);
    },
  );

  testWidgets(
    'Can use no push animation and swipe back on Cupertino pop transition',
    (tester) async {
      // Pump routemaster with two pages
      final delegate = RoutemasterDelegate(
        routesBuilder: (_) => RouteMap(
          routes: {
            '/': (info) => const MaterialPageOne(),
            '/subpage': (info) => const CustomPage(child: PageTwo()),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );

      // Finds first page
      expect(find.byType(PageOne), findsOneWidget);
      expect(find.byType(PageTwo), findsNothing);

      // Navigate
      delegate.push('/subpage');
      final frames = await tester.pumpAndSettle();
      expect(frames, 2);

      // Finds second page
      expect(find.byType(PageOne), findsNothing);
      expect(find.byType(PageTwo), findsOneWidget);

      // Swipe back from left edge
      final gesture = await tester.startGesture(const Offset(5.0, 200.0));
      await gesture.moveBy(const Offset(500.0, 0.0));
      await gesture.up();
      await tester.pump();
      await tester.pump(kTransitionDuration);

      // Page 1 visible
      expect(find.byType(PageOne), findsOneWidget);
      expect(find.byType(PageTwo), findsNothing);
    },
  );
}

class TestPageTransition extends PageTransition {
  const TestPageTransition();

  @override
  final Duration duration = kTestDuration;

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const TestPageTransitionsBuilder();
}

class TestPageTransitionsBuilder extends PageTransitionsBuilder {
  const TestPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return const SizedBox();
  }
}

class CustomPage extends TransitionBuilderPage<void> {
  const CustomPage({required Widget child}) : super(child: child);

  @override
  PageTransition buildPushTransition(BuildContext context) {
    return PageTransition.none;
  }

  @override
  PageTransition buildPopTransition(BuildContext context) {
    return PageTransition.cupertino;
  }
}
