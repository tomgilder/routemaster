import 'package:flutter/material.dart';
import '../../routemaster.dart';
import '../route_info.dart';

typedef bool ValidateCallback(RouteInfo info);

typedef void ValidationFailedCallback(Routemaster delegate, RouteInfo info);

/// A mapping from path templates (e.g. URL segments), which can create a
/// [RouteState] object.
///
/// The [RouteState] is created when this plan matches a path, and the
/// state can then create either one page or multiple pages.
@immutable
abstract class RoutePlan {
  /// List of path templates that this plan could match.
  ///   e.g. `['/search/product/:id', '/categories/thing/:id']`
  List<String> get pathTemplates;

  RouteState createState(Routemaster delegate, RouteInfo path);

  /// Callback to check if the route is valid. If this returns false,
  /// [onValidationFailed] is called.
  ///
  /// By default this redirects to the default path.
  ValidateCallback? get validate;

  /// Callback, called when the [validate] returns false.
  ///
  /// By default this redirects to the default path.
  final ValidationFailedCallback? onValidationFailed = (delegate, routeInfo) {
    delegate.replaceNamed(delegate.defaultPath);
  };
}

abstract class RouteState {
  bool maybeSetRouteStates(Iterable<RouteState> routes);
  bool maybePush(RouteState route);
  bool maybePop();

  RouteInfo get routeInfo;
  Iterable<RouteState> getCurrentRouteStates();
}

abstract class MultiPageRouteState extends RouteState {
  List<Page> createPages();
}

abstract class SinglePageRouteState extends RouteState {
  Page createPage();
}

class MaterialPagePlan extends RoutePlan {
  final List<String> pathTemplates;
  final Widget Function(RouteInfo info) builder;
  final bool Function(RouteInfo info)? validate;
  final void Function(Routemaster routemaster, RouteInfo info)?
      onValidationFailed;

  MaterialPagePlan(
    String pathTemplate,
    this.builder, {
    this.validate,
    this.onValidationFailed,
  }) : pathTemplates = [pathTemplate];

  MaterialPagePlan.routes(
    this.pathTemplates,
    this.builder, {
    this.validate,
    this.onValidationFailed,
  });

  @override
  RouteState createState(Routemaster delegate, RouteInfo routeInfo) {
    return WidgetRouteState(this, routeInfo);
  }
}

class WidgetRouteState extends SinglePageRouteState {
  final MaterialPagePlan widgetRoute;
  final RouteInfo routeInfo;

  WidgetRouteState(this.widgetRoute, this.routeInfo);

  Page<void> createPage() {
    return MaterialPage<void>(
      key: ValueKey(routeInfo),
      child: widgetRoute.builder(routeInfo),
    );
  }

  bool maybeSetRouteStates(Iterable<RouteState> routes) {
    return false;
  }

  @override
  bool maybePush(RouteState route) {
    return false;
  }

  @override
  bool maybePop() {
    return false;
  }

  @override
  Iterable<RouteState> getCurrentRouteStates() sync* {
    yield this;
  }
}

mixin RedirectPlan {
  String get redirectPath;
}

class PagePlan extends RoutePlan {
  final List<String> pathTemplates;
  final Page Function(RouteInfo info) builder;
  final bool Function(RouteInfo info)? validate;
  final void Function(Routemaster routemaster, RouteInfo info)?
      onValidationFailed;

  PagePlan(
    String pathTemplate,
    this.builder, {
    this.validate,
    this.onValidationFailed,
  }) : this.pathTemplates = [pathTemplate];

  PagePlan.routes(
    this.pathTemplates,
    this.builder, {
    this.validate,
    this.onValidationFailed,
  });

  @override
  RouteState createState(Routemaster delegate, RouteInfo routeInfo) {
    return PageRouteState(this, routeInfo);
  }
}

class PageRouteState extends SinglePageRouteState {
  final PagePlan pageRoute;
  final RouteInfo routeInfo;

  PageRouteState(this.pageRoute, this.routeInfo);

  Page createPage() {
    return pageRoute.builder(routeInfo);
  }

  bool maybeSetRouteStates(Iterable<RouteState> routes) {
    return false;
  }

  @override
  bool maybePush(RouteState route) {
    return false;
  }

  @override
  bool maybePop() {
    return false;
  }

  @override
  Iterable<RouteState> getCurrentRouteStates() sync* {
    yield this;
  }
}
