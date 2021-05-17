import 'package:flutter/material.dart';

/// The default not found page. To customize this, return a different page from
/// [RouteMap.onUnknownRoute].
class DefaultNotFoundPage extends StatelessWidget {
  /// The path that couldn't be found.
  final String path;

  /// Initializes the page with the path that couldn't be found.
  const DefaultNotFoundPage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text("Page '$path' wasn't found."),
        ),
      ),
    );
  }
}
