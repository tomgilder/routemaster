import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/src/system_nav.dart';

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
  return _ambiguate(WidgetsBinding.instance)!.handlePopRoute();
}

Future<void> setSystemUrl(String url) {
  // ignore: invalid_use_of_protected_member
  return _ambiguate(WidgetsBinding.instance)!.handlePushRoute(url);
}

T? _ambiguate<T>(T? value) => value;

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
