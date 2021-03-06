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
