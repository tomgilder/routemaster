import 'dart:html';

class SystemNav {
  static void back() {
    window.history.back();
  }

  static void replaceLocation(String location) {
    window.location.replace('#' + location);
  }
}
