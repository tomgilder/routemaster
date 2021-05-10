import 'package:routemaster/routemaster.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (BuildContext context) {
          return RouteMap(
            routes: {
              '/': (_) => MaterialPage<void>(child: HomePage()),
              '/one': (_) => MaterialPage<void>(child: PageOne()),
              '/two': (_) => MaterialPage<void>(child: PageTwo()),
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () => Routemaster.of(context).replace('/one'),
            child: Text('Replace page one'),
          ),
          ElevatedButton(
            onPressed: () => Routemaster.of(context).push('/one'),
            child: Text('Push page one'),
          ),
        ],
      ),
    );
  }
}

class PageOne extends StatelessWidget {
  const PageOne({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () => Routemaster.of(context).replace('/two'),
            child: Text('Replace page two'),
          ),
          ElevatedButton(
            onPressed: () => Routemaster.of(context).push('/two'),
            child: Text('Push page two'),
          ),
        ],
      ),
    );
  }
}

class PageTwo extends StatelessWidget {
  const PageTwo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [Text('Page two')],
      ),
    );
  }
}
