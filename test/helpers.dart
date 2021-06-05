import 'package:flutter/foundation.dart';
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
  final void Function(String) onReplaceState;

  MockHistoryProvider(this.onReplaceState);

  @override
  void replaceState(dynamic data, String title, String? url) {
    if (url != null) {
      onReplaceState(url.startsWith('#') ? url.substring(1) : url);
    }
  }

  @override
  String hash = '#';
}

/// Records changes in URL
Future<List<String?>> recordUrlChanges(Future Function() callback) async {
  final result = <String?>[];
  final stackTraces = <StackTrace>[];

  final webHistoryProvider = MockHistoryProvider((url) {
    result.add(url);
  });

  SystemNav.historyProvider = webHistoryProvider;

  SystemChannels.navigation.setMockMethodCallHandler((call) async {
    if (call.method == 'routeInformationUpdated') {
      final location = call.arguments['location'] as String;
      if (result.isNotEmpty && result.last == location) {
        throw "Duplicate location recorded: '$location'.\n\nPrevious route was added from:\n\n${stackTraces.last}";
      }
      result.add(location);
      stackTraces.add(StackTrace.current);
    }
  });

  await callback();
  SystemChannels.navigation.setMockMethodCallHandler(null);
  SystemNav.historyProvider = null;
  return result;
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
  const PageThree();
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
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
