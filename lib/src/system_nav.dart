export 'system_nav_main.dart' if (dart.library.js) 'system_nav_web.dart';
// ignore_for_file: public_member_api_docs

/// Allows tests to mock browser history
abstract class HistoryProvider {
  String get hash;

  void back();
  void forward();
}
