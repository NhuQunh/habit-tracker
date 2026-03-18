import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize notification settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleDailyReminder() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_reminder',
      'Nhắc nhở hàng ngày',
      channelDescription: 'Thông báo nhắc nhở hoàn thành thói quen',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule for 7:00 AM tomorrow
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      7, // 7 AM
      0,  // 0 minutes
    );

    // If it's already past 7 AM today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0, // notification id
        'Nhắc nhở hoàn thành thói quen',
        'Đã đến lúc thực hiện các thói quen tốt của bạn hôm nay!',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted') {
        rethrow;
      }

      // Android 14+ can deny exact alarms. Fallback to inexact so app doesn't crash.
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0, // notification id
        'Nhắc nhở hoàn thành thói quen',
        'Đã đến lúc thực hiện các thói quen tốt của bạn hôm nay!',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );
    }
  }

  Future<void> cancelDailyReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> showWeeklyReport({
    required int totalHabits,
    required int completedHabits,
    required double completionRate,
  }) async {
    final completionPercentage = (completionRate * 100).round();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'weekly_report',
      'Báo cáo cuối tuần',
      channelDescription: 'Tóm tắt tiến độ thói quen trong tuần',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      1, // notification id
      'Báo cáo cuối tuần',
      'Tuần này bạn đã hoàn thành $completedHabits/$totalHabits thói quen ($completionPercentage%). Tiếp tục phát huy!',
      details,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to app
    // For now, just print the payload
    print('Notification tapped: ${response.payload}');
  }

  Future<bool> areNotificationsEnabled() async {
    return await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        true; // Assume enabled on iOS if we can't check
  }
}