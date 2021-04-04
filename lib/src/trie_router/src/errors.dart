import 'package:path/path.dart' as path;

/// Indicates the user has configured their routes improperly.
class RouteConfigurationError extends Error {}

class ConflictingPathError extends RouteConfigurationError {
  final Iterable<String> segmentsToAdd;
  final Iterable<String?> segmentsAlreadyAdded;

  ConflictingPathError(this.segmentsToAdd, this.segmentsAlreadyAdded);

  @override
  String toString() {
    return "Attempt to add '${path.joinAll(segmentsToAdd)}' but a path containing "
        "'${path.joinAll(segmentsAlreadyAdded.where((element) => element != null).map((e) => e!))}' has already been added. Adding two paths "
        "prefixed with ':' at the same index is not allowed.";
  }
}
