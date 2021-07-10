import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:routemaster/routemaster.dart';
import 'helpers.dart';

void main() {
  testWidgets('Can use initial route with tabs and hot reload', (tester) async {
    await tester.pumpWidget(MyApp());
    unawaited(tester.binding.reassembleApplication());
    await tester.pump();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: const RoutemasterParser(),
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: const RouteInformation(location: '/home'),
      ),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (BuildContext context) {
          return RouteMap(
            routes: {
              '/home': (_) {
                return const TabPage(
                  child: PageOne(),
                  paths: ['one', 'two'],
                );
              },
            },
          );
        },
      ),
    );
  }
}
