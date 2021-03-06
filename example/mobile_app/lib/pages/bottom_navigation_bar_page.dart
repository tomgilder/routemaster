import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:routemaster/routemaster.dart';

class BottomNavigationBarPage extends StatefulWidget {
  final IndexedRouteState routeState;

  BottomNavigationBarPage({@required this.routeState});

  @override
  _BottomNavigationBarPageState createState() =>
      _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.routeState.index;
    final stack = widget.routeState.getStackForIndex(selectedIndex);
    final pages = stack.createPages();

    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Navigation Bar')),
      body: Navigator(
        key: ValueKey(selectedIndex),
        onPopPage: stack.onPopPage,
        pages: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            widget.routeState.index = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.ac_unit),
            label: 'One',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explicit),
            label: 'Two',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Three',
          ),
        ],
      ),
    );
  }
}

class BottomContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              // TODO: Is this confusing?
              // It feels like we should be able to use .pushNamed for
              // Android-style navigation where we don't push into the tab
              // navigator. Not sure there's a good solution to this.
              onPressed: () => Routemaster.of(context)
                  .replaceNamed('/bottom-navigation-bar/sub-page'),
              child: Text("Push page Android-style"),
            ),
          ],
        ),
      ),
    );
  }
}
