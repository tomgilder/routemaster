import '../../path_parser.dart';

/// Indicates the user has configured their routes improperly.
abstract class RouteConfigurationError extends Error {}

/// An error thrown when there's an attempt to add a path that conflicts with
/// one already added to the router.
class ConflictingPathError extends RouteConfigurationError {
  /// The new route segments that couldn't be added to the router.
  final Iterable<String> segmentsToAdd;

  /// The existing route segments that [segmentsToAdd] conflicted with.
  final Iterable<String?> segmentsAlreadyAdded;

  /// Initializes an error that conflicting paths have been added to the router.
  ConflictingPathError(this.segmentsToAdd, this.segmentsAlreadyAdded);

  @override
  String toString() {
    return "Attempt to add '${pathContext.joinAll(segmentsToAdd)}' but a path containing "
        "'${pathContext.joinAll(segmentsAlreadyAdded.where((element) => element != null).map((e) => e!))}' has already been added. Adding two paths "
        "prefixed with ':' at the same index is not allowed.";
  }
}

/// An error thrown when a attempt is made to add a path to the router that
/// has already been added.
class DuplicatePathError extends RouteConfigurationError {
  /// The path that is a duplicate of one already added.
  final String path;

  /// Initializes an error that duplicate paths have been added to the router.
  DuplicatePathError(this.path);

  @override
  String toString() {
    return "Attempted to add a duplicate route: router already has a route at '$path'.";
  }
}
