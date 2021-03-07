import 'package:collection/collection.dart';
import 'trie_router/trie_router.dart';
import 'package:quiver/core.dart';

/// Information generated from a specific path (URL).
///
/// This object has value equality - objects are equal if the path,
/// queryParameters and pathParameters all match.
class RouteInfo {
  final String path;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  RouteInfo(RouterResult result, Map<String, String> queryParameters)
      : path = result.pathSegment,
        pathParameters = result.pathParameters,
        queryParameters = queryParameters;

  @override
  bool operator ==(Object other) =>
      other is RouteInfo &&
      path == other.path &&
      DeepCollectionEquality().equals(pathParameters, other.pathParameters) &&
      DeepCollectionEquality().equals(queryParameters, other.queryParameters);

  @override
  int get hashCode => hash3(
        path,
        DeepCollectionEquality().hash(pathParameters),
        DeepCollectionEquality().hash(queryParameters),
      );

  @override
  String toString() => "RouteInfo: '$path'";
}
