import 'package:flutter/material.dart';
import '../../routemaster.dart';
import '../route_info.dart';

@immutable
abstract class RoutePlan {
  RoutePlan();

  List<String> get pathTemplates;

  RouteState createState(Routemaster delegate, RouteInfo path);

  final bool Function(RouteInfo info)? validate = (_) => true;
  final void Function(Routemaster routemaster, RouteInfo info)?
      onValidationFailed = (routemaster, _) {
    routemaster.replaceNamed(routemaster.defaultPath);
  };
}

abstract class RouteState {
  bool maybeSetRouteStates(Iterable<RouteState> routes);
  bool maybePush(RouteState route);
  bool maybePop();

  RouteInfo get routeInfo;
  Iterable<RouteState> getCurrentRouteStates();
}

// TODO: Is this abstract class helpful to anyone?
abstract class MultiPageRouteState extends RouteState {
  List<Page> createPages();

  void pop();
  void push(RouteState routerData);
}

// TODO: Is this abstract class helpful to anyone?
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

  RouteState get currentRoute => this;

  WidgetRouteState(this.widgetRoute, this.routeInfo);

  Page<void> createPage() {
    return MaterialPage<void>(
      child: widgetRoute.builder(routeInfo),
      key: ValueKey(routeInfo.path),
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
