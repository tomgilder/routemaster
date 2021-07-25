@TestOn('dart-vm')
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/system_nav.dart';

void main() {
  test('SystemNav.replaceUrl() throws when not on web', () {
    expect(
      () => SystemNav.replaceUrl(RouteData('path', pathTemplate: '/path')),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('SystemNav.setHashUrlStrategy() throws when not on web', () {
    expect(
      () => SystemNav.setHashUrlStrategy(),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('SystemNav.makePublicUrl() throws when not on web', () {
    expect(
      () => SystemNav.makePublicUrl(RouteData('/path', pathTemplate: '/path')),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('SystemNav.setPathUrlStrategy() throws when not on web', () {
    expect(
      () => SystemNav.setPathUrlStrategy(),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('Routemaster.setPathUrlStrategy() does nothing when not on web', () {
    Routemaster.setPathUrlStrategy();
  });
}
