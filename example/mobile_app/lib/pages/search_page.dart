import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(tag: 'my-hero', child: Text('Hero text')),
            ElevatedButton(
              onPressed: () => Routemaster.of(context).pushNamed('hero'),
              child: Text(
                  "Test hero animations work\n\n(spoiler alert: they don't)"),
            ),
          ],
        ),
      ),
    );
  }
}

class HeroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 300),
            Hero(tag: 'my-hero', child: Text('Hero text')),
          ],
        ),
      ),
    );
  }
}
