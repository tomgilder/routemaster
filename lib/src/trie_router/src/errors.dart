import '../../path_parser.dart';

/// Indicates the user has configured their routes improperly.
class RouteConfigurationError extends Error {}

class ConflictingPathError extends RouteConfigurationError {
  final Iterable<String> segmentsToAdd;
  final Iterable<String?> segmentsAlreadyAdded;

  ConflictingPathError(this.segmentsToAdd, this.segmentsAlreadyAdded);

  @override
  String toString() {
    return "Attempt to add '${pathContext.joinAll(segmentsToAdd)}' but a path containing "
        "'${pathContext.joinAll(segmentsAlreadyAdded.where((element) => element != null).map((e) => e!))}' has already been added. Adding two paths "
        "prefixed with ':' at the same index is not allowed.";
  }
}

class DuplicatePathError extends RouteConfigurationError {
  final String path;

  DuplicatePathError(this.path);

  @override
  String toString() {
    return "Attempted to add a duplicate route: router already has a route at '$path'.";
  }
}
