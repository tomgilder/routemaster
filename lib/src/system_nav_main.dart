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

  static PathStrategy get pathStrategy {
    throw UnsupportedError('Only supported on web');
  }

  @visibleForTesting
  static void setFakePathUrlStrategy() {}
}
