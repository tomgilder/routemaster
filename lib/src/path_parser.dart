import 'package:path/path.dart' as path;

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

  static String getAbsolutePath({
    required String currentPath,
    required String newPath,
    Map<String, String>? queryParameters,
  }) {
    final absolutePath = path.isAbsolute(newPath)
        ? newPath
        : path.join(
            stripQueryString(currentPath),
            newPath,
          );

    if (queryParameters == null) {
      return absolutePath;
    }

    return Uri(path: absolutePath, queryParameters: queryParameters).toString();
  }
}
