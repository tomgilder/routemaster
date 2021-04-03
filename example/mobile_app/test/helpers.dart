import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records changes in URL
Future<List<String?>> recordUrlChanges(Future Function() callback) async {
  final result = <String?>[];
  SystemChannels.navigation.setMockMethodCallHandler((call) async {
    if (call.method == 'routeInformationUpdated') {
      result.add(call.arguments['location'] as String?);
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
