part of '../routemaster.dart';

/// An observer of changes in navigation.
///
/// This is a [NavigatorObserver] with one extra method: [didChangeRoute].
///
/// It will relay all navigation events from all [PageStackNavigator] widgets.
abstract class RoutemasterObserver extends NavigatorObserver {
  /// Creates an observer to listen to changes in navigation.
  RoutemasterObserver();

  /// The router's current route changed.
  void didChangeRoute(RouteData routeData, Page page) {}
}

/// Passes on navigation events to a list of [NavigatorObserver] objects.
class _RelayingNavigatorObserver extends NavigatorObserver {
  final Iterable<NavigatorObserver> Function() getObservers;

  _RelayingNavigatorObserver(this.getObservers);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in getObservers().toList()) {
      observer.didPush(route, previousRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in getObservers().toList()) {
      observer.didPop(route, previousRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in getObservers().toList()) {
      observer.didRemove(route, previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    for (final observer in getObservers().toList()) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in getObservers().toList()) {
      observer.didStartUserGesture(route, previousRoute);
    }
  }

  @override
  void didStopUserGesture() {
    for (final observer in getObservers().toList()) {
      observer.didStopUserGesture();
    }
  }
}
