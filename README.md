# Routemaster

Hello! This is an experimental Flutter router, building on [page_router](https://github.com/johnpryan/page_router).

To see how it works, start at the [example app](https://github.com/tomgilder/routemaster/blob/main/examples/mobile_app/lib/main.dart).

I would love any feedback you have! Please create an issue for API feedback.

Please don't report bugs yet; it's way too early. There are almost no tests, so there will be bugs 😁 

# Design goals

* Work with the Flutter Navigator 2.0 API, don't try to replace it.
* Design around user scenarios/stories, such as the ones in [the Flutter storyboard](https://github.com/flutter/uxr/files/5953028/PUBLIC.Flutter.Navigator.API.Scenarios.-.Storyboards.pdf) - [see here for examples](https://github.com/tomgilder/routemaster/wiki/Routermaster-Flutter-scenarios).
* Be opinionated: try not to provide 10 options to achieve a goal, but be flexible for all scenarios.

***

![A photo of a Routemaster bus](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Routemaster_RML2375_%28JJD_375D%29%2C_6_March_2004.jpg/320px-Routemaster_RML2375_%28JJD_375D%29%2C_6_March_2004.jpg)

(photo by Chris Sampson, licensed under CC BY 2.0)