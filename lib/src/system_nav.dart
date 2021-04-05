export 'system_nav_main.dart' if (dart.library.js) 'system_nav_web.dart';

enum PathStrategy { hash, path }

bool isReplacementNavigation(Object state) {
  if (state is Map) {
    if (state['state'] is Map) {
      final dynamic routemasterState = state['state']['state'];
      if (routemasterState is Map) {
        final dynamic isReplacement = routemasterState['isReplacement'];
        if (isReplacement is bool) {
          return isReplacement;
        }
      }
    }
  }

  return false;
}
