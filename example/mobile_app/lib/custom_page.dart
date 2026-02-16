import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class CustomPage extends TransitionBuilderPage<void> {
  CustomPage({required super.child});

  @override
  PageTransition buildPushTransition(BuildContext context) {
    if (kIsWeb) {
      // No push transition on web
      return PageTransition.none;
    }

    // Default Android fade upwards transition on push
    return PageTransition.fadeUpwards;
  }

  @override
  PageTransition buildPopTransition(BuildContext context) {
    if (kIsWeb) {
      // No pop transition on web
      return PageTransition.none;
    }

    // Cupertino transition on pop
    return PageTransition.cupertino;
  }
}
