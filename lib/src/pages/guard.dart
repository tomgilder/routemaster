import 'package:flutter/material.dart';
import '../../routemaster.dart';

typedef CanNavigateCallback = bool Function(
  RouteData info,
  BuildContext context,
);

typedef NavigationFailedCallback = Page Function(
  RouteData info,
  BuildContext context,
);

/// Provides functionality to block pages being loaded.
///
/// Generally it's **cleaner not to use this class**, and just use logic within
/// the route map, like this:
///
/// ```
///  '/protected-route': (route) {
///    if (!isLoggedIn()) return Redirect('/login');
///    if (!canUserAccessPage) return Redirect('/no-access');
///    return ProtectedPage();
///  }
/// ```
///
/// If [canNavigate] returns true, the page returned by [builder] is shown.
///
/// If it returns false, the [onNavigationFailed] function is called. This can
/// either return a new page, or return [Redirect] to go to a different path.
///
/// If no [onNavigationFailed] is provided, the default behavior is to redirect
/// to the router's default path.
class Guard extends Page<dynamic> {
  /// A function that returns a page to show if [canNavigate] returns true.
  final Page Function() builder;

  /// Callback to check if the route is valid. If this returns false,
  /// [onNavigationFailed] is called.
  ///
  /// If [onNavigationFailed] is null, `onUnknownRoute` is called.
  final CanNavigateCallback canNavigate;

  /// Callback, called when the [canNavigate] returns false.
  ///
  /// By default this redirects to the default path.
  final NavigationFailedCallback? onNavigationFailed;

  const Guard({
    required this.builder,
    required this.canNavigate,
    this.onNavigationFailed,
  });

  @override
  Route createRoute(BuildContext context) {
    throw UnsupportedError('Guards must be unwrapped');
  }
}

/// Tells the router the page was not found, and causes the router to call
/// `onUnknownRoute`. By default this will show [DefaultUnknownRoutePage].
class NotFound extends Page<dynamic> {
  const NotFound();

  @override
  Route createRoute(BuildContext context) {
    throw UnsupportedError('createRoute must not be called on NotFound');
  }
}

/// A page results which tells the router to redirect to another page.
class Redirect extends Page<dynamic> {
  /// The path to redirect to.
  final String path;

  /// Query parameters to append to [path] when redirecting.
  final Map<String, String>? queryParameters;

  /// The full redirect path, including [queryParameters].
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
