import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/src/system_nav.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() {
    if (kIsWeb) {
      // System navigation methods don't work when running test in Chrome
      SystemNav.enabled = false;
    }
  });

  await testMain();
}
