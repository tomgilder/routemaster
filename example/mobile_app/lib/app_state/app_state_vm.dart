import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  bool _showBonusTab = false;
  bool get showBonusTab => _showBonusTab;
  set showBonusTab(bool value) {
    _showBonusTab = value;
    notifyListeners();
  }
}
