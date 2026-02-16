import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class LinkHandler {
  final void Function(String link) onLink;
  StreamSubscription<Uri>? _subscription;
  final _appLinks = AppLinks();

  LinkHandler({required this.onLink});

  Future<void> init() async {
    if (_subscription != null) {
      return;
    }

    _subscription = _appLinks.uriLinkStream.listen(_onUri);

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _onUri(initialUri);
      }
    } on Exception {
      if (kDebugMode) {
        print('Failed to get initial link.');
      }
    }
  }

  void _onUri(Uri uri) {
    if (kDebugMode) {
      print(uri);
    }

    onLink(uri.path);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
