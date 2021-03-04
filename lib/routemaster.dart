library routemaster;

export 'tab_route.dart';
export 'parser.dart';
export 'delegate.dart';
export 'stack_route.dart';
export 'routes.dart';

class RouteData {
  const RouteData(this.routeString);

  /// The pattern used to parse the route string. e.g. "/users/:id"
  final String routeString;

  @override
  bool operator ==(Object other) =>
      other is RouteData && routeString == other.routeString;

  @override
  int get hashCode => routeString.hashCode;

  @override
  String toString() => 'Route: $routeString';
}
