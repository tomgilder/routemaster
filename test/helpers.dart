import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routemaster/routemaster.dart';

const kTransitionDuration = Duration(milliseconds: 310);

/// Records changes in URL
Future<List<String>> recordUrlChanges(Future Function() callback) async {
  final result = <String>[];
  SystemChannels.navigation.setMockMethodCallHandler((call) async {
    if (call.method == 'routeInformationUpdated') {
      result.add(call.arguments['location'] as String);
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

class PageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class PageTwo extends StatelessWidget {
  PageTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
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
