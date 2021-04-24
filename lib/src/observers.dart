part of '../routemaster.dart';

abstract class RoutemasterObserver extends NavigatorObserver {
  void didChangeRoute(RouteData routeData, Page page);
}

class _RelayingNavigatorObserver extends NavigatorObserver {
  final List<NavigatorObserver> Function() getObservers;

  _RelayingNavigatorObserver(this.getObservers);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in getObservers()) {
      observer.didPush(route, previousRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in getObservers()) {
      observer.didPop(route, previousRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in getObservers()) {
      observer.didRemove(route, previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    for (final observer in getObservers()) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in getObservers()) {
      observer.didStartUserGesture(route, previousRoute);
    }
  }

  @override
  void didStopUserGesture() {
    for (final observer in getObservers()) {
      observer.didStopUserGesture();
    }
  }
}
