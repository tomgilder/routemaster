import 'dart:html';
import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  bool get isLoggedIn => window.sessionStorage['isLoggedIn'] == 'true';
  set isLoggedIn(bool value) {
    window.sessionStorage['isLoggedIn'] = value.toString();
    notifyListeners();
  }

  bool _showBonusTab = false;
  bool get showBonusTab => _showBonusTab;
  set showBonusTab(bool value) {
    _showBonusTab = value;
    notifyListeners();
  }
}
