import 'dart:html';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'navigation_test_shared.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  replaceTests(
    expectUrl: (expected) {
      expect(window.location.hash, '#$expected');
    },
  );
}
