import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/trie_router/trie_router.dart';

class TestRoute {
  final String id;

  const TestRoute(this.id);

  @override
  String toString() {
    return "Test route '$id'";
  }
}

void main() {
  test("params", () {
    final path = '/hello?test=hello&blah=thinghello';
    final split = path.substring(path.indexOf('?'));
    final result = Uri.splitQueryString(split);

    print(result['test']);
  });

  test("Can add and get single routes", () {
    final router = TrieRouter<TestRoute>();
    final rootRoute = TestRoute('root');
    final route1 = TestRoute('one');
    final route2 = TestRoute('two');

    router.add('/', rootRoute);
    router.add('/one', route1);
    router.add('/one/two', route2);

    final dataRoot = router.get('/');
    expect(dataRoot.path, '/');
    expect(dataRoot.value, rootRoute);
    expect(dataRoot.parameters.isEmpty, isTrue);

    final data1 = router.get('/one');
    expect(data1.path, '/one');
    expect(data1.value, route1);
    expect(data1.parameters.isEmpty, isTrue);

    final data2 = router.get('/one/two');
    expect(data2.path, '/one/two');
    expect(data2.value, route2);
    expect(data2.parameters.isEmpty, isTrue);
  });

  test("Can add and get all routes", () {
    final router = TrieRouter<TestRoute>();
    final rootRoute = TestRoute('root');
    final route1 = TestRoute('one');
    final route2 = TestRoute('two');

    router.add('/', rootRoute);
    router.add('/one', route1);
    router.add('/one/two', route2);

    final routes = router.getAll('/one/two');
    expect(routes[0].path, '/');
    expect(routes[0].value, rootRoute);
    expect(routes[0].parameters.isEmpty, isTrue);

    expect(routes[1].path, '/one');
    expect(routes[1].value, route1);
    expect(routes[1].parameters.isEmpty, isTrue);

    expect(routes[2].path, '/one/two');
    expect(routes[2].value, route2);
    expect(routes[2].parameters.isEmpty, isTrue);
  });
}
