import 'package:flutter/foundation.dart';
import 'system_nav.dart';

class SystemNav {
  static void setHash(String location, Map<String, String>? queryParameters) {
    throw UnsupportedError('Only supported on web');
  }

  static void setPathUrlStrategy() {
    throw UnsupportedError('Only supported on web');
  }

  static PathStrategy get pathStrategy {
    throw UnsupportedError('Only supported on web');
  }

  @visibleForTesting
  static void setFakePathUrlStrategy() {}
}
