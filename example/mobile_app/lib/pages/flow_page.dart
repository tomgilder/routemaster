import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class FlowBottomSheetContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageStackNavigator(stack: FlowPage.of(context).stack);
  }
}

class FlowPageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Routemaster.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ),
      child: Material(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Page One',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            CupertinoButton(
              onPressed: () => FlowPage.of(context).pushNext(),
              child: Text('Next page'),
            ),
            CupertinoButton(
              onPressed: () => Routemaster.of(context).push('/flow/subpage'),
              child: Text('Subpage'),
            ),
          ],
        ),
      ),
    );
  }
}

class FlowPageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: Material(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Page Two',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            CupertinoButton(
              onPressed: () => Routemaster.of(context).push('/feed'),
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
