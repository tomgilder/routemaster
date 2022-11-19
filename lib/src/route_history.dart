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

// coverage:ignore-start
  void _goToIndex(int index) {
    if (index == _index) {
      return;
    }

    _index = index;
    _navigate(
      _history[_index],
      isBrowserHistoryNavigation: true,
    );
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

  void _navigate(
    RouteData route, {
    bool isBrowserHistoryNavigation = false,
  }) {
    _state.delegate._navigate(
      uri: route._uri,
      isReplacement: false,
      requestSource: RequestSource.internal,
      isBrowserHistoryNavigation: isBrowserHistoryNavigation,
    );
  }

  void _onPopPage({required RouteData newRoute}) {
    final poppingToPreviousHistoryRoute =
        _index > 0 && _history[_index - 1] == newRoute;

    if (poppingToPreviousHistoryRoute) {
      if (kIsWeb && SystemNav.enabled) {
        // Use system navigation so forward button works
        SystemNav.back(); // coverage:ignore-line
      } else {
        _index--;
        _state.delegate._updateCurrentConfiguration(
          isReplacement: true,
          updateHistory: false,
        );
      }
    } else {
      _state.delegate._updateCurrentConfiguration(
        isReplacement: true,
      );
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
