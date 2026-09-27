import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'salatak_daily';
  static const _channelName = 'تذكير صلاتك';
  static const _channelDesc = 'إشعارات يومية لتذكيرك بقضاء الصلاة';

  static const _notificationId = 1001;

  /// تهيئة الإشعارات (تُستدعى من main)
  static Future<void> initialize() async {
    if (_initialized) return;

    // تهيئة المناطق الزمنية
    tz.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // fallback: استخدم UTC+3 (بغداد)
      tz.setLocalLocation(tz.getLocation('Asia/Baghdad'));
    }

    // إعدادات Android
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const init = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      init,
      onDidReceiveNotificationResponse: (response) {
        // عند الضغط على الإشعار — يُفتح التطبيق تلقائياً
      },
    );

    // إنشاء قناة الإشعارات
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
      ),
    );

    _initialized = true;
  }

  /// طلب إذن الإشعارات (Android 13+)
  static Future<bool> requestPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return false;
    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }

  /// جدولة إشعار يومي
  static Future<void> scheduleDaily({
    required TimeOfDay time,
    String title = '🕌 صلاتك',
    String body = 'لا تنس قضاء صلواتك اليوم',
  }) async {
    await initialize();

    // احذف الإشعارات القديمة
    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      time.hour, time.minute,
    );

    // إذا مضى الوقت اليوم، جدوله للغد
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _notificationId,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// إلغاء كل الإشعارات
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// عرض إشعار تجريبي فوري
  static Future<void> showTestNotification() async {
    await initialize();
    await _plugin.show(
      999,
      '🕌 صلاتك',
      'هذا إشعار تجريبي — الإشعارات تعمل بنجاح!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
