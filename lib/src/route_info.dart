import 'package:collection/collection.dart';
import 'package:quiver/core.dart';
import 'query_parser.dart';
import 'trie_router/trie_router.dart';
import '../routemaster.dart';

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

  /// The builder used to build this route
  final PageBuilder builder;

  RouteInfo(RouterResult result, this.path)
      : pathParameters = result.pathParameters,
        queryParameters = QueryParser.parseQueryParameters(path),
        builder = result.builder;

  @override
  bool operator ==(Object other) =>
      other is RouteInfo &&
      path == other.path &&
      DeepCollectionEquality().equals(pathParameters, other.pathParameters) &&
      DeepCollectionEquality().equals(queryParameters, other.queryParameters) &&
      builder.runtimeType == other.builder.runtimeType;

  @override
  int get hashCode => hash4(
        path,
        DeepCollectionEquality().hash(pathParameters),
        DeepCollectionEquality().hash(queryParameters),
        builder.runtimeType,
      );

  @override
  String toString() => "RouteInfo: '$path'";
}
