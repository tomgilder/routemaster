import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

Future<bool> popRouterDelegate(WidgetTester tester) {
  return (tester.state(find.byType(MaterialApp)).widget as MaterialApp)
      .routerDelegate
      .popRoute();
}
