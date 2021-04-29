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
    print(
      "Note: using path URL strategy with Routemaster is experimental, and there's a high chance of bugs.\n\n"
      'Please file an issue at https://github.com/tomgilder/routemaster/issues if you have problems.',
    );
    pathStrategy = PathStrategy.path;
    setUrlStrategy(RoutemasterPathUrlStrategy());
  }

  static PathStrategy pathStrategy = PathStrategy.hash;
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
