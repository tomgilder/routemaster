import 'trie_node.dart';

/// A Trie that associates an [Iterable] of keys, [K] with a value, [V].
///
/// Keys must be unique relative to their prefix. For example, for a
/// Trie<String, String> if the following add() operations are valid:
///
/// ```dart
/// add(['users', 'greg'], 'value');
/// add(['customers', 'greg'], 'value'); // OK
/// ```
class Trie<K, V> {
  final TrieNode<K, V> root;

  Trie() : root = TrieNode<K, V>(null, null);

  bool add(Iterable<K> keys, V value) {
    var current = root;
    var isNew = false;

    // Work downwards through the trie, adding nodes as needed, and keeping
    // track of whether we add any nodes.
    for (var key in keys) {
      if (!current.contains(key)) {
        isNew = true;
        current.add(key, value);
      }
      current = current.get(key);
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

  bool contains(Iterable<K> keys) {
    var current = root;
    for (var key in keys) {
      if (current.contains(key)) {
        current = current.get(key);
      } else {
        return false;
      }
    }
    return current.contains(null);
  }
}
