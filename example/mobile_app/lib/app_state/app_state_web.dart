import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  bool get isLoggedIn =>
      web.window.sessionStorage.getItem('isLoggedIn') == 'true';
  set isLoggedIn(bool value) {
    web.window.sessionStorage.setItem('isLoggedIn', value.toString());
    notifyListeners();
  }

  bool _showBonusTab = false;
  bool get showBonusTab => _showBonusTab;
  set showBonusTab(bool value) {
    _showBonusTab = value;
    notifyListeners();
  }
}
