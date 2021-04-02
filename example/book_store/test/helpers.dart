import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

Future<List<String>> recordUrlChanges(Future Function() callback) async {
  final result = <String>[];
  SystemChannels.navigation.setMockMethodCallHandler((call) async {
    if (call.method == 'routeInformationUpdated') {
      result.add(call.arguments['location'] as String);
    }
  });

  await callback();
  SystemChannels.navigation.setMockMethodCallHandler(null);
  return result;
}

/// Simulates pressing the system back button
Future<void> invokeSystemBack() {
  // ignore: invalid_use_of_protected_member
  return WidgetsBinding.instance.handlePopRoute();
}

Future<void> setSystemUrl(String url) {
  // ignore: invalid_use_of_protected_member
  return WidgetsBinding.instance.handlePushRoute(url);
}

/// Allows us to emulate the behavior of a web browser by storing a simple
/// stack of routes and popping them, reproducing the same behavior as a user
/// clicking a browser back button.
class BrowserEmulatorRouteInfoProvider
    extends PlatformRouteInformationProvider {
  BrowserEmulatorRouteInfoProvider({
    RouteInformation initialRouteInformation,
  }) : super(
          initialRouteInformation: initialRouteInformation ??
              RouteInformation(
                location: '/',
              ),
        );

  final _urlStack = Queue<RouteInformation>();

  @override
  void routerReportsNewRouteInformation(RouteInformation routeInformation) {
    _urlStack.addLast(routeInformation);
    super.routerReportsNewRouteInformation(routeInformation);
  }

  @override
  Future<bool> didPushRoute(String route) async {
    final result = await super.didPushRoute(route);
    if (result) {
      _urlStack.addLast(RouteInformation(location: route));
    }
    return result;
  }

  /// Pops the current URL, as if the user clicked the browser's back button.
  void pop() {
    _urlStack.removeLast();
    this.didPushRouteInformation(_urlStack.last);
  }
}
