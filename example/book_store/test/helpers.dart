import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records changes in URL
class SystemUrlTracker {
  String? current;
}

/// Records changes in URL
Future<void> recordUrlChanges(
    Future<dynamic> Function(SystemUrlTracker url) callback) async {
  try {
    final tracker = SystemUrlTracker();
    final stackTraces = <StackTrace>[];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.navigation,
      (call) async {
        if (call.method == 'routeInformationUpdated') {
          final args = call.arguments as Map;
          final location = args.containsKey('uri')
              ? args['uri'] as String
              : args['location'] as String;

          tracker.current = location;
          stackTraces.add(StackTrace.current);
        }
        return null;
      },
    );

    await callback(tracker);
  } finally {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.navigation, null);
  }
}

/// Simulates pressing the system back button
Future<void> invokeSystemBack() {
  // ignore: invalid_use_of_protected_member
  return _ambiguate(WidgetsBinding.instance)!.handlePopRoute();
}

Future<void> setSystemUrl(String url) {
  // ignore: invalid_use_of_protected_member
  return _ambiguate(WidgetsBinding.instance)!.handlePushRoute(url);
}

T? _ambiguate<T>(T? value) => value;

/// Allows us to emulate the behavior of a web browser by storing a simple
/// stack of routes and popping them, reproducing the same behavior as a user
/// clicking a browser back button.
class BrowserEmulatorRouteInfoProvider
    extends PlatformRouteInformationProvider {
  BrowserEmulatorRouteInfoProvider({
    RouteInformation? initialRouteInformation,
  }) : super(
          initialRouteInformation: initialRouteInformation ??
              RouteInformation(
                location: '/',
              ),
        );

  final _urlStack = Queue<RouteInformation>();

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    _urlStack.addLast(routeInformation);
    super.routerReportsNewRouteInformation(routeInformation, type: type);
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
    didPushRouteInformation(_urlStack.last);
  }
}
