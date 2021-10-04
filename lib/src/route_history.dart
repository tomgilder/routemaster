part of '../routemaster.dart';

/// Allows navigating through the router's chronological history.
class RouteHistory {
  final _RoutemasterState _state;

  RouteHistory._(this._state);

  int _index = -1;
  final _history = <RouteData>[];

  bool get _isEmpty => _history.isEmpty;

  /// Whether there's a previous chronological history entry.
  bool get canGoBack => _index > 0;

  /// Whether there's a forward chronological history entry.
  bool get canGoForward => _index < _history.length - 1;

  /// Goes back in chronological navigation order.
  ///
  /// Returns `true` if the navigation was successful, or `false` if it wasn't.
  ///
  /// Does nothing if there's no previous chronological history entry.
  bool back() {
    if (!canGoBack) {
      return false;
    }

    _index--;

    if (kIsWeb && SystemNav.enabled) {
      SystemNav.back();
    } else {
      _navigate(_history[_index]);
    }

    return true;
  }

  /// Goes forward in chronological navigation order.
  ///
  /// Returns `true` if the navigation was successful, or `false` if it wasn't.
  ///
  /// Does nothing if there's no forward chronological history entry.
  bool forward() {
    if (!canGoForward) {
      return false;
    }

    _index++;

    if (kIsWeb && SystemNav.enabled) {
      SystemNav.forward();
    } else {
      _navigate(_history[_index]);
    }

    return true;
  }

  void _goToIndex(int index) {
    _index = index;
    _navigate(_history[_index]);
  }

  void _didNavigate({required RouteData route, required bool isReplacement}) {
    if (isReplacement) {
      _didReplace(route);
    } else {
      _didPush(route);
    }
  }

  void _didPush(RouteData route) {
    final routeHasChanged = _history.isEmpty || route != _history[_index];

    if (routeHasChanged) {
      _history.add(route);
      _index++;
      _clearForwardEntries();
    }
  }

  void _didReplace(RouteData route) {
    if (_history.isNotEmpty) {
      _history.removeLast();
    }

    if (_index == -1) {
      _index = 0;
    }

    _history.add(route);
    _clearForwardEntries();
  }

  void _clearForwardEntries() {
    if (_history.length > _index) {
      _history.removeRange(_index, _history.length - 1);
    }
  }

  void _navigate(RouteData route) {
    _state.delegate._navigate(
      uri: route._uri,
      isReplacement: true,
      isHistoryNavigation: true,
      requestSource: RequestSource.internal,
    );
  }
}
