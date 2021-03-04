import 'package:flutter/material.dart';
import 'package:mobile_app/routes.dart';
import 'package:routemaster/routemaster.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Builder(
        builder: (context) {
          final isLoggedIn = Provider.of<AppState>(context).isLoggedIn;

          return MaterialApp.router(
            title: 'Routemaster Demo',
            routeInformationParser: RoutemasterParser(),
            routerDelegate: Routemaster(
              plans: isLoggedIn ? routeMap : loggedOutRouteMap,
            ),
          );
        },
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }
}
