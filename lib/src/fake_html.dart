// Work-around for dart analyser issue: https://github.com/dart-lang/linter/issues/2651
// ignore_for_file: public_member_api_docs

final window = Window();

class Window {
  final history = History();
}

class History {
  void back() {}

  void forward() {}

  void go(int delta) {}
}
