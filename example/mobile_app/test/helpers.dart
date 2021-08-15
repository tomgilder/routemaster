import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class SystemUrlTracker {
  String? current;
}

/// Records changes in URL
Future<void> recordUrlChanges(
    Future Function(SystemUrlTracker url) callback) async {
  try {
    final tracker = SystemUrlTracker();
    final stackTraces = <StackTrace>[];

    SystemChannels.navigation.setMockMethodCallHandler((call) async {
      if (call.method == 'routeInformationUpdated') {
        final location = call.arguments['location'] as String;

        tracker.current = location;
        stackTraces.add(StackTrace.current);
      }
    });

    await callback(tracker);
  } finally {
    SystemChannels.navigation.setMockMethodCallHandler(null);
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
