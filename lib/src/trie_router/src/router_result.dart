import '../../../routemaster.dart';

class RouterResult {
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

  const RouterResult(this.builder, this.pathParameters, this.pathSegment);

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
