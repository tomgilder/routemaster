import 'package:flutter/material.dart';
import 'package:mobile_app/app_state/app_state.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Provider.of<AppState>(context, listen: false).isLoggedIn = true;
              },
              child: Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }
}
