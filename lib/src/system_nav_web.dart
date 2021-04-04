import 'dart:html';

class SystemNav {
  static void back() {
    window.history.back();
  }

  static void replaceLocation(
    String location,
    Map<String, String>? queryParameters,
  ) {
    // TODO: Support https://pub.dev/packages/url_strategy
    final url = Uri(path: location, queryParameters: queryParameters);
    window.location.replace('#' + url.toString());
  }
}
