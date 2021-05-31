import 'package:path/path.dart' as path;

final pathContext = path.Context(style: path.Style.url);

class PathParser {
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
    final absolutePath = pathContext.isAbsolute(path)
        ? path
        : pathContext.join(
            stripQueryString(basePath),
            path,
          );

    if (queryParameters == null) {
      return absolutePath;
    }

    final uri = Uri.parse(absolutePath);
    return Uri(
      path: uri.path,
      queryParameters: <String, String>{
        // Combine query params from both path and map
        // This allows push('/two?a=b', queryParameters: {'c': 'd'})
        ...uri.queryParameters,
        ...queryParameters,
      },
    ).toString();
  }
}
