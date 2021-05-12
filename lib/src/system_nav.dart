export 'system_nav_main.dart' if (dart.library.js) 'system_nav_web.dart';

enum PathStrategy { hash, path }

String makeUrl({
  required PathStrategy pathStrategy,
  required String path,
  Map<String, String>? queryParameters,
}) {
  final hasQueryParameters = queryParameters?.isNotEmpty == true;
  final url = Uri(
    path: path,
    queryParameters: hasQueryParameters ? queryParameters : null,
  );

  switch (pathStrategy) {
    case PathStrategy.hash:
      return '#$url';

    case PathStrategy.path:
      return url.toString();
  }
}

/// Allows tests to mock browser history
abstract class HistoryProvider {
  void replaceState(dynamic data, String title, String? url);
}
