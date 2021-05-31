part of '../../routemaster.dart';

/// Information generated from a specific path (URL).
///
/// This object has value equality - objects are equal if the paths match.
class RouteData {
  final Uri _uri;

  /// The full path that generated this route, including query string.
  String get fullPath => _uri.toString();

  /// The path component of this route, without query string.
  ///
  /// For the full path including query string, use [fullPath].
  String get path => _uri.path;

  /// Query parameters from the path.
  ///
  ///   e.g. a route template of '/profile/:id' and a path of '/profile/1'
  ///        becomes `pathParameters['id'] == '1'`.
  ///
  final Map<String, String> pathParameters;

  /// Query parameters from the path.
  ///
  ///   e.g. /page?hello=world becomes `queryParameters['hello'] == 'world'`.
  ///
  Map<String, String> get queryParameters => _uri.queryParameters;

  /// Did this route replace the previous one, preventing the user from
  /// returning to it.
  final bool isReplacement;

  /// The template for this route, for instance '/profile/:id'.
  final String? pathTemplate;

  /// Initializes routing data from a path string.
  RouteData(
    String path, {
    this.pathParameters = const {},
    this.isReplacement = false,
    this.pathTemplate,
  }) : _uri = Uri.parse(path);

  RouteData.fromUri(
    Uri uri, {
    this.pathParameters = const {},
    this.isReplacement = false,
    this.pathTemplate,
  }) : _uri = uri;

  /// Initializes routing data from the provided router result.
  RouteData.fromRouterResult(
    RouterResult result,
    Uri uri, {
    this.isReplacement = false,
  })  : _uri = uri,
        pathParameters = result.pathParameters,
        pathTemplate = result.pathTemplate;

  @override
  bool operator ==(Object other) => other is RouteData && _uri == other._uri;

  @override
  int get hashCode => _uri.hashCode;

  @override
  String toString() => _uri.toString();

  /// Creates a [RouteInformation] object with data from this route.
  RouteInformation toRouteInformation() {
    return RouteInformation(
      location: fullPath,
      state: {
        'isReplacement': isReplacement,
      },
    );
  }

  /// Gets the [RouteData] for the nearest [Page] ancestor for the given
  /// context.
  static RouteData of(BuildContext context) {
    final modalRoute = ModalRoute.of(context);
    assert(modalRoute != null, "Couldn't get modal route");
    assert(modalRoute!.settings is Page, "Modal route isn't a page route");

    final page = modalRoute!.settings as Page;
    return PageStackNavigator.of(context).routeDataFor(page)!;
  }
}
