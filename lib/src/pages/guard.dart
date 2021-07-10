import 'package:flutter/material.dart';
import '../../routemaster.dart';

/// Provides functionality to block pages being loaded. Generally it's cleaner
/// to **not to use this class**, and just use logic within the route map
/// to return [NotFound] or [Redirect], like this:
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
  final bool Function(RouteData info, BuildContext context) canNavigate;

  /// Callback, called when the [canNavigate] returns false.
  ///
  /// By default this redirects to the default path.
  final Page Function(RouteData info, BuildContext context)? onNavigationFailed;

  /// Initializes a way to prevent loading of certain routes.
  ///
  /// Note: it's usually cleaner to not use this class, and instead return
  /// [NotFound] or [Redirect].
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

/// Can be returned instead of a page to inform the router that the page was not
/// found.
///
/// Results in the router calling `onUnknownRoute`. By default this will show
/// [DefaultNotFoundPage].
class NotFound extends Page<dynamic> {
  /// Informs the router that no page was found.
  ///
  /// Results in the router calling `onUnknownRoute`. By default this will show
  /// [DefaultNotFoundPage].
  const NotFound();

  @override
  Route createRoute(BuildContext context) {
    throw UnsupportedError('createRoute must not be called on NotFound');
  }
}

/// Can be returned instead of a page to redirect the router to another path.
///
/// Redirect path can contain path parameters that reference path parameters of
/// the original path by name.
///
/// E.g. defining route `'/home/car/:id': (info) => Redirect('/cars/:id')`
/// in [RouteMap] and then calling
/// `Routermaster.of(context).push('/home/car/RAV4)` will result in current path
/// being `'/cars/RAV4'`.
class Redirect extends Page<dynamic> {
  /// The path to redirect to.
  ///
  /// Can contain path parameters that reference path parameters of the
  /// original path.
  final String path;

  /// Query parameters to append to [path] when redirecting.
  final Map<String, String>? queryParameters;

  /// The full redirect path, including [queryParameters].
  String get redirectPath => Uri(
        path: path,
        queryParameters: queryParameters,
      ).toString();

  /// Initializes a redirect to the given [path], with an optional map of
  /// [queryParameters].
  const Redirect(this.path, {this.queryParameters});

  @override
  Route createRoute(BuildContext context) {
    throw UnimplementedError('Redirect does not support building a route');
  }
}
