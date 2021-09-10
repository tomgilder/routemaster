import 'package:flutter/material.dart';

import 'core.dart';
import 'not_found_page.dart';
import 'trie_router/trie_router.dart';

/// A standard simple routing table which takes a map of routes.
///
///   * [routes] - A map of paths and [PageBuilder] delegates that return
///     [Page] objects to build.
///
@immutable
class RouteMap {
  final UnknownRouteCallback? _onUnknownRoute;

  final _router = TrieRouter();

  /// Creates a standard simple routing table which takes a map of routes.
  ///
  ///   * [routes] - a map of paths and [PageBuilder] delegates that return
  ///     [Page] objects to build.
  ///
  ///   * [onUnknownRoute] - called when there's no match for a route.
  ///     There are two general options for this callback's operation:
  ///
  ///       1. Return a page, which will be displayed.
  ///
  ///     or
  ///
  ///       2. Use the routing delegate to, for instance, redirect to another
  ///          route and return null.
  ///
  RouteMap({
    required Map<String, PageBuilder> routes,
    UnknownRouteCallback? onUnknownRoute,
  }) : _onUnknownRoute = onUnknownRoute {
    _router.addAll(routes);
  }

  /// Generate a single [RouteResult] for the given [path]. Returns null if the
  /// path isn't valid.
  RouterResult? get(String path) {
    return _router.get(path);
  }

  /// Generate all [RouteResult] objects required to build the navigation tree
  /// for the given [path]. Returns null if the path isn't valid.
  List<RouterResult>? getAll(String path) {
    return _router.getAll(path);
  }

  /// Called when there's no match for a route. By default this returns
  /// [DefaultNotFoundPage], a simple page not found page.
  ///
  /// There are two general options for this callback's operation:
  ///
  ///   1. Return a page, which will be displayed.
  ///
  /// or
  ///
  ///   2. Use the routing delegate to, for instance, redirect to another route
  ///      and return null.
  ///
  RouteSettings onUnknownRoute(String path) {
    if (_onUnknownRoute != null) {
      return _onUnknownRoute!(path);
    }

    return MaterialPage<void>(
      child: DefaultNotFoundPage(path: path),
    );
  }
}
