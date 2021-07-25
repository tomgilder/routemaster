// ignore_for_file: public_member_api_docs

/// A node in the trie containing multiple child nodes.
///
/// [K] is the key and is unique relative to the parent, not the entire data
/// structure. [V] is an element stored in the Trie.
class TrieNode<K, V> {
  final Map<K, TrieNode<K, V>> _children;
  final K key;
  final String? template;
  V value;

  TrieNode(this.key, this.value, this.template) : _children = {};

  bool contains(K key) {
    return _children.containsKey(key);
  }

  void add(K key, V value, String? template) {
    _children[key] = TrieNode<K, V>(key, value, template);
  }

  TrieNode<K, V>? get(K key) {
    return _children.containsKey(key) ? _children[key] : null;
  }

  bool containsWhere(bool Function(K k) test) {
    for (var childKey in _children.keys) {
      if (childKey == null) continue;
      if (test(childKey)) {
        return true;
      }
    }
    return false;
  }

  TrieNode<K, V>? getWhere(bool Function(K k) test) {
    for (var childKey in _children.keys) {
      if (test(childKey)) {
        return _children[childKey];
      }
    }
    return null;
  }
}

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
  final TrieNode<K?, V?> root;

  Trie() : root = TrieNode<K?, V?>(null, null, '/');
}
