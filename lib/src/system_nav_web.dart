import 'dart:html';
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
    pathStrategy = PathStrategy.path;
    setUrlStrategy(RoutemasterPathUrlStrategy());
  }

  static PathStrategy pathStrategy = PathStrategy.hash;
}

/// A custom URL strategy which supports replacing URLs.
class RoutemasterPathUrlStrategy extends PathUrlStrategy {
  @override
  void pushState(Object state, String title, String url) {
    if (isReplacementNavigation(state)) {
      replaceState(state, title, url);
    } else {
      super.pushState(state, title, url);
    }
  }
}
