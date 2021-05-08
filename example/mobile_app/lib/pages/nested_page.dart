import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class SplitScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Row(children: [
        Flexible(
          flex: 3,
          child: ClipRect(
            child: StackNavigator(
              stack: NestedPage.of(context).stacks[0],
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: ClipRect(
            child: StackNavigator(
              stack: NestedPage.of(context).stacks[1],
            ),
          ),
        ),
      ]),
    );
  }
}

class NestedContentPageOne extends StatelessWidget {
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

class NestedContentPageTwo extends StatelessWidget {
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

class NestedSidebarPageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.blueGrey,
        child: Center(
          child: ElevatedButton(
            onPressed: () => Routemaster.of(context).push('two'),
            child: Text('Go to page 2'),
          ),
        ),
      ),
    );
  }
}

class NestedSidebarPageTwo extends StatelessWidget {
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
