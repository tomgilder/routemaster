import 'package:routemaster/src/query_parser.dart';

import 'trie_router/trie_router.dart';

/// Information generated from a specific path (URL).
class RouteInfo {
  final String path;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  RouteInfo(RouterResult result, Map<String, String> queryParameters)
      : path = result.pathSegment,
        pathParameters = result.pathParameters,
        queryParameters = queryParameters;

  @override
  bool operator ==(Object other) => other is RouteInfo && path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => "RouteInfo: '$path'";
}
