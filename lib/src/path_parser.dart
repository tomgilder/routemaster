import 'package:path/path.dart' as p;

class PathParser {
  static Map<String, String> parseQueryParameters(String path) {
    final queryStringStart = path.indexOf('?');
    if (queryStringStart == -1 || path.length < queryStringStart) {
      return Map.unmodifiable(const <String, String>{});
    }

    final queryString = path.substring(path.indexOf('?') + 1);

    return Map.unmodifiable(Uri.splitQueryString(queryString));
  }

  static String stripQueryString(String path) {
    final indexOfQuery = path.indexOf('?');

    if (indexOfQuery == -1) {
      return path;
    }

    return path.substring(0, indexOfQuery);
  }

  /// Returns an absolute path for [path].
  ///
  /// If [path] is already an absolute path, return that path.
  /// Otherwise return the joining of [basePath] and [path].
  static String getAbsolutePath({
    required String basePath,
    required String path,
    Map<String, String>? queryParameters,
  }) {
    final absolutePath = p.isAbsolute(path)
        ? path
        : p.join(
            stripQueryString(basePath),
            path,
          );

    if (queryParameters == null) {
      return absolutePath;
    }

    return Uri(path: absolutePath, queryParameters: queryParameters).toString();
  }
}
