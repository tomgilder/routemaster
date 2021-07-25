import '../../../routemaster.dart';

/// A match for a path returned from [TrieRouter].
class RouterResult {
  /// The original path template for this route, such as '/products/productId'.
  final String pathTemplate;

  /// The builder matching the path
  final PageBuilder builder;

  /// Path parameters matched in this path section
  /// e.g. '/blah/:id' becomes `pathParameters['id']`
  final Map<String, String> pathParameters;

  /// The path for this path segment. This isn't the complete path requested.
  /// e.g. a look up for '/blah/test' will return 3 RouterResults with paths:
  ///         1. /
  ///         2. /blah
  ///         3. /blah/test
  final String pathSegment;

  /// Initializes a router result.
  const RouterResult({
    required this.builder,
    required this.pathParameters,
    required this.pathSegment,
    required this.pathTemplate,
  });

  @override
  int get hashCode => pathSegment.hashCode;

  @override
  bool operator ==(Object other) {
    return other is RouterResult && pathSegment == other.pathSegment;
  }

  @override
  String toString() {
    return "RouterData - path: '$pathSegment',  params: '$pathParameters'";
  }
}
