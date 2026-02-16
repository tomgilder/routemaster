import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/src/path_parser.dart';

void main() {
  test('Returns absolute path for absolute paths', () {
    expect(
      PathParser.getAbsolutePath(
        basePath: '/old',
        path: '/new',
      ).toString(),
      '/new',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/old?query=string',
        path: '/new',
      ).toString(),
      '/new',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/old/blah',
        path: '/new/blah',
      ).toString(),
      '/new/blah',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/old',
        path: '/new',
        queryParameters: {'query': 'param'},
      ).toString(),
      '/new?query=param',
    );
  });

  test('Returns absolute path for relative paths', () {
    expect(
      PathParser.getAbsolutePath(
        basePath: '/one',
        path: 'two',
      ).toString(),
      '/one/two',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/one?query=string',
        path: 'two',
      ).toString(),
      '/one/two',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/one/two',
        path: 'three/four',
      ).toString(),
      '/one/two/three/four',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/one/two',
        path: 'three/four',
        queryParameters: {'query': 'param'},
      ).toString(),
      '/one/two/three/four?query=param',
    );
  });
}
