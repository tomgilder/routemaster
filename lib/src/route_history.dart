part of '../routemaster.dart';

/// Allows navigating through the router's chronological history.
class RouteHistory {
  final _RoutemasterState _state;

  RouteHistory._(this._state);

  int _index = -1;
  final _history = <RouteData>[];

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

    if (kIsWeb && SystemNav.enabled) {
      SystemNav.back(); // coverage:ignore-line
    } else {
      _index--;

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

    if (kIsWeb && SystemNav.enabled) {
      SystemNav.forward(); // coverage:ignore-line
    } else {
      _index++;

      _navigate(_history[_index]);
    }

    return true;
  }

  /// Clear the navigation history.
  ///
  /// Does nothing if there's no history entry.
  void clear() {
    if (_index < 0) return;
    final last = _history[_index];
    _index = 0;
    _history.clear();
    _history.add(last);
  }

  // coverage:ignore-start
  void _goToIndex(int index) {
    if (index == _index) {
      return;
    }

    _index = index;
    _navigate(_history[_index], isBrowserHistoryNavigation: true);
  }
  // coverage:ignore-end

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
      _clearForwardEntries();
      _history.add(route);
      _index++;
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
    if (_history.length > _index + 1) {
      _history.removeRange(_index + 1, _history.length);
    }
  }

  void _navigate(RouteData route, {bool isBrowserHistoryNavigation = false}) {
    _state.delegate._navigate(
      uri: route._uri,
      isReplacement: false,
      requestSource: .internal,
      isBrowserHistoryNavigation: isBrowserHistoryNavigation,
    );
  }

  void _onPopPage({required RouteData newRoute}) {
    final poppingToPreviousHistoryRoute =
        _index > 0 && _history[_index - 1] == newRoute;

    if (poppingToPreviousHistoryRoute) {
      final isWebNav = kIsWeb && SystemNav.enabled;
      if (isWebNav) {
        // Use system navigation so forward button works
        SystemNav.back(); // coverage:ignore-line
      }
      _index--;
      _state.delegate._updateCurrentConfiguration(
        isReplacement: true,
        updateHistory: false,
        // On web, use isBrowserHistoryNavigation to update configuration
        // without triggering replaceState, which would overwrite the browser's
        // forward history entry before SystemNav.back() completes.
        isBrowserHistoryNavigation: isWebNav,
      );
    } else {
      _state.delegate._updateCurrentConfiguration(isReplacement: true);
    }
  }

  void _onPopToRoute({required RouteData newRoute}) {
    // Search backwards from _index for the target route
    int? targetIndex;
    for (var i = _index - 1; i >= 0; i--) {
      if (_history[i] == newRoute) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex != null) {
      final stepsBack = _index - targetIndex;
      if (stepsBack <= 0) {
        _state.delegate._updateCurrentConfiguration(updateHistory: false);
        return;
      }

      final isWebNav = kIsWeb && SystemNav.enabled;
      if (isWebNav) {
        // Use browser history.go() so forward button works
        SystemNav.go(-stepsBack); // coverage:ignore-line
      }
      _index = targetIndex;
      _state.delegate._updateCurrentConfiguration(
        isReplacement: true,
        updateHistory: false,
        // On web, use isBrowserHistoryNavigation to update configuration
        // without triggering replaceState, which would overwrite the browser's
        // forward history entry before SystemNav.go() completes.
        isBrowserHistoryNavigation: isWebNav,
      );
    } else {
      // Route not found in history, use replacement behavior
      _state.delegate._updateCurrentConfiguration(isReplacement: true);
    }
  }

  @override
  String toString() {
    return 'RouteHistory('
        'index: $_index, '
        'canGoBack: $canGoBack, '
        'canGoForward: $canGoForward, '
        'history: $_history'
        ')';
  }
}
