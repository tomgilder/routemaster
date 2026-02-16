import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'fake_html.dart' if (dart.library.js_interop) 'package:web/web.dart';
import 'package:flutter/foundation.dart';
import 'system_nav.dart';
// ignore_for_file: public_member_api_docs

class SystemNav {
  /// Used to disable system navigation from tests when running in Chrome
  static bool enabled = true;

  static void setPathUrlStrategy() {
    setUrlStrategy(PathUrlStrategy());
  }

  @visibleForTesting
  static void setHashUrlStrategy() {
    setUrlStrategy(const HashUrlStrategy());
  }

  static void back() {
    historyProvider!.back();
  }

  static void forward() {
    historyProvider!.forward();
  }

  static void go(int delta) {
    historyProvider!.go(delta);
  }

  /// Allows tests to mock browser history
  @visibleForTesting
  static HistoryProvider? historyProvider = BrowserHistoryProvider();
}

class BrowserHistoryProvider implements HistoryProvider {
  @override
  void back() => window.history.back();

  @override
  void forward() => window.history.forward();

  @override
  void go(int delta) => window.history.go(delta);
}
