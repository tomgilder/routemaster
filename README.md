# Routemaster <img src="https://openclipart.org/download/286938/Double-Decker-Bus.svg" width="30">

Hello! Routemaster is an easy-to-use router for Flutter, which wraps over Navigator 2.0... and has a [silly name](https://github.com/tomgilder/routemaster#Name).

[![Build](https://github.com/tomgilder/routemaster/actions/workflows/build.yaml/badge.svg)](https://github.com/tomgilder/routemaster/actions/workflows/build.yaml) [![codecov](https://codecov.io/gh/tomgilder/routemaster/branch/main/graph/badge.svg?token=JNF2NV7W09)](https://codecov.io/gh/tomgilder/routemaster)
[![pub](https://img.shields.io/pub/v/routemaster.svg?color=success)](https://pub.dev/packages/routemaster)

## Features

* Simple declarative mapping from URLs to pages
* Easy-to-use API: just `Routemaster.of(context).push('/page')`
* Really easy nested navigation support for tabs
* Multiple route maps: for example one for a logged in user, another for logged out
* Observers to easily listen to route changes
* Covered by over 200 unit, widget and integration tests

Here's the entire routing setup needed for an app featuring tabs and pushed routes:

```dart
final routes = RouteMap(
  routes: {
    '/': (_) => CupertinoTabPage(
          child: HomePage(),
          paths: ['/feed', '/settings'],
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

# Documentation

Begin with the quick start below, but also see the [API reference](https://pub.dev/documentation/routemaster/latest/routemaster/routemaster-library.html), [wiki](https://github.com/tomgilder/routemaster/wiki) and [FAQs](https://github.com/tomgilder/routemaster/wiki/FAQs).
___

<img src="https://openclipart.org/download/286938/Double-Decker-Bus.svg" width="80"> 

# Quick start API tour

* [Overview](#overview)
* [Routing](#routing)
* [Tabs](#tabs)
* [Cupertino tabs](#cupertino-tabs)
* [Guarded routes](#guarded-routes)
* [404 Page](#404-page)
* [Redirect](#redirect)
* [Swap routing map](#swap-routing-map)
* [Navigation observers](#navigation-observers)
* [Navigate without a context](#navigate-without-a-context)
* [Hero animations](#hero-animations) 
 
## Overview

Routemaster generates pages based on the current path. This is the key concept of its path-base routing. Path structure matters.

It uses the path to decide where a page should be pushed. This means the path needs to match your intended page hierarchy.

For example:

```dart
'/tabs': (route) => TabPage(child: HomePage(), paths: ['one', 'two']),

// First tab default page
'/tabs/one': (route) => MaterialPage(child: TabOnePage()),

// Second tab default page
'/tabs/two': (route) => MaterialPage(child: TabTwoPage()),

// Second tab sub-page: will be displayed in the 2nd tab because it
// starts with '/tabs/two'
'/tabs/two/subpage': (route) => MaterialPage(child: TabTwoPage()),

// Not a tab page: will not be displayed in in a tab
// because the path doesn't start with '/tabs/one' or '/tabs/two'
'/tabs/notInATab': (route) => MaterialPage(child: NotTabPage()),
```

Any child paths that begin with `/tabs/one` or `/tabs/two` will be pushed into the correct tab. 

When navigating to `/tabs/two/subpage`, the `TabPage` will be asked "hey, do you know how to handle this path?" and it'll go "sure! it starts with `/tabs/two`, so it goes in my second tab".

However, navigating to `/tabs/notInATab` will **not** be displayed in a tab, but pushed on top of the tab bar.

`TabPage` will be all "yeah sorry, no idea what to do with that, doesn't match any of my tab paths" and its parent will be asked to hande it.

Path hierarchy matters, for example [changing where dialogs are displayed](https://github.com/tomgilder/routemaster/wiki/Path-hierarchy).
  
## Routing

### Basic app routing setup

```dart
MaterialApp.router(
  routerDelegate: RoutemasterDelegate(
    routesBuilder: (context) => RouteMap(routes: {
      '/': (routeData) => MaterialPage(child: PageOne()),
      '/two': (routeData) => MaterialPage(child: PageTwo()),
    }),
  ),
  routeInformationParser: RoutemasterParser(),
)
```

###  Navigate from within pages

```dart
Routemaster.of(context).push('relative-path');
Routemaster.of(context).push('/absolute-path');

Routemaster.of(context).replace('relative-path');
Routemaster.of(context).replace('/absolute-path');
```

### Path parameters

```dart
// Path '/products/123' will result in ProductPage(id: '123')
RouteMap(routes: {
  '/products/:id': (route) => MaterialPage(
        child: ProductPage(id: route.pathParameters['id']),
      ),
  '/products/myPage': (route) => MaterialPage(MyPage()),
})
```

Note that routes without path parameters have priority, so in the above example
`/products/myPage` will show `MyPage`.

### Query parameters

```dart
// Path '/search?query=hello' results in SearchPage(query: 'hello')
RouteMap(routes: {
  '/search': (route) => MaterialPage(
        child: SearchPage(query: route.queryParameters['query']),
      ),
})
```

### Get current path info within a widget

```dart
RouteData.of(context).path; // Full path: '/product/123?query=param'
RouteData.of(context).pathParameters; // Map: {'id': '123'}
RouteData.of(context).queryParameters; // Map: {'query': 'param'}
```

## Tabs

Setup:

```dart
RouteMap(
  routes: {
    '/': (route) => TabPage(
          child: HomePage(),
          paths: ['/feed', '/settings'],
        ),
    '/feed': (route) => MaterialPage(child: FeedPage()),
    '/settings': (route) => MaterialPage(child: SettingsPage()),
  },
)
```

Main page:

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabPage = TabPage.of(context);

    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: tabPage.controller,
          tabs: [
            Tab(text: 'Feed'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabPage.controller,
        children: [
          for (final stack in tabPage.stacks) PageStackNavigator(stack: stack),
        ],
      ),
    );
  }
}
```

## Cupertino tabs

Setup:

```dart
RouteMap(
  routes: {
    '/': (route) => CupertinoTabPage(
          child: HomePage(),
          paths: ['/feed', '/settings'],
        ),
    '/feed': (route) => MaterialPage(child: FeedPage()),
    '/settings': (route) => MaterialPage(child: SettingsPage()),
  },
)
```

Main page:

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: tabState.tabBuilder,
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            label: 'Feed',
            icon: Icon(CupertinoIcons.list_bullet),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(CupertinoIcons.search),
          ),
        ],
      ),
    );
  }
}
```

## Guarded routes

Show default not found page if validation fails:

```dart
'/protected-route': (route) => 
    canUserAccessPage()
      ? MaterialPage(child: ProtectedPage())
      : NotFound()
