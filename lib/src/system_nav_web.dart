import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'system_nav.dart';

class SystemNav {
  static void setHash(
    String location,
    Map<String, String>? queryParameters,
  ) {
    assert(pathStrategy == PathStrategy.hash);

    final url = Uri(
      path: location,
      queryParameters: queryParameters,
    ).toString();
    window.location.hash = url;
  }

  static void setPathUrlStrategy() {
    print(
      "Note: using path URL strategy with Routemaster is experimental, and there's a high chance of bugs.\n\n"
      'Please file an issue at https://github.com/tomgilder/routemaster/issues if you have problems.',
    );
    _pathStrategy = PathStrategy.path;
    setUrlStrategy(RoutemasterPathUrlStrategy());
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

/// A custom URL strategy which supports replacing URLs.
class RoutemasterPathUrlStrategy extends PathUrlStrategy {
  @override
  // Uses dynamic to be compatible with different Flutter versions
  void pushState(dynamic state, String title, String url) {
    if (state != null && isReplacementNavigation(state)) {
      replaceState(state as Object, title, url);
    } else if (state is Object) {
      super.pushState(state, title, url);
    } else {
      super.pushState(Object(), title, url);
    }
  }
}
