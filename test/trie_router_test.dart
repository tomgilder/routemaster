import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/trie_router/trie_router.dart';

class TestRoute extends RoutePlan {
  final String id;

  TestRoute(this.id);

  @override
  String toString() {
    return "Test route '$id'";
  }

  @override
  RouteState createState(Routemaster delegate, RouteInfo path) {
    throw UnimplementedError();
  }

  @override
  List<String> get pathTemplates => ['pathTemplate'];
}

void main() {
  test("Can add and get single routes", () {
    final router = TrieRouter();
    final rootRoute = TestRoute('root');
    final route1 = TestRoute('one');
    final route2 = TestRoute('two');

    router.add('/', rootRoute);
    router.add('/one', route1);
    router.add('/one/two', route2);

    final dataRoot = router.get('/')!;
    expect(dataRoot.pathSegment, '/');
    expect(dataRoot.value, rootRoute);
    expect(dataRoot.pathParameters.isEmpty, isTrue);

    final data1 = router.get('/one')!;
    expect(data1.pathSegment, '/one');
    expect(data1.value, route1);
    expect(data1.pathParameters.isEmpty, isTrue);

    final data2 = router.get('/one/two')!;
    expect(data2.pathSegment, '/one/two');
    expect(data2.value, route2);
    expect(data2.pathParameters.isEmpty, isTrue);
  });

  test("Can add and get all routes", () {
    final router = TrieRouter();
    final rootRoute = TestRoute('root');
    final route1 = TestRoute('one');
    final route2 = TestRoute('two');

    router.add('/', rootRoute);
    router.add('/one', route1);
    router.add('/one/two', route2);

    final routes = router.getAll('/one/two')!;
    expect(routes[0].pathSegment, '/');
    expect(routes[0].value, rootRoute);
    expect(routes[0].pathParameters.isEmpty, isTrue);

    expect(routes[1].pathSegment, '/one');
    expect(routes[1].value, route1);
    expect(routes[1].pathParameters.isEmpty, isTrue);

    expect(routes[2].pathSegment, '/one/two');
    expect(routes[2].value, route2);
    expect(routes[2].pathParameters.isEmpty, isTrue);
  });
}
