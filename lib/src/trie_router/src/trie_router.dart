import 'package:routemaster/routemaster.dart';
import '../../path_parser.dart';
import 'errors.dart';
import 'router_result.dart';
import 'trie_node.dart';

/// A router for storing and retrieving routes that uses a Trie data structure.
class TrieRouter {
  final Trie<String, PageBuilder> _trie;

  /// Initializes an empty router.
  TrieRouter() : _trie = Trie();

  /// Adds all the given [routes] to the router.
  /// The key of the map is the route.
  void addAll(Map<String, PageBuilder> routes) {
    routes.forEach((key, value) {
      add(key, value);
    });
  }

  /// Throws a [ConflictingPathError] if there is a conflict.
  ///
  /// It is an error to add two segments prefixed with ':' at the same index.
  void add(String path, PageBuilder value) {
    assert(path.isNotEmpty);

    final pathSegments = pathContext.split(path);
    assert(pathSegments.isNotEmpty);

    final list = List<String>.from(pathSegments);
    var current = _trie.root;

    // Work downwards through the trie, adding nodes as needed, and keeping
    // track of whether we add any nodes.
    for (var i = 0; i < list.length; i++) {
      final pathSegment = list[i];

      // Throw an error when two segments start with ':' at the same index.
      if (pathSegment.startsWith(':') &&
          current.containsWhere((k) => k!.startsWith(':')) &&
          !current.containsWhere((k) => k == pathSegment)) {
        throw ConflictingPathError(
            list,
            List<String?>.from(list).sublist(0, i)
              ..add(current.getWhere((k) => k!.startsWith(':'))!.key));
      }

      final isLastSegment = i == list.length - 1;

      if (current.contains(pathSegment)) {
        if (isLastSegment) {
          if (current.get(pathSegment)!.value != null) {
            throw DuplicatePathError(pathContext.joinAll(pathSegments));
          }

          // A child node has already been created, need to update it so it
          // points at the right value
          current.get(pathSegment)!.value = value;
        }
      } else {
        final template = pathContext.joinAll(pathSegments.take(i + 1));

        // No matching node for path, we need to create one
        if (isLastSegment) {
          // Last segment, add a node pointing at the value
          current.add(pathSegment, value, template);
        } else {
          // Not the last segment, add null node
          current.add(pathSegment, null, template);
        }
      }

      current = current.get(pathSegment)!;
    }

    // Explicitly mark the end of a list of path segments. Otherwise, we might
    // say a path segment is present if it is a prefix of a different, longer
    // word that was added earlier.
    if (!current.contains(null)) {
      current.add(null, null, null);
    }
  }

  /// Returns a single matching result from the router, or null if no match
  /// was found.
  RouterResult? get(String route) {
    final pathSegments = pathContext.split(PathParser.stripQueryString(route));
    final parameters = <String, String>{};
    TrieNode<String?, PageBuilder?>? current = _trie.root;

    for (final segment in pathSegments) {
      if (current!.contains(segment)) {
        current = current.get(segment);
      } else if (current.containsWhere((k) => k!.startsWith(':'))) {
        // If there is a segment that starts with `:`, we should match any
        // route.
        current = current.getWhere((k) => k != null && k.startsWith(':'));

        // Add the current segment to the parameters. E.g. 'id': '123'
        parameters[current!.key!.substring(1)] = segment;
      } else {
        return null;
      }
    }

    return RouterResult(
      builder: current!.value!,
      pathParameters: parameters,
      pathSegment: route,
      pathTemplate: current.template!,
    );
  }

  /// Returns all matching results from the router, or null if no match was
  /// found.
  List<RouterResult>? getAll(String route) {
    final pathSegments = pathContext.split(PathParser.stripQueryString(route));
    final parameters = <String, String>{};
    final result = <RouterResult>[];

    void addToResult(int index, TrieNode<String?, PageBuilder?> node) {
      final p = pathContext.joinAll(pathSegments.take(index));
      result.add(
        RouterResult(
          builder: node.value!,
          pathParameters: Map.unmodifiable(parameters),
          pathSegment: p,
          pathTemplate: node.template!,
        ),
      );
    }

    TrieNode<String?, PageBuilder?>? current = _trie.root;
    var i = 0;

    for (final segment in pathSegments) {
      i++;

      if (current!.contains(segment)) {
        current = current.get(segment);
        if (current!.value != null) {
          addToResult(i, current);
        }
      } else if (current.containsWhere((k) => k!.startsWith(':'))) {
        final nextSegment =
            i < pathSegments.length - 1 ? pathSegments[i] : null;
        final nextSegmentIsParam = nextSegment?.startsWith(':') ?? false;

        // If there is a segment that starts with `:`, we should match any
        // route.
        current = current.getWhere((k) => k != null && k.startsWith(':'));

        // Add the current segment to the parameters. E.g. ':id': '123'
        parameters[current!.key!.substring(1)] = segment;

        if (!nextSegmentIsParam && current.value != null) {
          addToResult(i, current);
        }
      } else {
        return null;
      }
    }

    return result;
  }
}
