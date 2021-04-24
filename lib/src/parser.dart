import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'route_data.dart';

class RoutemasterParser extends RouteInformationParser<RouteData> {
  const RoutemasterParser();

  @override
  Future<RouteData> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(
      RouteData(routeInformation.location!),
    );
  }

  /// Route object -> RouteInformation (URL)
  @override
  RouteInformation restoreRouteInformation(RouteData routeData) {
    return routeData.toRouteInformation();
  }
}
