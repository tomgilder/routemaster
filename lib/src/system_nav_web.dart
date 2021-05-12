import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'route_data.dart';
import 'system_nav.dart';

class SystemNav {
  /// Allows tests to mock browser history
  @visibleForTesting
  static HistoryProvider? historyProvider;

  static void replaceUrl(RouteData routeData) {
    historyProvider ??= BrowserHistoryProvider();
    historyProvider!.replaceState(
      null,
      '',
      makeUrl(
        pathStrategy: _pathStrategy,
        path: routeData.path,
        queryParameters: routeData.queryParameters,
      ),
    );
  }

  static void setPathUrlStrategy() {
    _pathStrategy = PathStrategy.path;
    setUrlStrategy(PathUrlStrategy());
  }

  /// Used from tests: pretends we're using the path URL strategy.
  /// Otherwise calls to replace() won't work from tests.
  @visibleForTesting
  static void setFakePathUrlStrategy() {
    _pathStrategy = PathStrategy.path;
  }

  static PathStrategy _pathStrategy = PathStrategy.hash;
  static PathStrategy get pathStrategy => _pathStrategy;
}

class BrowserHistoryProvider implements HistoryProvider {
  @override
  void replaceState(dynamic data, String title, String? url) {
    window.history.replaceState(data, title, url);
  }
}
