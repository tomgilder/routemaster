# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Routemaster is a Flutter routing package. It provides declarative URL-based routing with support for tabs, nested routes, guards, redirects, and web/mobile/desktop platforms.

## Common Commands

```bash
# Run unit tests (VM)
flutter test

# Run unit tests (web/Chrome)
flutter test --platform chrome

# Run a single test file
flutter test test/router_test.dart

# Run all tests including integration and example app tests
./run-all-tests.sh

# Run integration tests
integration_test_app/run.sh

# Analyze code
flutter analyze

# Get dependencies
flutter pub get
```

## Architecture

The main library is exported from `lib/routemaster.dart` (~1500 lines), which is the core file containing `RouteMap`, `RoutemasterDelegate`, `Routemaster`, `PageStack`, and `RouteData`.

### Key Components

- **RouteMap**: Maps URL paths to page builders. Paths support `:param` parameters and `_`-prefixed private segments (hidden from URL bar).
- **RoutemasterDelegate**: The `RouterDelegate` implementation that manages navigation state and integrates with Flutter's Router API.
- **TrieRouter** (`lib/src/trie_router/`): Trie-based data structure for efficient route matching.
- **Page types** (`lib/src/pages/`): `TabPage`, `CupertinoTabPage`, `IndexedPage`, `StackPage`, `TransitionPage`, `Guard`, `Redirect`.
- **Platform abstraction**: `system_nav.dart` / `system_nav_main.dart` / `system_nav_web.dart` handle web vs native navigation differences. `fake_html.dart` stubs web APIs for non-web platforms.
- **RouteHistory** (`lib/src/route_history.dart`): Chronological navigation history for back/forward.

### Core Design

Path hierarchy determines page hierarchy. For `/tabs/one/details`, the router builds a stack: the `/tabs` page (e.g., a `TabPage`) contains `/tabs/one`, which contains `/tabs/one/details`. Tab pages use path prefixes to determine which tab a sub-route belongs to.

## Code Style

Strict analysis is enabled: `strict-casts`, `strict-inference`, `strict-raw-types`. The `public_member_api_docs` lint requires documentation on all public API members.

## Test Structure

Tests are in `test/` organized by feature (e.g., `tab_test.dart`, `guard_test.dart`, `history_test.dart`). `test/helpers.dart` provides test utilities including `recordUrlChanges()` for tracking URL state and mock history providers. Example apps `book_store` and `mobile_app` also have their own tests.
