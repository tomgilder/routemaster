@TestOn('browser')

import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/src/system_nav.dart';

void main() {
  test('makeUrl makes hash URL with null query params', () {
    expect(
      SystemNav.makeUrl(
        path: '/new-path',
        queryParameters: null,
      ),
      '#/new-path',
    );
  });

  test('makeUrl makes hash URL with empty query params', () {
    expect(
      SystemNav.makeUrl(
        path: '/new-path',
        queryParameters: {},
      ),
      '#/new-path',
    );
  });

  test('makeUrl makes hash URL with query params', () {
    expect(
      SystemNav.makeUrl(
        path: '/new-path',
        queryParameters: {'query': 'param'},
      ),
      '#/new-path?query=param',
    );
  });

  test('makeUrl makes hash URL with just query params', () {
    expect(
      SystemNav.makeUrl(
        path: '/new-path',
        queryParameters: {'query': 'param'},
      ),
      '#/new-path?query=param',
    );
  });

  test('makeUrl makes hash URL with query params', () {
    expect(
      SystemNav.makeUrl(
        path: '/new-path',
        queryParameters: {'query': 'param'},
      ),
      '#/new-path?query=param',
    );
  });
}
