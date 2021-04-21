import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets("Doesn't rebuild routes by default", (tester) async {
    var routeBuildCount = 0;

    final delegate = RoutemasterDelegate(routesBuilder: (context) {
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

    delegate.push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(routeBuildCount, 1);
  });

  testWidgets('Rebuilds route map when dependencies change', (tester) async {
    var routeBuildCount = 0;

    final delegate = RoutemasterDelegate(routesBuilder: (context) {
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

    delegate.push('two');
    await tester.pump();
    await tester.pump(kTransitionDuration);

    expect(routeBuildCount, 2);
  });

  testWidgets('Can swap route maps and navigate', (tester) async {
    final routeMap1UnknownRoutes = <String>[];
    final routeMap1 = RouteMap(
      onUnknownRoute: (route, __) {
        routeMap1UnknownRoutes.add(route);
        return MaterialPage<void>(child: DefaultUnknownRoutePage(path: route));
      },
      routes: {
        '/': (_) => MaterialPageOne(),
        '/two': (_) => MaterialPageTwo(),
      },
    );

    final routeMap2UnknownRoutes = <String>[];
    final routeMap2 = RouteMap(
      onUnknownRoute: (route, __) {
        routeMap2UnknownRoutes.add(route);
        return MaterialPage<void>(child: DefaultUnknownRoutePage(path: route));
      },
      routes: {
        '/': (_) => MaterialPageOne(),
        '/three': (_) => MaterialPageThree(),
      },
    );

    final delegate = RoutemasterDelegate(routesBuilder: (context) {
      final state = StateProvider.of(context).state;
      return state.someValue == '1' ? routeMap1 : routeMap2;
    });
    final state = AppState()..someValue = '1';

    await tester.pumpWidget(
      StateProvider(
        state: state,
        child: MaterialApp.router(
          routeInformationParser: RoutemasterParser(),
          routeInformationProvider: PlatformRouteInformationProvider(
            initialRouteInformation: RouteInformation(location: '/two'),
          ),
          routerDelegate: delegate,
        ),
      ),
    );

    expect(find.byType(PageTwo), findsOneWidget);

    // Change state to swap to routeMap2
    state.someValue = '2';
    // Navigate to '/three' which is only in routeMap2
    delegate.push('/three');

    await tester.pump();
    await tester.pump(kTransitionDuration);
    expect(find.byType(PageThree), findsOneWidget);

    // Assert that onUnknownRoute has never been called
    expect(routeMap1UnknownRoutes.isEmpty, isTrue);
    expect(routeMap2UnknownRoutes.isEmpty, isTrue);
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
