# Routemaster <img src="https://openclipart.org/download/286938/Double-Decker-Bus.svg" width="30">

Hello! Routemaster is an easy-to-use router for Flutter, which wraps over Navigator 2.0.

## Features

* Simple declarative mapping from a URLs to pages
* Easy-to-use API: just `Routemaster.of(context).push('/page')`
* Really easy nested navigation support for tabs
* Multiple route maps: for example one for a logged in user, another for logged out

Here's the entire routing setup needed for an app featuring tabs and pushed routes:

```dart
final routes = RouteMap(
  routes: {
    '/': (_) => CupertinoTabPage(
          child: HomePage(),
          paths: ['feed', 'settings'],
        ),

    '/feed': (_) => MaterialPage(child: FeedPage()),
    '/settings': (_) => MaterialPage(child: SettingsPage()),
    '/feed/profile/:id': (info) => MaterialPage(
      child: ProfilePage(id: info.pathParameters['id'])
    ),
  }
);

void main() {
  runApp(
      MaterialApp.router(
        routerDelegate: RoutemasterDelegate(routesBuilder: (context) => routes),
        routeInformationParser: RoutemasterParser(),
      ),
  );
}
```

And then to navigate:

```dart
Routemaster.of(context).push('/feed/profile/1');
```

...you can see this in action in [this simple app example](https://github.com/tomgilder/routemaster/blob/main/example/simple_example/lib/main.dart).

There's also a [more advanced example](https://github.com/tomgilder/routemaster/blob/main/example/mobile_app/lib/main.dart).

I would love any feedback you have! Please create an issue for API feedback.

## Design goals

* Integrated: work with the Flutter Navigator 2.0 API, don't try to replace it. Try to have a very Flutter-like API.
* Usable: design around user scenarios/stories, such as the ones in [the Flutter storyboard](https://github.com/flutter/uxr/files/5953028/PUBLIC.Flutter.Navigator.API.Scenarios.-.Storyboards.pdf) - [see here for examples](https://github.com/tomgilder/routemaster/wiki/Routemaster-Flutter-scenarios).
* Opinionated: don't provide 10 options to achieve a goal, but be flexible for all scenarios.
* Focused: just navigation, nothing else. For example, no dependency injection.

This project builds on [page_router](https://github.com/johnpryan/page_router).

## Name

Named after the original Routemaster:

![A photo of a Routemaster bus](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Routemaster_RML2375_%28JJD_375D%29%2C_6_March_2004.jpg/320px-Routemaster_RML2375_%28JJD_375D%29%2C_6_March_2004.jpg)

(photo by Chris Sampson, licensed under CC BY 2.0)
