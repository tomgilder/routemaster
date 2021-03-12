import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/trie_router/trie_router.dart';

void main() {
  test("Route info with different paths are not equal", () {
    final builder = (RouteInfo info) => MaterialPage<void>(child: Container());
    final one = RouteInfo(RouterResult(builder, {}, '/one'), {});
    final two = RouteInfo(RouterResult(builder, {}, '/two'), {});

    expect(one == two, isFalse);
  });

  test("Route info with same paths are equal", () {
    final builder = (RouteInfo info) => MaterialPage<void>(child: Container());
    final one = RouteInfo(RouterResult(builder, {}, '/'), {});
    final two = RouteInfo(RouterResult(builder, {}, '/'), {});

    expect(one == two, isTrue);
  });

  test("Route info with same different query strings are not equal", () {
    final builder = (RouteInfo info) => MaterialPage<void>(child: Container());
    final one = RouteInfo(RouterResult(builder, {}, '/'), {'a': 'b'});
    final two = RouteInfo(RouterResult(builder, {}, '/'), {});

    expect(one == two, isFalse);
  });

  test("Route info with same query strings are equal", () {
    final builder = (RouteInfo info) => MaterialPage<void>(child: Container());
    final one = RouteInfo(RouterResult(builder, {}, '/'), {'a': 'b'});
    final two = RouteInfo(RouterResult(builder, {}, '/'), {'a': 'b'});

    expect(one == two, isTrue);
  });
  test("Route info with same different path params are not equal", () {
    final builder = (RouteInfo info) => MaterialPage<void>(child: Container());
    final one = RouteInfo(RouterResult(builder, {'a': 'b'}, '/'), {});
    final two = RouteInfo(RouterResult(builder, {}, '/'), {});

    expect(one == two, isFalse);
  });

  test("Route info with same path params are equal", () {
    final builder = (RouteInfo info) => MaterialPage<void>(child: Container());
    final one = RouteInfo(RouterResult(builder, {'a': 'b'}, '/'), {});
    final two = RouteInfo(RouterResult(builder, {'a': 'b'}, '/'), {});

    expect(one == two, isTrue);
  });
}
