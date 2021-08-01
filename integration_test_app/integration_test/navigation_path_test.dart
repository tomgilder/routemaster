import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:routemaster/routemaster.dart';
import 'navigation_test_shared.dart';
import 'dart:html';

// Runs a group of tests but with path URL strategy enabled
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Routemaster.setPathUrlStrategy();
  replaceTests(
    expectUrl: (expected) {
      expect(window.location.pathname, expected);
    },
  );
}
