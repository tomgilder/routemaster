part of '../routemaster.dart';

/// Information generated from a specific path (URL).
///
/// This object has value equality: objects are equal if the paths match.
class RouteData {
  final Uri _uri;

  /// The full path that generated this route, including query string.
  String get fullPath => _uri.toString();

  /// The user-visible path for this route, shown in a browser's address bar.
  ///
  /// This is only different from [fullPath] when using a private route,
  /// such as '/products/_secret/page', which will show in an address bar as
  /// '/products'; everything after the underscore is cut off.
  ///
  /// Private routes are useful for making pages that users cannot navigate to
  /// directly by entering a URL. For example, you may want to prevent a user
  /// from navigating directly to step two of a wizard, without having first
  /// completed step one.
  String get publicPath {
    if (_publicPath == null) {
      final path = _uri.toString();

      if (_privateSegmentIndex == null) {
        _publicPath = path;
      } else {
        _publicPath = pathContext.joinAll(
          pathContext.split(path).take(_privateSegmentIndex!),
        );
      }
    }

    return _publicPath!;
  }

  String? _publicPath;

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
  ///
  /// Will only be null on unknown routes generated from
  /// [RouteMap.onUnknownRoute].
  final String? pathTemplate;

  /// The source of the original navigation request for this route.
  /// See [RequestSource] for the options.
  final RequestSource requestSource;

  /// Initializes routing data from a path string.
  RouteData(
    String path, {
    required this.pathTemplate,
    this.pathParameters = const {},
    this.isReplacement = false,
    this.requestSource = RequestSource.system,
  })  : _uri = Uri.parse(path),
        _privateSegmentIndex = _getPrivateSegmentIndex(pathTemplate);

  /// Initializes routing data from a [Uri].
  RouteData._fromUri(
    Uri uri, {
    required this.pathTemplate,
    this.pathParameters = const {},
    this.isReplacement = false,
    this.requestSource = RequestSource.system,
  })  : _uri = uri,
        _privateSegmentIndex = _getPrivateSegmentIndex(pathTemplate);

  /// Initializes routing data from the provided router result.
  RouteData._fromRouterResult(
    RouterResult result,
    Uri uri, {
    required this.requestSource,
    required this.isReplacement,
  })  : _uri = uri,
        pathParameters = result.pathParameters,
        pathTemplate = result.pathTemplate,
        _privateSegmentIndex = _getPrivateSegmentIndex(result.pathTemplate);

  final int? _privateSegmentIndex;
  static int? _getPrivateSegmentIndex(String? pathTemplate) {
    if (pathTemplate == null) {
      return null;
    }

    var i = 0;
    for (final path in pathContext.split(pathTemplate)) {
      if (path.startsWith('_') || path.startsWith(':_')) {
        return i;
      }

      i++;
    }

    return null;
  }

  @override
  bool operator ==(Object other) => other is RouteData && _uri == other._uri;

  @override
  int get hashCode => _uri.hashCode;

  @override
  String toString() => _uri.toString();

  /// Creates a [RouteInformation] object with data from this route.
  RouteInformation toRouteInformation() {
    return RouteInformation(
      location: publicPath,
      state: {
        'isReplacement': isReplacement,
        'internalPath': fullPath,
        'requestSource': requestSource.toString(),
        'pathTemplate': pathTemplate,
        'pathParameters': pathParameters,
      },
    );
  }

  /// Creates a [RouteData] from a [RouteInformation].
  ///
  /// The [RouteInformation] will usually be provided by the system.
  static RouteData fromRouteInformation(RouteInformation routeInfo) {
    final state = routeInfo.state;
    if (state is Map) {
      final requestSource = state['requestSource'] as String;

      return RouteData(
        state['internalPath'] as String,
        isReplacement: state['isReplacement'] as bool,
        requestSource: RequestSource.values.firstWhere(
          (source) => source.toString() == requestSource,
        ),
        pathTemplate: state['pathTemplate'] as String,
        pathParameters: (state['pathParameters'] as Map<String, dynamic>)
            .cast<String, String>(),
      );
    }

    // No state: we only got a URL from the system, so probably a
    // manually-entered URL from the user.
    return RouteData(
      routeInfo.location!,
      pathTemplate: routeInfo.location!,
      requestSource: RequestSource.system,
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

  /// Gets the [RouteData] for the nearest [Page] ancestor for the given
  /// context, or null if the given context doesn't have associated RouteData.
  static RouteData? maybeOf(BuildContext context) {
    final modalRoute = ModalRoute.of(context);
    final page = modalRoute?.settings;

    if (page is Page) {
      return PageStackNavigator.of(context).routeDataFor(page);
    }

    return null;
  }
}
