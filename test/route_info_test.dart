import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/trie_router/trie_router.dart';

MaterialPage<void> builder(RouteInfo info) {
  return MaterialPage<void>(child: Container());
}

void main() {
  test('Provides correct path without query string', () {
    final routeInfo =
        RouteInfo.fromRouterResult(RouterResult(builder, {}, '/path'), '/path');
    expect(routeInfo.path, '/path');
  });

  test('Provides correct path with query string', () {
    final routeInfo = RouteInfo.fromRouterResult(
        RouterResult(builder, {}, '/path'), '/path?hello=world');
    expect(routeInfo.path, '/path?hello=world');
  });

  test('Route info with different paths are not equal', () {
    final one = RouteInfo.fromRouterResult(
        RouterResult(builder, {}, '/one'), '/one/two');
    final two =
        RouteInfo.fromRouterResult(RouterResult(builder, {}, '/two'), '/one');

    expect(one == two, isFalse);
  });

  test('Route info with same paths are equal', () {
    final one = RouteInfo.fromRouterResult(RouterResult(builder, {}, '/'), '/');
    final two = RouteInfo.fromRouterResult(RouterResult(builder, {}, '/'), '/');

    expect(one == two, isTrue);
  });

  test('Route info with different query strings are not equal', () {
    final one =
        RouteInfo.fromRouterResult(RouterResult(builder, {}, '/'), '/?a=b');
    final two = RouteInfo.fromRouterResult(RouterResult(builder, {}, '/'), '/');

    expect(one == two, isFalse);
  });

  test('Route info with same query strings are equal', () {
    final one =
        RouteInfo.fromRouterResult(RouterResult(builder, {}, '/'), '/?a=b');
    final two =
        RouteInfo.fromRouterResult(RouterResult(builder, {}, '/'), '/?a=b');

    expect(one == two, isTrue);
  });

  test('Route info with same path params are equal', () {
    final one =
        RouteInfo.fromRouterResult(RouterResult(builder, {'a': 'b'}, '/'), '/');
    final two =
        RouteInfo.fromRouterResult(RouterResult(builder, {'a': 'b'}, '/'), '/');

    expect(one == two, isTrue);
  });

  test('RouteInfo.toString() is correct', () {
    expect(
      RouteInfo('/').toString(),
      "RouteInfo: '/'",
    );
  });
}
