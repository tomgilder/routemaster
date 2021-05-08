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

    expect(page.getCurrentPages().single, [page]);
  });

  test('StatelessPage createPage returns page', () {
    final page = MaterialPageOne();
    final statelessPage = StatelessPage(
      routeData: RouteData(''),
      page: page,
    );

    expect(statelessPage.createPage(), page);
  });
}

class MockStatefulPage extends StatefulPage<void> {
  @override
  PageState createState(Routemaster routemaster, RouteData info) {
    throw UnimplementedError();
  }
}
