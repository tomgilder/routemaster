import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A transition for a page pop or push animation.
abstract class PageTransition {
  /// Initialize a transition for a page pop or push animation.
  const PageTransition();

  /// A builder that configures the animation.
  PageTransitionsBuilder get transitionsBuilder;

  /// How long this transition animation lasts.
  Duration get duration;

  /// A transition with no animation.
  static PageTransition get none => const _NoPageTransition();

  /// The default fade upwards transition used on Android.
  static PageTransition get fadeUpwards => const _FadeUpwardsPageTransition();

  /// The default slide-in transition used on iOS.
  static PageTransition get cupertino => const _CupertinoPageTransition();

  /// A zoom transition matching the one used on Android 10.
  static PageTransition get zoom => const _ZoomPageTransition();

  /// Returns the default page transition for the given [platform].
  static PageTransition platformDefault(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return PageTransition.fadeUpwards;

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return PageTransition.cupertino;
    }
  }
}

class _NoPageTransition extends PageTransition {
  const _NoPageTransition();

  @override
  final Duration duration =
      // Workaround for https://github.com/flutter/flutter/issues/86604
      const Duration(microseconds: 1);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const _NoPageTransitionBuilder();
}

class _NoPageTransitionBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class _CupertinoPageTransition extends PageTransition {
  const _CupertinoPageTransition();

  @override
  final Duration duration = const Duration(milliseconds: 400);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const CupertinoPageTransitionsBuilder();
}

class _FadeUpwardsPageTransition extends PageTransition {
  const _FadeUpwardsPageTransition();

  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const FadeUpwardsPageTransitionsBuilder();
}

class _ZoomPageTransition extends PageTransition {
  const _ZoomPageTransition();

  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const ZoomPageTransitionsBuilder();
}

/// A page that can use separate push and pop animations.
///
/// [pushTransition] and [popAnimation] can use one of the built-in transitions:
///
///   * [PageTransition.none] - an immediate transition without any animation.
///   * [PageTransition.fadeUpwards] - the default Android fade-up animation.
///   * [PageTransition.cupertino] - the default iOS slide-in animation.
///   * [PageTransition.zoom] - a zoom animation used on Android 10.
///
/// Alternatively you can subclass [PageTransition] to create your own custom
/// animation.
///
/// If [pushTransition] or [popAnimation] are null, the platform default
/// transition is used. This is the Cupertino animation on iOS and macOS, and
/// the fade upwards animation on all other platforms.
class TransitionPage<T> extends TransitionBuilderPage<T> {
  /// Initialize a transition page.
  ///
  /// If [pushTransition] or [popAnimation] are null, the platform default
  /// transition is used. This is the Cupertino animation on iOS and macOS, and
  /// the fade upwards animation on all other platforms.
  const TransitionPage({
    required this.child,
    this.pushTransition,
    this.popTransition,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.opaque = true,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          child: child,
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  /// Configures the transition animation used when this page is pushed.
  ///
  /// This can be set to one of the default built-in transitions:
  ///
  ///   * [PageTransition.none] - an immediate transition without any animation.
  ///   * [PageTransition.fadeUpwards] - the default Android fade-up animation.
  ///   * [PageTransition.cupertino] - the default iOS slide-in animation.
  ///   * [PageTransition.zoom] - a zoom animation used on Android 10.
  ///
  /// Alternatively you can subclass [PageTransition] to create your own custom
  /// animation.
  ///
  /// If this value is null, the platform default transition is used.
  final PageTransition? pushTransition;

  /// Configures the transition animation used when this page is popped.
  ///
  /// This can be set to one of the default built-in transitions:
  ///
  ///   * [PageTransition.none] - an immediate transition without any animation.
  ///   * [PageTransition.fadeUpwards] - the default Android fade-up animation.
  ///   * [PageTransition.cupertino] - the default iOS slide-in animation.
  ///   * [PageTransition.zoom] - a zoom animation used on Android 10.
  ///
  /// Alternatively you can subclass [PageTransition] to create your own custom
  /// animation.
  ///
  /// If this value is null, the platform default transition is used.
  final PageTransition? popTransition;

  @override
  PageTransition buildPushTransition(BuildContext context) {
    if (pushTransition == null) {
      return PageTransition.platformDefault(Theme.of(context).platform);
    }

    return pushTransition!;
  }

  @override
  PageTransition buildPopTransition(BuildContext context) {
    if (popTransition == null) {
      return PageTransition.platformDefault(Theme.of(context).platform);
    }

    return popTransition!;
  }

  /// The content to be shown in the [Route] created by this page.
  @override
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  @override
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  @override
  final bool fullscreenDialog;

  /// {@macro flutter.widgets.TransitionRoute.opaque}
  @override
  final bool opaque;
}

/// A page that can be subclassed to provide push and pop animations.
///
/// When a page is pushed, [buildPushTransition] is called, and the returned
/// transition is used to animate the page onto the screen.
///
/// When a page is popped, [buildPopTransition] is called, and the returned
/// transition is used to animate the page off the screen.
abstract class TransitionBuilderPage<T> extends Page<T> {
  /// Initialize a page that provides separate push and pop animations.
  const TransitionBuilderPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.opaque = true,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  /// Called when this page is pushed, returns a [PageTransition] to configure
  /// the push animation.
  ///
  /// Return `PageTransition.none` for an immediate push with no animation.
  PageTransition buildPushTransition(BuildContext context);

  /// Called when this page is popped, returns a [PageTransition] to configure
  /// the pop animation.
  ///
  /// Return `PageTransition.none` for an immediate pop with no animation.
  PageTransition buildPopTransition(BuildContext context);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  /// {@macro flutter.widgets.TransitionRoute.opaque}
  final bool opaque;

  @override
  Route<T> createRoute(BuildContext context) {
    return TransitionBuilderPageRoute<T>(page: this);
  }
}

/// The route created by by [TransitionBuilderPage], which delegates push and
/// pop transition animations to that page.
class TransitionBuilderPageRoute<T> extends PageRoute<T> {
  /// Initialize a route which delegates push and pop transition animations to
  /// the provided [page].
  TransitionBuilderPageRoute({
    required TransitionBuilderPage<T> page,
  }) : super(settings: page);

  TransitionBuilderPage<T> get _page => settings as TransitionBuilderPage<T>;

  /// This value is not used.
  ///
  /// The actual durations are provides by the [PageTransition] objects.
  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _page.child,
    );
  }

  @override
  bool didPop(T? result) {
    final transition = _page.buildPopTransition(navigator!.context);
    controller!.reverseDuration = transition.duration;
    return super.didPop(result);
  }

  @override
  TickerFuture didPush() {
    final transition = _page.buildPushTransition(navigator!.context);
    controller!.duration = transition.duration;
    return super.didPush();
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final isPopping = controller!.status == AnimationStatus.reverse;

    // If the push is complete we build the pop transition.
    // This is so cupertino back user gesture will work, even if a cupertino
    // transition wasn't used to show this page.
    final pushIsComplete = controller!.status == AnimationStatus.completed;

    final transition =
        (isPopping || pushIsComplete || navigator!.userGestureInProgress)
            ? _page.buildPopTransition(navigator!.context)
            : _page.buildPushTransition(navigator!.context);

    return transition.transitionsBuilder
        .buildTransitions(this, context, animation, secondaryAnimation, child);
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  bool get opaque => _page.opaque;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}
