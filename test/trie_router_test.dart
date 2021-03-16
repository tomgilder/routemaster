import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/trie_router/trie_router.dart';

class TestRoute extends Page<void> {
  final String id;

  TestRoute(this.id);

  @override
  String toString() {
    return "Test route '$id'";
  }

  @override
  Route<void> createRoute(BuildContext context) {
    throw UnimplementedError();
  }
}

RouteInfo getRouteInfo(RouterResult routerResult) {
  return RouteInfo(routerResult, '/');
}

void main() {
  test('Can add and get single routes', () {
    final router = TrieRouter();
    final rootRoute = TestRoute('root');
    final route1 = TestRoute('one');
    final route2 = TestRoute('two');

    router.add('/', (_) => rootRoute);
    router.add('/one', (_) => route1);
    router.add('/one/two', (_) => route2);

    final dataRoot = router.get('/')!;
    expect(dataRoot.pathSegment, '/');
    expect(dataRoot.builder(getRouteInfo(dataRoot)), rootRoute);
    expect(dataRoot.pathParameters.isEmpty, isTrue);

    final data1 = router.get('/one')!;
    expect(data1.pathSegment, '/one');
    expect(data1.builder(getRouteInfo(data1)), route1);
    expect(data1.pathParameters.isEmpty, isTrue);

    final data2 = router.get('/one/two')!;
    expect(data2.pathSegment, '/one/two');
    expect(data2.builder(getRouteInfo(data2)), route2);
    expect(data2.pathParameters.isEmpty, isTrue);
  });

  test('Can add and get all routes', () {
    final router = TrieRouter();
    final rootRoute = TestRoute('root');
    final route1 = TestRoute('one');
    final route2 = TestRoute('two');

    router.add('/', (_) => rootRoute);
    router.add('/one', (_) => route1);
    router.add('/one/two', (_) => route2);

    final routes = router.getAll('/one/two')!;
    expect(routes[0].pathSegment, '/');
    expect(routes[0].builder(getRouteInfo(routes[0])), rootRoute);
    expect(routes[0].pathParameters.isEmpty, isTrue);

    expect(routes[1].pathSegment, '/one');
    expect(routes[1].builder(getRouteInfo(routes[1])), route1);
    expect(routes[1].pathParameters.isEmpty, isTrue);

    expect(routes[2].pathSegment, '/one/two');
    expect(routes[2].builder(getRouteInfo(routes[2])), route2);
    expect(routes[2].pathParameters.isEmpty, isTrue);
  });
}
