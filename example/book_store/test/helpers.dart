import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records changes in URL
class SystemUrlTracker {
  String? current;
}

/// Records changes in URL
Future<void> recordUrlChanges(
    Future Function(SystemUrlTracker url) callback) async {
  try {
    final tracker = SystemUrlTracker();
    final stackTraces = <StackTrace>[];

    SystemChannels.navigation.setMockMethodCallHandler((call) async {
      if (call.method == 'routeInformationUpdated') {
        final location = call.arguments['location'] as String;

        tracker.current = location;
        stackTraces.add(StackTrace.current);
      }
    });

    await callback(tracker);
  } finally {
    SystemChannels.navigation.setMockMethodCallHandler(null);
  }
}

/// Simulates pressing the system back button
Future<void> invokeSystemBack() {
  // ignore: invalid_use_of_protected_member
  return WidgetsBinding.instance!.handlePopRoute();
}

Future<void> setSystemUrl(String url) {
  // ignore: invalid_use_of_protected_member
  return WidgetsBinding.instance!.handlePushRoute(url);
}

/// Allows us to emulate the behavior of a web browser by storing a simple
/// stack of routes and popping them, reproducing the same behavior as a user
/// clicking a browser back button.
/// 
/// Skipped due to API changing in Flutter master
// class BrowserEmulatorRouteInfoProvider
//     extends PlatformRouteInformationProvider {
//   BrowserEmulatorRouteInfoProvider({
//     RouteInformation? initialRouteInformation,
//   }) : super(
//           initialRouteInformation: initialRouteInformation ??
//               RouteInformation(
//                 location: '/',
//               ),
//         );

//   final _urlStack = Queue<RouteInformation>();

//   @override
//   void routerReportsNewRouteInformation(RouteInformation routeInformation,
//       {dynamic isNavigation}) {
//     _urlStack.addLast(routeInformation);
//     super.routerReportsNewRouteInformation(routeInformation);
//   }

//   @override
//   Future<bool> didPushRoute(String route) async {
//     final result = await super.didPushRoute(route);
//     if (result) {
//       _urlStack.addLast(RouteInformation(location: route));
//     }

//     return result;
//   }

//   /// Pops the current URL, as if the user clicked the browser's back button.
//   void pop() {
//     _urlStack.removeLast();
//     this.didPushRouteInformation(_urlStack.last);
//   }
// }
