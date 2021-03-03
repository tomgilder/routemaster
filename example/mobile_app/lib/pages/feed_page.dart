import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Routemaster.of(context).pushNamed('profile/1'),
              child: Text('Push profile page with ID 1'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Routemaster.of(context).pushNamed('profile/2?message=hello'),
              child: Text('Push profile page with ID 2 and query string'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Routemaster.of(context).pushNamed('profile/1/photo'),
              child: Text("Go to user 1's photo page (skipping stacks)"),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String id;
  final String message;

  const ProfilePage({
    @required this.id,
    @required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Profile page, ID = $id, message = $message'),
            ElevatedButton(
              onPressed: () => Routemaster.of(context).pushNamed('photo'),
              child: Text('Photo page (custom animation)'),
            ),
            ElevatedButton(
              onPressed: () => Routemaster.of(context).pop(),
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class PhotoPage extends StatelessWidget {
  final String id;

  const PhotoPage({
    @required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This would be a lovely picture of user $id'),
            ElevatedButton(
              onPressed: () => Routemaster.of(context).pop(),
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
