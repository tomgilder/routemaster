# 0.9.0

* Breaking change: `PageStackNavigator` no longer automatically provides a `HeroController` - to use heroes, wrap the navigator in a `HeroControllerScope`
* Breaking change: refactored `PageWrapper` and `StatefulPage` (this is unlikely to affect you)
* Added a new property to get the current route: `Routemaster.of(context).currentRoute`
* Added documentation to all classes, properties and methods
* Fixed: `RouteData.of(context)` sometimes throwing when navigating away from a page
* Fixed: issue with rebuilding routes when `RoutemasterDelegate` is recreated 
* Fixed: widgets rebuilding when `RoutemasterDelegate` is recreated

# 0.8.0

* Breaking change: `Guard` properties have been renamed: `validate` is now `canNavigate` and `onValidationFailed` is now `onNavigationFailed`
* Breaking change: removed abstract `RouteConfig` class; to create custom routing maps, inherit from `RouteMap`
* Deprecation: `StackNavigator` has been renamed `PageStackNavigator`
* Added `NotFound` return page type
* Added ability to customise the top-level navigator with `RoutemasterDelegate.builder`
* Added ability to use tabs with a custom page type
* Fixed `replace()` not working with hashes on web
* Fixed path URL strategy not working when it's set outside Routemaster 
* Fixed tabs creating a redirect loop on web
* Note: Use of `Guard` is no longer recommended - use standard `if` statements and `NotFound` or `Redirect`

# 0.7.2

* Fixed `pathTemplate` property on `RouteData`

# 0.7.1

* Fixed paths using backslashes on Windows

# 0.7.0

* Breaking change: `RouteData.path` no longer returns the full path with query string, to match Dart's `Uri` object. Use `RouteData.toString()` or `RouteData.fullPath` for the entire path including query string.
* Breaking change: `Guard` now takes a `builder` method instead of a `child` property
* Added support for return values via `pop('Result')`
* Added support for getting the `Route` object when pushing a new path
* Fixed an issue where subpages wouldn't push on top of a tab page
* Fixed an issue where query string values were lost after using the back button

# 0.6.2

* Support for absolute paths in tab child routes

# 0.6.1

* Fixed building against Flutter master branch

# 0.6.0

* Added `SafeArea` to default 404 page
* Fixed an issue navigating with relative paths and query strings
* Fixed an issue where the controller didn't update when tab length changed

# 0.5.0

* Fixed an issue where the root navigator would rebuild unnecessarily
* Added more useful assert errors
* Added default body for `RoutemasterObserver.didChangeRoute` so you're not forced to override it

# 0.4.0

* Added support for `RoutemasterObserver` in `RoutemasterDelegate`
* Added support for `NavigatorObserver` in `StackNavigator`
* Renamed `tabController` to `controller`

# 0.3.1

* Bug fix for reusing stacks in multiple navigators

# 0.3.0

* Added `StackNavigator` to simplify API
* Support for non-hash URLs on web - `Routemaster.setPathUrlStrategy()`
* Support for hero animations in nested navigators

# 0.2.0

* Re-work guards and redirects to make API simpler

# 0.1.0

* API hopefully becoming stable
* More flexible and customisable router config
* Support for "404" pages via `onUnknownRoute`
* Added Dashazon example, see `example/book_store/`

# 0.0.2

* Hugely improved and totally refactored API
* Null safety

# 0.0.1

* Initial first version
