import 'package:flutter/material.dart';
import '../../routemaster.dart';

typedef bool ValidateCallback(RouteInfo info);

typedef void ValidationFailedCallback(Routemaster delegate, RouteInfo info);

mixin GuardedPage<T> on ProxyPage<T> {
  /// Callback to check if the route is valid. If this returns false,
  /// [onValidationFailed] is called.
  ///
  /// By default this redirects to the default path.
  ValidateCallback? get validate;

  /// Callback, called when the [validate] returns false.
  ///
  /// By default this redirects to the default path.
  ValidationFailedCallback? get onValidationFailed;
}

class Guard<T> extends ProxyPage<T> with GuardedPage<T> {
  final ValidateCallback? validate;
  final ValidationFailedCallback? onValidationFailed;

  Guard({
    required Page<T> child,
    required this.validate,
    required this.onValidationFailed,
  }) : super(child: child);
}
