import 'package:path/path.dart' as path;
import 'package:routemaster/routemaster.dart';
import '../../query_parser.dart';
import 'errors.dart';
import 'router_result.dart';
import 'trie.dart';
import 'trie_node.dart';

class TrieRouter {
  final Trie<String, PageBuilder> _trie;

  TrieRouter() : _trie = Trie();

  void addAll(Map<String, PageBuilder> routes) {
    routes.forEach((key, value) {
      add(key, value);
    });
  }

  /// Throws a [ConflictingPathError] if there is a conflict.
  ///
  /// It is an error to add two segments prefixed with ':' at the same index.
  bool add(String route, PageBuilder value) {
    var pathSegments = path.split(route);
    return addPathComponents(pathSegments, value);
  }

  /// Throws a [ConflictingPathError] if there is a conflict.
  ///
  /// It is an error to add two segments prefixed with ':' at the same index.
  bool addPathComponents(Iterable<String> pathSegments, PageBuilder value) {
    var list = List<String>.from(pathSegments);
    TrieNode<String?, PageBuilder?>? current = _trie.root;
    var isNew = false;

    // Allow an empty list of path segments to associate a value at the root
    if (pathSegments.isEmpty) {
      _trie.root.value = value;
    }

    // Work downwards through the trie, adding nodes as needed, and keeping
    // track of whether we add any nodes.
    for (var i = 0; i < list.length; i++) {
      var pathSegment = list[i];

      // Throw an error when two segments start with ':' at the same index.
      if (pathSegment.startsWith(':') &&
          current!.containsWhere((k) => k!.startsWith(':')) &&
          !current.containsWhere((k) => k == pathSegment)) {
        throw ConflictingPathError(
            list,
            List<String?>.from(list).sublist(0, i)
              ..add(current.getWhere((k) => k!.startsWith(':'))!.key));
      }

      if (!current!.contains(pathSegment)) {
        isNew = true;
        current.add(pathSegment, value);
      }

      current = current.get(pathSegment);
    }

    // Explicitly mark the end of a list of path segments. Otherwise, we might
    // say a path segment is present if it is a prefix of a different, longer
    // word that was added earlier.
    if (!current!.contains(null)) {
      isNew = true;
      current.add(null, null);
    }
    return isNew;
  }

  bool contains(Iterable<String> pathSegments) {
    TrieNode<String?, PageBuilder?>? current = _trie.root;

    for (var segment in pathSegments) {
      if (current!.contains(segment)) {
        current = current.get(segment);
      } else if (current.containsWhere((k) => k!.startsWith(':'))) {
        // If there is a segment that starts with `:`, we should match any
        // route.
        current = current.getWhere((k) => k!.startsWith(':'));
      } else {
        return false;
      }
    }

    return current!.contains(null);
  }

  RouterResult? get(String route) {
    var pathSegments = path.split(QueryParser.stripQueryString(route));
    var parameters = <String, String>{};
    TrieNode<String?, PageBuilder?>? current = _trie.root;

    for (var segment in pathSegments) {
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

    return RouterResult(current!.value!, parameters, route);
  }

  List<RouterResult>? getAll(String route) {
    var pathSegments = path.split(QueryParser.stripQueryString(route));
    var parameters = <String, String>{};
    TrieNode<String?, PageBuilder?>? current = _trie.root;

    final result = <RouterResult>[];
    var i = 0;

    void addCurrentToResult() => result.add(
          RouterResult(
            current!.value!,
            Map.unmodifiable(parameters),
            path.joinAll(pathSegments.take(i)),
          ),
        );

    for (var segment in pathSegments) {
      if (current!.contains(segment)) {
        if (current.value != null) {
          // Flush current value to results
          addCurrentToResult();
        }

        current = current.get(segment);
      } else if (current.containsWhere((k) => k!.startsWith(':'))) {
        // If there is a segment that starts with `:`, we should match any
        // route.
        current = current.getWhere((k) => k != null && k.startsWith(':'));

        // Add the current segment to the parameters. E.g. ':id': '123'
        parameters[current!.key!.substring(1)] = segment;
      } else {
        return null;
      }

      i++;
    }

    // Flush final value to results
    addCurrentToResult();
    return result;
  }
}
