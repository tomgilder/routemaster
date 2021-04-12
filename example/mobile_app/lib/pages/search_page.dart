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
            ElevatedButton(
              onPressed: () => Routemaster.of(context).push('hero'),
              child: Text('Test hero animations work'),
            ),
            SizedBox(height: 20),
            Hero(
              tag: 'my-hero',
              child: Container(
                color: Colors.red,
                width: 50,
                height: 50,
              ),
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
      body: ListView(
        children: [
          SizedBox(height: 300),
          Center(
            child: Hero(
              tag: 'my-hero',
              child: Container(
                color: Colors.red,
                width: 100,
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
