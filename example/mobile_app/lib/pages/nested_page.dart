import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class NestedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(20),
        color: Colors.blue,
        // currentStack rename?
        child: ClipRect(
          child: StackNavigator(
            stack: IndexedPage.of(context).currentStack,
          ),
        ),
      ),
    );
  }
}

class NestedPageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Routemaster.of(context).push('two'),
          child: Text('Go to page 2'),
        ),
      ),
    );
  }
}
