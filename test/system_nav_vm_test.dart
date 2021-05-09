@TestOn('dart-vm')
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/system_nav.dart';

void main() {
  test('SystemNav.pathStrategy throws when not on web', () {
    expect(() => SystemNav.pathStrategy, throwsA(isA<UnsupportedError>()));
  });

  test('SystemNav.replaceUrl() throws when not on web', () {
    expect(
      () => SystemNav.replaceUrl('', {}),
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
