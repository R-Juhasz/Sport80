import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/sport80_state.dart';

class ReminderService {
  static const _notificationId = 80080;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }

    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Etc/UTC'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );

    _initialized = true;
  }

  Future<String> syncReminder(ReminderSettings settings) async {
    if (kIsWeb) {
      return 'Reminder time saved. Device notifications are available on mobile builds.';
    }

    await initialize();
    await _notifications.cancel(_notificationId);

    if (!settings.enabled) {
      return 'Daily reminders are turned off.';
    }

    final permissionGranted = await _requestPermission();
    if (!permissionGranted) {
      return 'Reminder saved, but notification permission is still disabled.';
    }

    final scheduledDate = _nextOccurrence(settings.hour, settings.minute);

    await _notifications.zonedSchedule(
      _notificationId,
      'Sport 80',
      'Today\'s challenge is ready. Protect the streak and start strong.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sport80_daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily challenge reminders for Sport 80.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    return 'Daily reminder scheduled for ${settings.formattedTime}.';
  }

  Future<void> cancelReminder() async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    await _notifications.cancel(_notificationId);
  }

  Future<bool> _requestPermission() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        final iosImplementation = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        return await iosImplementation?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      case TargetPlatform.macOS:
        final macImplementation = _notifications
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>();
        return await macImplementation?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      case TargetPlatform.android:
        final implementation = _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        return await implementation?.requestNotificationsPermission() ?? true;
      default:
        return true;
    }
  }

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
