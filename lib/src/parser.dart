import 'package:flutter/widgets.dart';
import 'route_dart.dart';

class RoutemasterParser extends RouteInformationParser<RouteData> {
  /// RouteInformation (URL) -> Route object
  ///
  /// Takes a URL and turns it into some kind of route
  /// In this case a [RouteData], but it can be anything
  ///
  /// This should probably be automatic, matching to a list of URLs
  @override
  Future<RouteData> parseRouteInformation(
      RouteInformation routeInformation) async {
    return RouteData(routeInformation.location!);
  }

  // / Route object -> RouteInformation (URL)
  @override
  RouteInformation restoreRouteInformation(RouteData routeData) {
    return RouteInformation(location: routeData.routeString);
  }
}