```

Redirect to another page if validation fails (changes URL):

```dart
'/protected-route': (route) => 
    canUserAccessPage()
      ? MaterialPage(child: ProtectedPage())
      : Redirect('/no-access'),
```

Show another page if validation fails (doesn't change URL): 

```dart
'/protected-route': (route) => 
    canUserAccessPage()
      ? MaterialPage(child: ProtectedPage())
      : MaterialPage(child: CustomNoAccessPage())
```

## 404 Page

Default page to shown on unknown URL:

```dart
RouteMap(
    onUnknownRoute: (route, context) {
        return MaterialPage(child: NotFoundPage());
    },
    routes: {
        '/': (_) => MaterialPage(child: HomePage()),
    },
)
```

## Redirect

Redirect one route to another:

```dart
RouteMap(routes: {
    '/one': (routeData) => MaterialPage(child: PageOne()),
    '/two': (routeData) => Redirect('/one'),
})
```

Redirect all routes to login page, for a logged-out route map:

```dart
RouteMap(
  onUnknownRoute: (_) => Redirect('/'),
  routes: {
    '/': (_) => MaterialPage(child: LoginPage()),
  },
)
```

Passing path parameters from original to the redirect path:

```dart
RouteMap(routes: {
    '/user/:id': (routeData) => MaterialPage(child: UserPage(id: id)),
    '/profile/:uid': (routeData) => Redirect('/user/:uid'),
})
```

## Swap routing map

You can swap the entire routing map at runtime.

This is particularly useful for different pages depending on whether the user is logged in:

```dart
final loggedOutMap = RouteMap(
  onUnknownRoute: (route, context) => Redirect('/'),
  routes: {
    '/': (_) => MaterialPage(child: LoginPage()),
  },
);

final loggedInMap = RouteMap(
  routes: {
    // Regular app routes
  },
);

MaterialApp.router(
  routerDelegate: RoutemasterDelegate(
    routesBuilder: (context) {
			// This will rebuild when AppState changes
      final appState = Provider.of<AppState>(context);
      return appState.isLoggedIn ? loggedInMap : loggedOutMap;
    },
  ),
  routeInformationParser: RoutemasterParser(),
);
```

## Navigation observers

```dart
class MyObserver extends RoutemasterObserver {
	// RoutemasterObserver extends NavigatorObserver and
	// receives all nested Navigator events
  @override
  void didPop(Route route, Route? previousRoute) {
    print('Popped a route');
  }

	// Routemaster-specific observer method
  @override
  void didChangeRoute(RouteData routeData, Page page) {
    print('New route: ${routeData.path}');
  }
}

MaterialApp.router(
  routerDelegate: RoutemasterDelegate(
    observers: [MyObserver()],
    routesBuilder: (_) => routeMap,
  ),
  routeInformationParser: RoutemasterParser(),
);
```

## Navigate without a context

app.dart
```dart
final routemaster = RoutemasterDelegate(
  routesBuilder: (context) => routeMap,
);

MaterialApp.router(
  routerDelegate: routemaster,
  routeInformationParser: RoutemasterParser(),
)
```

my_widget.dart
```dart
import 'app.dart';

void onTap() {
  routemaster.push('/blah');
}
```

## Hero animations

Hero animations will work automatically on the top-level navigator (assuming you're using `MaterialApp` or `CupertinoApp`).

For any child navigators, you'll need to wrap `PageStackNavigator` in a `HeroControllerScope`, like this:

```dart
HeroControllerScope(
  controller: MaterialApp.createMaterialHeroController(),
  child: PageStackNavigator(
    stack: pageStack,
  )
)
```

# Design goals

* Integrated: work with the Flutter Navigator 2.0 API, don't try to replace it. Try to have a very Flutter-like API.
* Usable: design around user scenarios/stories, such as the ones in [the Flutter storyboard](https://github.com/flutter/uxr/files/5953028/PUBLIC.Flutter.Navigator.API.Scenarios.-.Storyboards.pdf) - [see here for examples](https://github.com/tomgilder/routemaster/wiki/Routemaster-Flutter-scenarios).
* Opinionated: don't provide 10 options to achieve a goal, but be flexible for all scenarios.
* Focused: just navigation, nothing else. For example, no dependency injection.

This project builds on [page_router](https://github.com/johnpryan/page_router).

# Name

Named after the [original Routemaster](https://en.wikipedia.org/wiki/AEC_Routemaster):

![A photo of a Routemaster bus](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Routemaster_RML2375_%28JJD_375D%29%2C_6_March_2004.jpg/320px-Routemaster_RML2375_%28JJD_375D%29%2C_6_March_2004.jpg)

(photo by Chris Sampson, licensed under CC BY 2.0)
