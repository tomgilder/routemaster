import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'route_data.dart';

/// A delegate that is used by the [Router] widget to parse URLs.
///
/// This must be supplied to top-level app object for Routemaster to work.
class RoutemasterParser extends RouteInformationParser<RouteData> {
  /// Initializes a parser that works in conjunction with [RoutemasterDelegate].
  const RoutemasterParser();

  @override
  Future<RouteData> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(
      RouteData(routeInformation.location!),
    );
  }

  @override
  RouteInformation restoreRouteInformation(RouteData routeData) {
    return routeData.toRouteInformation();
  }
}
