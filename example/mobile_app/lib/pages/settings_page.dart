import 'package:flutter/material.dart';
import 'package:mobile_app/main.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
