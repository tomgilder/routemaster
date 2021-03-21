// TODO: Do we need this? Can we just use a string?
// Will this play a part in state restoration?
class RouteData {
  const RouteData(this.path);

  /// The pattern used to parse the route string. e.g. "/users/:id"
  final String path;

  @override
  bool operator ==(Object other) => other is RouteData && path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => path;
}
