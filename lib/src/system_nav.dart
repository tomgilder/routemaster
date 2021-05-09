export 'system_nav_main.dart' if (dart.library.js) 'system_nav_web.dart';

enum PathStrategy { hash, path }

bool isReplacementNavigation(dynamic state) {
  if (state is Map && state['state'] is Map) {
    final dynamic isReplacement = state['state']['isReplacement'];
    if (isReplacement is bool) {
      return isReplacement;
    }
  }

  return false;
}

String makeUrl({
  required PathStrategy pathStrategy,
  required String path,
  Map<String, String>? queryParameters,
}) {
  final url = Uri(
    path: path,
    queryParameters:
        queryParameters?.isNotEmpty == true ? queryParameters : null,
  );

  switch (pathStrategy) {
    case PathStrategy.hash:
      return '#$url';

    case PathStrategy.path:
      return url.toString();
  }
}
