import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/src/system_nav.dart';
import 'package:routemaster/src/trie_router/src/router_result.dart';

const kTransitionDuration = Duration(milliseconds: 350);

extension PumpExtension on WidgetTester {
  Future<void> pumpPageTransition() async {
    await pump();
    await pump(kTransitionDuration);
  }
}

class MockHistoryProvider implements HistoryProvider {
  @override
  String hash = '#';

  @override
  void back() {}

  @override
  void forward() {}
}

class SystemUrlTracker {
  String? current;
}

/// Records changes in URL
Future<void> recordUrlChanges(
    Future Function(SystemUrlTracker url) callback) async {
  try {
    final tracker = SystemUrlTracker();
    SystemChannels.navigation.setMockMethodCallHandler((call) async {
      if (call.method == 'routeInformationUpdated') {
        final location = call.arguments['location'] as String;
        tracker.current = location;
      }
    });

    await callback(tracker);
  } finally {
    SystemChannels.navigation.setMockMethodCallHandler(null);
    SystemNav.historyProvider = null;
  }
}

/// Simulates pressing the system back button
Future<void> invokeSystemBack() {
  // ignore: invalid_use_of_protected_member
  return WidgetsBinding.instance!.handlePopRoute();
}

Future<void> setSystemUrl(String url) {
  // ignore: invalid_use_of_protected_member
  return WidgetsBinding.instance!.handlePushRoute(url);
}

class MaterialPageOne extends MaterialPage<void> {
  const MaterialPageOne() : super(child: const PageOne());
}

class PageOne extends StatelessWidget {
  const PageOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class MaterialPageTwo extends MaterialPage<void> {
  const MaterialPageTwo() : super(child: const PageTwo());
}

class PageTwo extends StatelessWidget {
  const PageTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class MaterialPageThree extends MaterialPage<void> {
  const MaterialPageThree() : super(child: const PageThree());
}

class PageThree extends StatelessWidget {
  const PageThree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class EchoPage extends MaterialPage<void> {
  EchoPage({required String? text})
      : super(
          child: Scaffold(body: Text(text ?? '')),
        );
}

class PopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () => Routemaster.of(context).pop(),
        child: const Text('Pop'),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class FakeBuildContext implements BuildContext {
  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>(
      {Object? aspect}) {
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {}
}

const rootRoute = TestRoute('root');
const route1 = TestRoute('one');
const route2 = TestRoute('two');

void expectRootRoute(RouterResult result, {String prefix = ''}) {
  expectRoute(
    result,
    route: rootRoute,
    pathTemplate: '$prefix/',
    pathSegment: '$prefix/',
  );
}

void expectRoute1(RouterResult result, {String prefix = ''}) {
  expectRoute(
    result,
    route: route1,
    pathTemplate: '$prefix/one',
    pathSegment: '$prefix/one',
  );
}

void expectRoute2(RouterResult result, {String prefix = ''}) {
  expectRoute(
    result,
    route: route2,
    pathTemplate: '$prefix/one/two',
    pathSegment: '$prefix/one/two',
  );
}

void expectRoute(
  RouterResult result, {
  required Page route,
  required String pathSegment,
  required String pathTemplate,
  Map<String, String> pathParameters = const {},
}) {
  expect(result.pathSegment, pathSegment);
  expect(result.pathTemplate, pathTemplate);
  expect(result.builder(getRouteData(result)), route);
  expect(result.pathParameters, pathParameters);
}

class TestRoute extends Page<void> {
  final String id;

  const TestRoute(this.id);

  @override
  String toString() {
    return "Test route '$id'";
  }

  @override
  Route<void> createRoute(BuildContext context) {
    throw UnimplementedError();
  }
}

RouteData getRouteData(RouterResult routerResult) {
  return RouteData(
    '/',
    pathTemplate: routerResult.pathTemplate,
    pathParameters: routerResult.pathParameters,
    isReplacement: false,
    requestSource: RequestSource.system,
  );
}
