import 'package:routemaster/routemaster.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:routemaster/src/path_parser.dart';
import 'fake_html.dart' if (dart.library.js) 'dart:html';
import 'package:flutter/foundation.dart';
import 'system_nav.dart';
// ignore_for_file: public_member_api_docs

class SystemNav {
  static HashUrlStrategy? _urlStrategy;

  /// Used to disable system navigation from tests when running in Chrome
  static bool enabled = true;

  static void setPathUrlStrategy() {
    _urlStrategy = PathUrlStrategy();
    setUrlStrategy(_urlStrategy);
  }

  @visibleForTesting
  static void setHashUrlStrategy() {
    _urlStrategy = const HashUrlStrategy();
    setUrlStrategy(_urlStrategy);
  }

  /// Attempts to guess the current URL strategy based on whether a hash is set
  /// or not. This is to deal with users directly setting the URL strategy.
  static void _setDefaultUrlStrategy() {
    _urlStrategy = historyProvider!.hash.isNotEmpty
        ? const HashUrlStrategy()
        : PathUrlStrategy();
  }

  static void back() {
    historyProvider!.back();
  }

  static void forward() {
    historyProvider!.forward();
  }

  /// Allows tests to mock browser history
  @visibleForTesting
  static HistoryProvider? historyProvider = BrowserHistoryProvider();

  static String makePublicUrl(RouteData routeData) {
    if (_urlStrategy == null) {
      _setDefaultUrlStrategy();
    }

    return _urlStrategy!.prepareExternalUrl(
      routeData.queryParameters.isEmpty
          ? PathParser.stripQueryString(routeData.publicPath)
          : routeData.publicPath,
    );
  }
}

class BrowserHistoryProvider implements HistoryProvider {
  @override
  String get hash => window.location.hash;

  @override
  void back() => window.history.back();

  @override
  void forward() => window.history.forward();
}
