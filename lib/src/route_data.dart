import 'package:flutter/widgets.dart';
import 'package:routemaster/routemaster.dart';

import 'query_parser.dart';
import 'trie_router/trie_router.dart';

/// Information generated from a specific path (URL).
///
/// This object has value equality - objects are equal if the paths match.
class RouteData {
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

  final String? pathTemplate;

  RouteData.fromRouterResult(
    RouterResult result,
    this.path, {
    this.isReplacement = false,
  })  : pathParameters = result.pathParameters,
        queryParameters = QueryParser.parseQueryParameters(path),
        pathTemplate = result.pathTemplate;

  RouteData(
    this.path, {
    this.pathParameters = const {},
    this.isReplacement = false,
    this.pathTemplate,
  }) : queryParameters = QueryParser.parseQueryParameters(path);

  @override
  bool operator ==(Object other) => other is RouteData && path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => "RouteData: '$path'";

  RouteInformation toRouteInformation() {
    return RouteInformation(
      location: path,
      state: {
        'isReplacement': isReplacement,
      },
    );
  }

  static RouteData of(BuildContext context) {
    final modalRoute = ModalRoute.of(context);
    assert(modalRoute != null, "Couldn't get modal route");
    assert(modalRoute!.settings is Page, "Modal route isn't a page route");

    final page = modalRoute!.settings as Page;
    return StackNavigator.of(context).routeDataFor(page)!;
  }
}
