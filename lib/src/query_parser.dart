class QueryParser {
  static Map<String, String> parseQueryParameters(String path) {
    final queryStringStart = path.indexOf('?');
    if (queryStringStart == -1 || path.length < queryStringStart) {
      return Map.unmodifiable(const <String, String>{});
    }

    final queryString = path.substring(path.indexOf('?') + 1);

    return Map.unmodifiable(Uri.splitQueryString(queryString));
  }

  static String stripQueryString(String path) {
    final indexOfQuery = path.indexOf('?');

    if (indexOfQuery == -1) {
      return path;
    }

    return path.substring(0, indexOfQuery);
  }
}
