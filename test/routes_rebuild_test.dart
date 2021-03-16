import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets("Doesn't rebuild routes by default", (tester) async {
    var routeBuildCount = 0;

    final delegate = Routemaster(routesBuilder: (context) {
      routeBuildCount++;
      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (_) => MaterialPage<void>(child: PageTwo()),
      });
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    expect(routeBuildCount, 1);

    delegate.pushNamed('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(routeBuildCount, 1);
  });

  testWidgets('Rebuilds route map when dependencies change', (tester) async {
    var routeBuildCount = 0;

    final delegate = Routemaster(routesBuilder: (context) {
      routeBuildCount++;
      final state = StateProvider.of(context).state;

      return RouteMap(routes: {
        '/': (_) => MaterialPage<void>(child: PageOne()),
        '/two': (_) => MaterialPage<void>(child: Text(state.someValue)),
      });
    });
    final state = AppState();

    await tester.pumpWidget(
      StateProvider(
        state: state,
        child: MaterialApp.router(
          routeInformationParser: RoutemasterParser(),
          routerDelegate: delegate,
        ),
      ),
    );

    expect(routeBuildCount, 1);
    state.someValue = 'state change';

    delegate.pushNamed('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(routeBuildCount, 2);
  });
}

class AppState extends ChangeNotifier {
  String _someValue = 'initial';
  String get someValue => _someValue;
  set someValue(String newValue) {
    _someValue = newValue;
    notifyListeners();
  }
}

class StateProvider extends InheritedNotifier {
  final AppState state;

  StateProvider({
    required Widget child,
    required this.state,
  }) : super(
          child: child,
          notifier: state,
        );

  static StateProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StateProvider>()!;
  }
}
