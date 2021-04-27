import 'dart:async';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

class LinkHandler {
  final void Function(String link) onLink;
  StreamSubscription<String?>? _subscription;

  LinkHandler({required this.onLink});

  Future<Null> init() async {
    if (_subscription != null) {
      return;
    }

    _subscription = linkStream.listen(_onLink);

    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _onLink(initialLink);
      }
    } on PlatformException {}
  }

  void _onLink(String? link) {
    print(link);
    onLink(link!.replaceFirst('routemaster:/', ''));
  }

  void dispose() {
    _subscription!.cancel();
  }
}
