import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('StatefulPage createRoute throws', (tester) async {
    await tester.pumpWidget(Builder(
      builder: (context) {
        expect(
          () => MockStatefulPage().createRoute(context),
          throwsA(isA<UnimplementedError>()),
        );
        return const SizedBox();
      },
    ));
  });

  test('PageWrapper getCurrentPageStates returns itself', () {
    final page = PageWrapper.fromPage(
      routeData: RouteData('', pathTemplate: ''),
      page: const MaterialPageOne(),
    );

    expect(page.getCurrentPages().single, page);
  });

  test('PageWrapper createPage returns page', () {
    const page = MaterialPageOne();
    final wrapper = PageWrapper.fromPage(
      routeData: RouteData('', pathTemplate: ''),
      page: page,
    );

    expect(wrapper.createPage(), page);
  });

  testWidgets('StatefulPage that returns incorrect state type throws',
      (tester) async {
    final app = MaterialApp.router(
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (_) => RouteMap(
          routes: {
            '/': (_) => StatefulPage1(),
          },
        ),
      ),
    );

    await tester.pumpWidget(app);
    final e = tester.takeException() as AssertionError;
    expect(e.message,
        'StatefulPage1.createState must return a subtype of PageState<StatefulPage1>, but it returned WrongPageState.');
  });
}

class StatefulPage1 extends StatefulPage<void> {
  @override
  PageState<StatefulPage> createState() {
    return WrongPageState();
  }
}

class StatefulPage2 extends StatefulPage<void> {
  @override
  PageState<StatefulPage> createState() {
    return WrongPageState();
  }
}

class WrongPageState extends PageState<StatefulPage2> {
  @override
  Page createPage() {
    throw UnimplementedError();
  }

  @override
  Iterable<PageWrapper<Page>> getCurrentPages() {
    throw UnimplementedError();
  }

  @override
  Future<bool> maybePop<T extends Object?>([T? result]) {
    throw UnimplementedError();
  }

  @override
  bool maybeSetChildPages(Iterable<PageWrapper<Page>> pages) {
    throw UnimplementedError();
  }
}

class MockStatefulPage extends StatefulPage<void> {
  @override
  PageState createState() {
    throw UnimplementedError();
  }
}
