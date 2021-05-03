import 'package:flutter/material.dart';
import '../../routemaster.dart';

typedef ValidateCallback = bool Function(
  RouteData info,
  BuildContext context,
);

typedef ValidationFailedCallback = Page Function(
  RouteData info,
  BuildContext context,
);

/// A page that wraps other pages in order to provide more functionality.
///
/// Similar to [ProxyPage] but uses a builder method so the page doesn't build
/// until the route is required.
///
/// For example, [Guarded] adds validation functionality for routes.
class Guard extends Page<dynamic> {
  final Page Function() builder;

  /// Callback to check if the route is valid. If this returns false,
  /// [onValidationFailed] is called.
  ///
  /// If [onValidationFailed] is null, `onUnknownRoute` is called.
  final ValidateCallback validate;

  /// Callback, called when the [validate] returns false.
  ///
  /// By default this redirects to the default path.
  final ValidationFailedCallback? onValidationFailed;

  const Guard({
    required this.builder,
    required this.validate,
    this.onValidationFailed,
  });

  @override
  Route createRoute(BuildContext context) {
    throw UnsupportedError('Guards must be unwrapped');
  }
}

class NotFound extends Page<dynamic> {
  const NotFound();

  @override
  Route createRoute(BuildContext context) {
    throw UnsupportedError('Guards must be unwrapped');
  }
}

/// A page results which tells the router to redirect to another page.
class Redirect extends Page<dynamic> {
  final String path;
  final Map<String, String>? queryParameters;

  String get redirectPath => Uri(
        path: path,
        queryParameters: queryParameters,
      ).toString();

  const Redirect(this.path, {this.queryParameters});

  @override
  Route createRoute(BuildContext context) {
    throw UnimplementedError('Redirect does not support building a route');
  }
}
