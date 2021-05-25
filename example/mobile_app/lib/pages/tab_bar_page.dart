import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_app/app_state/app_state.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';

class TabBarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final tabPage = TabPage.of(context);

    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: tabPage.controller,
          tabs: [
            Tab(
              icon: Icon(Icons.directions_car),
              text: 'Home',
            ),
            if (appState.showBonusTab)
              Tab(
                icon: Icon(Icons.directions_transit),
                text: 'Bonus',
              ),
            Tab(
              icon: Icon(Icons.directions_car),
              text: 'Settings',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabPage.controller,
        children: [
          for (final stack in tabPage.stacks) PageStackNavigator(stack: stack),
        ],
      ),
    );
  }
}
