import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/src/query_parser.dart';

void main() {
  test('Parses query string', () {
    final result = QueryParser.parseQueryParameters('/test?one=A&two=B');
    expect(result.length, 2);
    expect(result['one'], 'A');
    expect(result['two'], 'B');
  });

  test('Parses query string without parameter', () {
    final result = QueryParser.parseQueryParameters('/test?a');
    expect(result['a'], '');
  });

  test('Returns empty map with no query string', () {
    expect(QueryParser.parseQueryParameters('').isEmpty, isTrue);
    expect(QueryParser.parseQueryParameters('/').isEmpty, isTrue);
    expect(QueryParser.parseQueryParameters('/?').isEmpty, isTrue);
    expect(QueryParser.parseQueryParameters('/test').isEmpty, isTrue);
    expect(QueryParser.parseQueryParameters('/test?').isEmpty, isTrue);
  });

  test('Returns unmodifiable map', () {
    final result = QueryParser.parseQueryParameters('/test?one=A&two=B');
    expect(() => result['thing'] = 'blah', throwsA(isA<UnsupportedError>()));
  });

  test('Returns unmodifiable map for empty string', () {
    final result = QueryParser.parseQueryParameters('');
    expect(() => result['thing'] = 'blah', throwsA(isA<UnsupportedError>()));
  });
}
