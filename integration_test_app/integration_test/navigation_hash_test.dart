import 'dart:html';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'navigation_test_shared.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  replaceTests(
    expectUrl: (expected) {
      // Flutter after 3.10 has empty URLs for home route
      final hashUrl = '#$expected';
      final allowEmpty = hashUrl == '#/';

      expect(
        window.location.hash == hashUrl ||
            (allowEmpty && window.location.hash.isEmpty),
        isTrue,
      );
    },
  );
}
