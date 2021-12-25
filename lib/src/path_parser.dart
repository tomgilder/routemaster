import 'package:path/path.dart' as path;

/// Global path URL context. Should always be used to access path methods to
/// ensure the URL style is used.
final pathContext = path.Context(style: path.Style.url);

/// Utilities for parsing paths.
class PathParser {
  /// Strips any query string from [path].
  static String stripQueryString(String path) {
    final indexOfQuery = path.indexOf('?');

    if (indexOfQuery == -1) {
      return path;
    }

    return path.substring(0, indexOfQuery);
  }

  /// Joins all provided parts seperated by '/'.
  ///
  /// Similar to path.joinAll, but doesn't reset if a later part is absolute.
  static String joinRelative(String part1,
      [String? part2,
      String? part3,
      String? part4,
      String? part5,
      String? part6,
      String? part7,
      String? part8]) {
    final parts = <String?>[
      part1,
      part2,
      part3,
      part4,
      part5,
      part6,
      part7,
      part8
    ];
    return joinAllRelative(parts.whereType<String>());
  }

  /// Joins all provided [parts] seperated by '/'.
  ///
  /// Similar to path.joinAll, but doesn't reset if a later part is absolute.
  static String joinAllRelative(Iterable<String> parts) {
    final buffer = StringBuffer();

    // final firstPart = parts.first;
    // buffer.write(firstPart);
    // var needsSeparator = !firstPart.endsWith('/');

    var isFirst = true;
    var needsSeparator = false;

    for (var part in parts.where((part) => part != '')) {
      if (isFirst) {
        buffer.write(part);
        needsSeparator = !part.endsWith('/');
        isFirst = false;
        continue;
      }

      final startsWithSeparator = part.startsWith('/');

      if (needsSeparator) {
        if (startsWithSeparator) {
          buffer.write(part);
        } else {
          buffer.write('/');
          buffer.write(part);
        }
      } else {
        if (startsWithSeparator) {
          buffer.write(part.substring(1));
        } else {
          buffer.write(part);
        }
      }

      needsSeparator = !part.endsWith('/');
    }

    return buffer.toString();
  }

  /// Returns an absolute path for [path].
  ///
  /// If [path] is already an absolute path, return that path.
  /// Otherwise return the joining of [basePath] and [path].
  static Uri getAbsolutePath({
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

    final uri = Uri.parse(absolutePath);

    if (queryParameters == null) {
      return uri;
    }

    return Uri(
      path: uri.path,
      queryParameters: <String, String>{
        // Combine query params from both path and map
        // This allows push('/two?a=b', queryParameters: {'c': 'd'})
        ...uri.queryParameters,
        ...queryParameters,
      },
    );
  }
}
