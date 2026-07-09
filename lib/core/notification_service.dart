import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show AndroidFlutterLocalNotificationsPlugin;

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _dailyId = 1001;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
    } catch (_) {}

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    try {
      await _plugin.initialize(initSettings);
      _initialized = true;
    } catch (_) {}
  }

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      await _plugin.cancel(_dailyId);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'daily_reminder',
        'Daily Reminder',
        channelDescription: 'Reminds you to log your daily expenses',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.zonedSchedule(
        _dailyId,
        'ClearSpend Reminder',
        'Have you logged your expenses today?',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  static Future<void> cancelDailyReminder() async {
    try {
      await _plugin.cancel(_dailyId);
    } catch (_) {}
  }

  static Future<void> showTestNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notifications channel',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000).toInt();
      await _plugin.show(id, 'ClearSpend', 'Test notification - notifications are working!', details);
    } catch (_) {}
  }

  static Future<bool> requestAndroidPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return false;
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }
}
