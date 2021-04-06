class RouteData {
  final String path;

  final bool isReplacement;

  const RouteData(
    this.path, {
    this.isReplacement = false,
  });

  @override
  bool operator ==(Object other) => other is RouteData && path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => path;
}
