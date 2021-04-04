import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/src/route_dart.dart';

void main() {
  test('RouteData.hashCode uses path', () {
    expect(RouteData('/').hashCode == RouteData('/').hashCode, isTrue);
  });

  test('RouteData.toString() uses path', () {
    expect(RouteData('/').toString(), '/');
  });
}
