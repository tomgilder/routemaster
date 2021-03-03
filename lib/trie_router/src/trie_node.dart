/// A node in the trie containing multiple child nodes.
///
/// [K] is the key and is unique relative to the parent, not the entire data
/// structure. [V] is an element stored in the Trie.
class TrieNode<K, V> {
  final Map<K, TrieNode<K, V>> _children;
  final K key;
  V value;

  TrieNode(this.key, this.value) : _children = {};

  bool contains(K key) {
    return _children.containsKey(key);
  }

  void add(K key, V value) {
    _children[key] = TrieNode<K, V>(key, value);
  }

  TrieNode<K, V> get(K key) {
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

  TrieNode<K, V> getWhere(bool Function(K k) test) {
    for (var childKey in _children.keys) {
      if (test(childKey)) {
        return _children[childKey];
      }
    }
    return null;
  }
}
