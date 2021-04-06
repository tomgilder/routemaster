import 'query_parser.dart';
import 'trie_router/trie_router.dart';

/// Information generated from a specific path (URL).
///
/// This object has value equality - objects are equal if the path,
/// queryParameters and pathParameters all match.
class RouteInfo {
  /// The full path that generated this route.
  final String path;

  /// Query parameters from the path.
  ///
  ///   e.g. a route template of /profile:id and a path of /profile/1
  ///        becomes `pathParameters['id'] == '1'`.
  ///
  final Map<String, String> pathParameters;

  /// Query parameters from the path.
  ///
  ///   e.g. /page?hello=world becomes `queryParameters['hello'] == 'world'`.
  ///
  final Map<String, String> queryParameters;

  final bool isReplacement;

  RouteInfo.fromRouterResult(
    RouterResult result,
    this.path, {
    this.isReplacement = false,
  })  : pathParameters = result.pathParameters,
        queryParameters = QueryParser.parseQueryParameters(path);

  RouteInfo(
    this.path, {
    this.pathParameters = const {},
    this.isReplacement = false,
  }) : queryParameters = QueryParser.parseQueryParameters(path);

  @override
  bool operator ==(Object other) => other is RouteInfo && path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => "RouteInfo: '$path'";
}
