// TODO: Do we need this? Can we just use a string?
// Will this play a part in state restoration?
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
