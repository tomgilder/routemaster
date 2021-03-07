import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/trie_router/trie_router.dart';

void main() {
  test("Route info with different paths are not equal", () {
    final plan = MaterialPagePlan('/', (_) => Container());
    final one = RouteInfo(RouterResult(plan, {}, '/one'), {});
    final two = RouteInfo(RouterResult(plan, {}, '/two'), {});

    expect(one == two, isFalse);
  });

  test("Route info with same paths are equal", () {
    final plan = MaterialPagePlan('/', (_) => Container());
    final one = RouteInfo(RouterResult(plan, {}, '/'), {});
    final two = RouteInfo(RouterResult(plan, {}, '/'), {});

    expect(one == two, isTrue);
  });

  test("Route info with same different query strings are not equal", () {
    final plan = MaterialPagePlan('/', (_) => Container());
    final one = RouteInfo(RouterResult(plan, {}, '/'), {'a': 'b'});
    final two = RouteInfo(RouterResult(plan, {}, '/'), {});

    expect(one == two, isFalse);
  });

  test("Route info with same query strings are equal", () {
    final plan = MaterialPagePlan('/', (_) => Container());
    final one = RouteInfo(RouterResult(plan, {}, '/'), {'a': 'b'});
    final two = RouteInfo(RouterResult(plan, {}, '/'), {'a': 'b'});

    expect(one == two, isTrue);
  });
  test("Route info with same different path params are not equal", () {
    final plan = MaterialPagePlan('/', (_) => Container());
    final one = RouteInfo(RouterResult(plan, {'a': 'b'}, '/'), {});
    final two = RouteInfo(RouterResult(plan, {}, '/'), {});

    expect(one == two, isFalse);
  });

  test("Route info with same path params are equal", () {
    final plan = MaterialPagePlan('/', (_) => Container());
    final one = RouteInfo(RouterResult(plan, {'a': 'b'}, '/'), {});
    final two = RouteInfo(RouterResult(plan, {'a': 'b'}, '/'), {});

    expect(one == two, isTrue);
  });
}
