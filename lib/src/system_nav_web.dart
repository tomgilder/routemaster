import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'system_nav.dart';

class SystemNav {
  static void replaceUrl(
    String location,
    Map<String, String>? queryParameters,
  ) {
    window.history.replaceState(
      null,
      '',
      makeUrl(
        pathStrategy: _pathStrategy,
        path: location,
        queryParameters: queryParameters,
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
