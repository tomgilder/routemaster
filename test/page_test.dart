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
        return SizedBox();
      },
    ));
  });

  test('StatelessPage getCurrentPageStates returns itself', () {
    final page = StatelessPage(
      routeData: RouteData(''),
      page: MaterialPageOne(),
    );

    expect(page.getCurrentPages().single, page);
  });

  test('StatelessPage createPage returns page', () {
    final page = MaterialPageOne();
    final statelessPage = StatelessPage(
      routeData: RouteData(''),
      page: page,
    );

    expect(statelessPage.createPage(), page);
  });

  testWidgets('StatefulPage that returns incorrect state type throws',
      (tester) async {
    final app = MaterialApp.router(
      routeInformationParser: RoutemasterParser(),
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
