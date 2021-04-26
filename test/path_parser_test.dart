import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/src/path_parser.dart';

void main() {
  test('Parses query string', () {
    final result = PathParser.parseQueryParameters('/test?one=A&two=B');
    expect(result.length, 2);
    expect(result['one'], 'A');
    expect(result['two'], 'B');
  });

  test('Parses spaces in query', () {
    final result = PathParser.parseQueryParameters('/test?query=hello+world');
    expect(result['query'], 'hello world');
  });

  test('Parses query string without parameter', () {
    final result = PathParser.parseQueryParameters('/test?a');
    expect(result['a'], '');
  });

  test('Returns empty map with no query string', () {
    expect(PathParser.parseQueryParameters('').isEmpty, isTrue);
    expect(PathParser.parseQueryParameters('/').isEmpty, isTrue);
    expect(PathParser.parseQueryParameters('/?').isEmpty, isTrue);
    expect(PathParser.parseQueryParameters('/test').isEmpty, isTrue);
    expect(PathParser.parseQueryParameters('/test?').isEmpty, isTrue);
  });

  test('Returns unmodifiable map', () {
    final result = PathParser.parseQueryParameters('/test?one=A&two=B');
    expect(() => result['thing'] = 'blah', throwsA(isA<UnsupportedError>()));
  });

  test('Returns unmodifiable map for empty string', () {
    final result = PathParser.parseQueryParameters('');
    expect(() => result['thing'] = 'blah', throwsA(isA<UnsupportedError>()));
  });

  test('Returns unmodifiable map for empty string', () {
    final result = PathParser.parseQueryParameters('');
    expect(() => result['thing'] = 'blah', throwsA(isA<UnsupportedError>()));
  });

  test('Returns absolute path for absolute paths', () {
    expect(
      PathParser.getAbsolutePath(
        currentPath: '/old',
        newPath: '/new',
      ),
      '/new',
    );

    expect(
      PathParser.getAbsolutePath(
        currentPath: '/old?query=string',
        newPath: '/new',
      ),
      '/new',
    );

    expect(
      PathParser.getAbsolutePath(
        currentPath: '/old/blah',
        newPath: '/new/blah',
      ),
      '/new/blah',
    );

    expect(
      PathParser.getAbsolutePath(
        currentPath: '/old',
        newPath: '/new',
        queryParameters: {'query': 'param'},
      ),
      '/new?query=param',
    );
  });

  test('Returns absolute path for relative paths', () {
    expect(
      PathParser.getAbsolutePath(
        currentPath: '/one',
        newPath: 'two',
      ),
      '/one/two',
    );

    expect(
      PathParser.getAbsolutePath(
        currentPath: '/one?query=string',
        newPath: 'two',
      ),
      '/one/two',
    );

    expect(
      PathParser.getAbsolutePath(
        currentPath: '/one/two',
        newPath: 'three/four',
      ),
      '/one/two/three/four',
    );

    expect(
      PathParser.getAbsolutePath(
        currentPath: '/one/two',
        newPath: 'three/four',
        queryParameters: {'query': 'param'},
      ),
      '/one/two/three/four?query=param',
    );
  });
}
