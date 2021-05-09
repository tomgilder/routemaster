import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:routemaster/routemaster.dart';

class BottomNavigationBarReplacementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Navigation Bar')),
      body: Center(
        child: ElevatedButton(
          onPressed: () =>
              Routemaster.of(context).replace('/bottom-navigation-bar'),
          child: Text('Replace: Bottom Navigation Bar page'),
        ),
      ),
    );
  }
}

class BottomNavigationBarPage extends StatefulWidget {
  @override
  _BottomNavigationBarPageState createState() =>
      _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  @override
  Widget build(BuildContext context) {
    final pageState = IndexedPage.of(context);
    final selectedIndex = pageState.index;
    final stack = pageState.stacks[selectedIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Navigation Bar')),
      body: PageStackNavigator(
        key: ValueKey(selectedIndex),
        stack: stack,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            pageState.index = index;
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
            Text('Bottom bar page 1'),
            ElevatedButton(
              onPressed: () {
                Routemaster.of(context)
                    .push('/bottom-navigation-bar/threepage');
              },
              child: Text('Push page Android-style'),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomContentPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bottom bar page 2'),
            ElevatedButton(
              onPressed: () => Routemaster.of(context)
                  .push('/bottom-navigation-bar/threepage'),
              child: Text('Page 2: push page'),
            ),
          ],
        ),
      ),
    );
  }
}
