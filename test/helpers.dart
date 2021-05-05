import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_test/flutter_test.dart';

const kTransitionDuration = Duration(milliseconds: 310);

/// Records changes in URL
Future<List<String?>> recordUrlChanges(Future Function() callback) async {
  final result = <String?>[];
  final stackTraces = <StackTrace>[];
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
  MaterialPageOne() : super(child: PageOne());
}

class PageOne extends StatelessWidget {
  PageOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class MaterialPageTwo extends MaterialPage<void> {
  MaterialPageTwo() : super(child: PageTwo());
}

class PageTwo extends StatelessWidget {
  PageTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class MaterialPageThree extends MaterialPage<void> {
  MaterialPageThree() : super(child: PageThree());
}

class PageThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class PopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () => Routemaster.of(context).pop(),
        child: Text('Pop'),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
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
