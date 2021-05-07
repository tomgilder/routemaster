import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifications {
  final void Function(String) onNotificationSelected;

  Notifications({required this.onNotificationSelected});

  final FlutterLocalNotificationsPlugin? notifications =
      kIsWeb ? null : FlutterLocalNotificationsPlugin();

  /// Sets up notifications. Returns a payload if the app was launched via a
  /// notification.
  Future<String?> init() async {
    if (notifications == null) {
      return null;
    }

    await notifications!.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
        iOS: IOSInitializationSettings(),
        macOS: MacOSInitializationSettings(),
      ),
      onSelectNotification: (payload) async {
        if (payload != null) {
          onNotificationSelected(payload);
        }
      },
    );

    final details = await notifications!.getNotificationAppLaunchDetails();
    return details?.payload;
  }

  void showNotification() async {
    if (notifications == null) {
      return;
    }

    await notifications!.show(
      0,
      'Hello world',
      'Wanna read a great article? Click here!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId',
          'channelName',
          'channelDescription',
        ),
      ),
      payload: '/article/1',
    );
  }

  void scheduleNotification() async {
    if (notifications == null) {
      return;
    }

    tz.initializeTimeZones();
    notifications!.zonedSchedule(
      0,
      'Hey there!',
      'Wanna read a great article? Click here!',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: '/article/1',
    );
  }
}
