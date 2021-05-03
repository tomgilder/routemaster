import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/src/path_parser.dart';

void main() {
  test('Returns absolute path for absolute paths', () {
    expect(
      PathParser.getAbsolutePath(
        basePath: '/old',
        path: '/new',
      ),
      '/new',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/old?query=string',
        path: '/new',
      ),
      '/new',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/old/blah',
        path: '/new/blah',
      ),
      '/new/blah',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/old',
        path: '/new',
        queryParameters: {'query': 'param'},
      ),
      '/new?query=param',
    );
  });

  test('Returns absolute path for relative paths', () {
    expect(
      PathParser.getAbsolutePath(
        basePath: '/one',
        path: 'two',
      ),
      '/one/two',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/one?query=string',
        path: 'two',
      ),
      '/one/two',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/one/two',
        path: 'three/four',
      ),
      '/one/two/three/four',
    );

    expect(
      PathParser.getAbsolutePath(
        basePath: '/one/two',
        path: 'three/four',
        queryParameters: {'query': 'param'},
      ),
      '/one/two/three/four?query=param',
    );
  });
}
