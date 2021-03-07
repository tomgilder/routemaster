# Routemaster

Hello! This is an in-development router for Flutter. It's an easy-to-use wrapper over Navigator 2.0.

Here's the entire routing setup needed for an app featuring tabs and pushed routes:

```dart
final plans = [
  CupertinoTabPlan(
    '/',
    (info, routeState) => HomePage(routeState: routeState),
    paths: ['/feed', '/settings'],
  ),
  MaterialPagePlan('/feed', (info) => FeedPage()),
  MaterialPagePlan('/feed/profile/:id', (info) => ProfilePage(id: info['id'])),
  MaterialPagePlan('/settings', (info) => SettingsPage()),
];

void main() {
  runApp(
      MaterialApp.router(
        routerDelegate: Routemaster(plans: plans),
        routeInformationParser: RoutemasterParser(),
      ),
    );
}
```

And then to navigate:

```dart
Routemaster.of(context).replaceNamed('/feed/profile/1');
```

...you can see this in action in [this simple app example](https://github.com/tomgilder/routemaster/blob/main/example/simple_example/lib/main.dart).

There's also a [more advanced example](https://github.com/tomgilder/routemaster/blob/main/example/mobile_app/lib/main.dart).

I would love any feedback you have! Please create an issue for API feedback.

Please don't report bugs yet; it's way too early. There are almost no tests, so there will be bugs 😁 

# Design goals

* Integrated: work with the Flutter Navigator 2.0 API, don't try to replace it. Try to have a very Flutter-like API.
* Usable: design around user scenarios/stories, such as the ones in [the Flutter storyboard](https://github.com/flutter/uxr/files/5953028/PUBLIC.Flutter.Navigator.API.Scenarios.-.Storyboards.pdf) - [see here for examples](https://github.com/tomgilder/routemaster/wiki/Routermaster-Flutter-scenarios).
* Opinionated: don't provide 10 options to achieve a goal, but be flexible for all scenarios.
* Focused: just navigation, nothing else. For example, no dependency injection.

# Architecture 

The architecture mirrors Flutter's fairly closely.

You create immutable `RoutePlan` objects as mapping between paths and widgets:

`MaterialPagePlan('/search', (_) => SearchPage())`

These `RoutePlan` objects have a `createState()` object which creates a mutable `RouteState` object to manage the in-memory state.

So for instance `TabPlan` creates a `TabRouteState`, which has a `index` property for which the current tab is.

This project builds on [page_router](https://github.com/johnpryan/page_router).

# Name

Named after the original Routemaster:

![A photo of a Routemaster bus](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Routemaster_RML2375_%28JJD_375D%29%2C_6_March_2004.jpg/320px-Routemaster_RML2375_%28JJD_375D%29%2C_6_March_2004.jpg)

(photo by Chris Sampson, licensed under CC BY 2.0)
