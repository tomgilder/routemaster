import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/src/system_nav_main.dart';

void main() {
  test('SystemNav.back() throws when not on web', () {
    expect(() => SystemNav.back(), throwsA(isA<UnsupportedError>()));
  });

  test('SystemNav.replaceLocation() throws when not on web', () {
    expect(
      () => SystemNav.replaceLocation('', {}),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
