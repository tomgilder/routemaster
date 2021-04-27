import 'package:flutter/foundation.dart';

enum LoggedInState {
  loading,
  loggedOut,
  loggedIn,
}

class AppState extends ChangeNotifier {
  LoggedInState _loggedInState = LoggedInState.loading;

  LoggedInState get loggedInState => _loggedInState;

  Future<void> logIn({bool success = true}) async {
    _loggedInState = LoggedInState.loading;
    notifyListeners();

    await Future<void>.delayed(Duration(seconds: 2));
    _loggedInState = LoggedInState.loggedIn;
    notifyListeners();
  }

  void logOut() {
    _loggedInState = LoggedInState.loggedOut;
    notifyListeners();
  }
}

class Article {
  final String body;

  Article({required this.body});
}

class Api {
  final void Function() onAuthFailure;

  Api({required this.onAuthFailure});

  Future<ApiResponse<Article>> getArticle({String? articleId}) async {
    await Future<void>.delayed(Duration(seconds: 1));

    if (articleId == '401') {
      onAuthFailure();
      return ApiAuthFailure();
    }

    return ApiSuccess(Article(body: 'Article $articleId'));
  }
}

abstract class ApiResponse<T> {}

class ApiSuccess<T> extends ApiResponse<T> {
  final T value;

  ApiSuccess(this.value);
}

class ApiAuthFailure<T> extends ApiResponse<T> {}
