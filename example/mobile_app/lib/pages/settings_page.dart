import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/app_state/app_state.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoSwitch(
                  value: appState.showBonusTab,
                  onChanged: (value) {
                    appState.showBonusTab = value;
                  },
                ),
                SizedBox(width: 10),
                Text('Show bonus tab'),
              ],
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Provider.of<AppState>(context, listen: false)
                  .isLoggedIn = false,
              child: Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
