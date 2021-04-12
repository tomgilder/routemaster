import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
