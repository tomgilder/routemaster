import 'package:flutter/foundation.dart';
import '../routemaster.dart';
import 'system_nav.dart';
// ignore_for_file: public_member_api_docs

class SystemNav {
  static HistoryProvider? historyProvider;

  /// Used to disable system navigation from tests when running in Chrome
  static bool enabled = true;

  static void setPathUrlStrategy() {
    throw UnsupportedError('Only supported on web');
  }

  @visibleForTesting
  static void setHashUrlStrategy() {
    throw UnsupportedError('Only supported on web');
  }

  static String makePublicUrl(RouteData routeData) {
    throw UnsupportedError('Only supported on web');
  }

  static String back() {
    throw UnsupportedError('Only supported on web');
  }

  static String forward() {
    throw UnsupportedError('Only supported on web');
  }
}
