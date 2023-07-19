import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class SystemUrlTracker {
  String? current;
}

/// Records changes in URL
Future<void> recordUrlChanges(
    Future<void> Function(SystemUrlTracker url) callback) async {
  try {
    final tracker = SystemUrlTracker();
    final stackTraces = <StackTrace>[];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.navigation, (call) async {
      if (call.method == 'routeInformationUpdated') {
        final args = call.arguments as Map;
        final location = args.containsKey('uri')
            ? args['uri'] as String
            : args['location'] as String;

        tracker.current = location;
        stackTraces.add(StackTrace.current);
      }
      return null;
    });

    await callback(tracker);
  } finally {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.navigation, null);
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
