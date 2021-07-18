import 'package:routemaster/routemaster.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'fake_html.dart' if (dart.library.js) 'dart:html';
import 'package:flutter/foundation.dart';
import 'system_nav.dart';

class SystemNav {
  static HashUrlStrategy? _urlStrategy;

  static void setPathUrlStrategy() {
    _urlStrategy = PathUrlStrategy();
    setUrlStrategy(_urlStrategy);
  }

  @visibleForTesting
  static void setHashUrlStrategy() {
    _urlStrategy = const HashUrlStrategy();
    setUrlStrategy(_urlStrategy);
  }

  /// Attempts to guess the current URL strategy based on whether a hash is set
  /// or not. This is to deal with users directly setting the URL strategy.
  static void _setDefaultUrlStrategy() {
    historyProvider ??= BrowserHistoryProvider();
    _urlStrategy = historyProvider!.hash.isNotEmpty
        ? const HashUrlStrategy()
        : PathUrlStrategy();
  }

  /// Allows tests to mock browser history
  @visibleForTesting
  static HistoryProvider? historyProvider;

  static void replaceUrl(RouteData routeData) {
    historyProvider ??= BrowserHistoryProvider();
    historyProvider!.replaceState(
      routeData.toRouteInformation().state,
      '',
      makePublicUrl(routeData),
    );
  }

  static String makePublicUrl(RouteData routeData) {
    final isPrivatePath = routeData.publicPath != routeData.fullPath;

    final queryParameters = routeData.queryParameters;
    final hasQueryParameters = !isPrivatePath && queryParameters.isNotEmpty;
    final url = Uri(
      path: routeData.publicPath,
      queryParameters: hasQueryParameters ? queryParameters : null,
    );

    if (_urlStrategy == null) {
      _setDefaultUrlStrategy();
    }

    return _urlStrategy!.prepareExternalUrl(url.toString());
  }
}

class BrowserHistoryProvider implements HistoryProvider {
  @override
  void replaceState(dynamic data, String title, String? url) {
    window.history.replaceState(data, title, url);
  }

  @override
  String get hash => window.location.hash;
}
