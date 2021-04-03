import 'package:book_store/models.dart';
import 'package:book_store/page_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';

class LoginPage extends StatefulWidget {
  static const usernameFieldKey = Key('username-field');
  static const loginButtonKey = Key('login-button');

  final String? redirectTo;

  const LoginPage({
    this.redirectTo = '/',
  });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _login() {
    if (_usernameController.text.isNotEmpty) {
      Provider.of<AppState>(context, listen: false).username =
          _usernameController.text;
      Routemaster.of(context).push(widget.redirectTo!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Log in',
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Type any username to login'),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Username:'),
                  ),
                  Expanded(
                    child: CupertinoTextField(
                      controller: _usernameController,
                      key: LoginPage.usernameFieldKey,
                      onSubmitted: (_) => _login(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              AnimatedBuilder(
                animation: _usernameController,
                builder: (_, __) => ElevatedButton(
                  key: LoginPage.loginButtonKey,
                  onPressed:
                      _usernameController.text.isNotEmpty ? _login : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Text('Log in'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
