import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

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
                Provider.of<AppState>(context, listen: false).logIn();
              },
              child: Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }
}
