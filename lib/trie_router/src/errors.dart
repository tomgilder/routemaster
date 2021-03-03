/// Indicates the user has configured their routes improperly.
class RouteConfigurationError extends Error {}

class ConflictingPathError extends RouteConfigurationError {
  final Iterable<String> segmentsToAdd;
  final Iterable<String> segmentsAlreadyAdded;

  ConflictingPathError(this.segmentsToAdd, this.segmentsAlreadyAdded);

  String toString() {
    return "Attempt to add $segmentsToAdd but a path containing "
        "$segmentsAlreadyAdded has already been added. Adding two paths "
        "prefixed with ':' at the same index is not allowed.";
  }
}
