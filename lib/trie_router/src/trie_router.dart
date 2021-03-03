import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:quiver/core.dart';
import 'errors.dart';
import 'trie.dart';

class TrieRouter<T> {
  final Trie<String, T> _trie;

  TrieRouter() : _trie = Trie();

  /// Throws a [ConflictingPathError] if there is a conflict.
  ///
  /// It is an error to add two segments prefixed with ':' at the same index.
  bool add(String route, T value) {
    var pathSegments = path.split(route);
    print(pathSegments);
    return addPathComponents(pathSegments, value);
  }

  /// Throws a [ConflictingPathError] if there is a conflict.
  ///
  /// It is an error to add two segments prefixed with ':' at the same index.
  bool addPathComponents(Iterable<String> pathSegments, T value) {
    var list = List<String>.from(pathSegments);
    var current = _trie.root;
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
          current.containsWhere((k) => k.startsWith(':')) &&
          !current.containsWhere((k) => k == pathSegment)) {
        throw ConflictingPathError(
            list,
            List<String>.from(list).sublist(0, i)
              ..add(current.getWhere((k) => k.startsWith(':')).key));
      }

      if (!current.contains(pathSegment)) {
        isNew = true;
        current.add(pathSegment, value);
      }

      current = current.get(pathSegment);
    }

    // Explicitly mark the end of a list of path segments. Otherwise, we might
    // say a path segment is present if it is a prefix of a different, longer
    // word that was added earlier.
    if (!current.contains(null)) {
      isNew = true;
      current.add(null, null);
    }
    return isNew;
  }

  bool contains(Iterable<String> pathSegments) {
    var current = _trie.root;

    for (var segment in pathSegments) {
      if (current.contains(segment)) {
        current = current.get(segment);
      } else if (current.containsWhere((k) => k.startsWith(':'))) {
        // If there is a segment that starts with `:`, we should match any
        // route.
        current = current.getWhere((k) => k.startsWith(':'));
      } else {
        return false;
      }
    }

    return current.contains(null);
  }

  String _stripQueryString(String path) {
    final indexOfQuery = path.indexOf('?');

    if (indexOfQuery == -1) {
      return path;
    }

    return path.substring(0, indexOfQuery);
  }

  RouterData<T> get(String route) {
    assert(route != null);

    var pathSegments = path.split(_stripQueryString(route));
    var parameters = <String, String>{};
    var current = _trie.root;

    for (var segment in pathSegments) {
      if (current.contains(segment)) {
        current = current.get(segment);
      } else if (current.containsWhere((k) => k.startsWith(':'))) {
        // If there is a segment that starts with `:`, we should match any
        // route.
        current = current.getWhere((k) => k != null && k.startsWith(':'));

        // Add the current segment to the parameters. E.g. 'id': '123'
        parameters[current.key.substring(1)] = segment;
      } else {
        return null;
      }
    }

    return RouterData(current.value, parameters, route);
  }

  List<RouterData<T>> getAll(String route) {
    assert(route != null);

    var pathSegments = path.split(_stripQueryString(route));
    var parameters = <String, String>{};
    var current = _trie.root;

    final result = <RouterData<T>>[];
    int i = 0;

    void addCurrentToResult() => result.add(
          RouterData(
            current.value,
            Map.unmodifiable(parameters),
            path.joinAll(pathSegments.take(i)),
          ),
        );

    for (var segment in pathSegments) {
      if (current.contains(segment)) {
        if (current.value != null) {
          // Flush current value to results
          addCurrentToResult();
        }

        current = current.get(segment);
      } else if (current.containsWhere((k) => k.startsWith(':'))) {
        // If there is a segment that starts with `:`, we should match any
        // route.
        current = current.getWhere((k) => k != null && k.startsWith(':'));

        // Add the current segment to the parameters. E.g. ':id': '123'
        parameters[current.key.substring(1)] = segment;
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

class RouterData<T> {
  final T value;
  final Map<String, String> parameters;
  final String path;

  const RouterData(this.value, this.parameters, this.path)
      : assert(value != null),
        assert(parameters != null),
        assert(path != null);

  @override
  int get hashCode =>
      hash3(value, DeepCollectionEquality().hash(parameters), path);

  @override
  bool operator ==(Object other) {
    return other is RouterData<T> &&
        value == other.value &&
        path == path &&
        DeepCollectionEquality().equals(parameters, other.parameters);
  }

  @override
  String toString() {
    return "RouterData - path: '$path', value: '$value', params: '$parameters'";
  }
}
