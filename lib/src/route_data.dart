import 'package:flutter/widgets.dart';
import 'package:routemaster/routemaster.dart';
import 'trie_router/trie_router.dart';

/// Information generated from a specific path (URL).
///
/// This object has value equality - objects are equal if the paths match.
class RouteData {
  final Uri _uri;

  /// The full path that generated this route, including query string.
  String get fullPath => _uri.toString();

  /// The path component of this route, without query string.
  String get path => _uri.path;

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
  Map<String, String> get queryParameters => _uri.queryParameters;

  final bool isReplacement;

  final String? pathTemplate;

  RouteData.fromRouterResult(
    RouterResult result,
    String path, {
    this.isReplacement = false,
  })  : _uri = Uri.parse(path),
        pathParameters = result.pathParameters,
        pathTemplate = result.pathTemplate;

  RouteData(
    String path, {
    this.pathParameters = const {},
    this.isReplacement = false,
    this.pathTemplate,
  }) : _uri = Uri.parse(path);

  @override
  bool operator ==(Object other) => other is RouteData && _uri == other._uri;

  @override
  int get hashCode => _uri.hashCode;

  @override
  String toString() => _uri.toString();

  RouteInformation toRouteInformation() {
    return RouteInformation(
      location: fullPath,
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
