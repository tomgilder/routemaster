import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  testWidgets('Pages do not rebuild', (tester) async {
    final tracker1 = Tracker();
    final tracker2 = Tracker();

    final delegate = RoutemasterDelegate(
      routesBuilder: (_) => RouteMap(
        routes: {
          '/': (_) => MaterialPage<void>(
                child: BuildTracker(tracker: tracker1),
              ),
          '/two': (_) => MaterialPage<void>(
                child: BuildTracker(tracker: tracker2),
              ),
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: RoutemasterParser(),
        routerDelegate: delegate,
      ),
    );

    delegate.push('/two');
    await tester.pump();
    await tester.pump(Duration(seconds: 1));

    expect(tracker1.initStateCount, 1);
    expect(tracker2.initStateCount, 1);
  });
}

class Tracker {
  var initStateCount = 0;
}

class BuildTracker extends StatefulWidget {
  final Tracker tracker;

  BuildTracker({required this.tracker});

  @override
  _BuildTrackerState createState() => _BuildTrackerState();
}

class _BuildTrackerState extends State<BuildTracker> {
  @override
  void initState() {
    super.initState();
    widget.tracker.initStateCount++;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
