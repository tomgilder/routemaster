class QueryParser {
  static Map<String, String> parseQueryParameters(String path) {
    final queryStringStart = path.indexOf('?');
    if (queryStringStart == -1 || path.length < queryStringStart) {
      return const <String, String>{};
    }

    final queryString = path.substring(path.indexOf('?') + 1);

    return Uri.splitQueryString(queryString);
  }
}
