import 'package:flutter/foundation.dart';
import '../routemaster.dart';
import 'system_nav.dart';

class SystemNav {
  static HistoryProvider? historyProvider;

  static void replaceUrl(RouteData routeData) {
    throw UnsupportedError('Only supported on web');
  }

  static void setPathUrlStrategy() {
    throw UnsupportedError('Only supported on web');
  }

  @visibleForTesting
  static void setHashUrlStrategy() {
    throw UnsupportedError('Only supported on web');
  }

  static String makeUrl({
    required String path,
    Map<String, String>? queryParameters,
  }) {
    throw UnsupportedError('Only supported on web');
  }
}
