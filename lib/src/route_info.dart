import 'package:collection/collection.dart';
import 'plans/standard.dart';
import 'trie_router/trie_router.dart';
import 'package:quiver/core.dart';

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

  /// The plan used to build this route
  final RoutePlan plan;

  RouteInfo(RouterResult result, Map<String, String> queryParameters, this.plan)
      : path = result.pathSegment,
        pathParameters = result.pathParameters,
        queryParameters = queryParameters;

  @override
  bool operator ==(Object other) =>
      other is RouteInfo &&
      path == other.path &&
      DeepCollectionEquality().equals(pathParameters, other.pathParameters) &&
      DeepCollectionEquality().equals(queryParameters, other.queryParameters) &&
      plan.runtimeType == other.plan.runtimeType;

  @override
  int get hashCode => hash4(
        path,
        DeepCollectionEquality().hash(pathParameters),
        DeepCollectionEquality().hash(queryParameters),
        plan.runtimeType,
      );

  @override
  String toString() => "RouteInfo: '$path'";
}
