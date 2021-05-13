@TestOn('browser')
import 'dart:html';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/src/system_nav.dart';

void main() {
  document.head!.append(BaseElement()..href = '/test/');
  SystemNav.setPathUrlStrategy();

  test('makeUrl makes path URL with null query params', () {
    expect(
      SystemNav.makeUrl(
        path: '/new-path',
        queryParameters: null,
      ),
      '/test/new-path',
    );
  });

  test('makeUrl makes path URL with empty query params', () {
    expect(
      SystemNav.makeUrl(
        path: '/new-path',
        queryParameters: {},
      ),
      '/test/new-path',
    );
  });
}
