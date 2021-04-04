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
        onPressed: () => Routemaster.of(context).popRoute(),
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
