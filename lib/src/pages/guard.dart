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

mixin GuardedPage<T> on ProxyPage<T> {
  /// Callback to check if the route is valid. If this returns false,
  /// [onValidationFailed] is called.
  ///
  /// If [onValidationFailed] is null, `onUnknownRoute` is called.
  ValidateCallback get validate;

  /// Callback, called when the [validate] returns false.
  ///
  /// By default this redirects to the default path.
  ValidationFailedCallback? get onValidationFailed;
}

/// A page results which tells the router to redirect to another page.
class Redirect extends Page<void> {
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

class Guard extends ProxyPage<void> with GuardedPage<void> {
  @override
  final ValidateCallback validate;

  @override
  final ValidationFailedCallback? onValidationFailed;

  const Guard({
    required Page child,
    required this.validate,
    this.onValidationFailed,
  }) : super(child: child);
}
