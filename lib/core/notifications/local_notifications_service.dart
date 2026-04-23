import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _taskChannel = AndroidNotificationChannel(
    'bloom_tasks',
    'BloomList Tasks',
    description: 'Rappels de tâches et échéances',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _focusChannel = AndroidNotificationChannel(
    'bloom_focus',
    'BloomList Focus',
    description: 'Notifications de fin de session focus',
    importance: Importance.high,
  );

  Future<void> init() async {
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();

      await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );

      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_taskChannel);
      await androidPlugin?.createNotificationChannel(_focusChannel);
    } catch (_) {
      // Ignore notification init failures to keep app stable in debug/prod.
    }
  }

  Future<void> requestPermissions() async {
    try {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();

      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  int _taskNotificationId(String taskId) {
    return taskId.hashCode & 0x7fffffff;
  }

  NotificationDetails _taskDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'bloom_tasks',
        'BloomList Tasks',
        channelDescription: 'Rappels de tâches et échéances',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  NotificationDetails _focusDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'bloom_focus',
        'BloomList Focus',
        channelDescription: 'Notifications de fin de session focus',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required DateTime reminderAt,
  }) async {
    try {
      if (reminderAt.isBefore(DateTime.now())) {
        return;
      }

      await _plugin.zonedSchedule(
        _taskNotificationId(taskId),
        'Rappel BloomList',
        title,
        tz.TZDateTime.from(reminderAt, tz.local),
        _taskDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: taskId,
      );
    } catch (_) {}
  }

  Future<void> cancelTaskReminder(String taskId) async {
    try {
      await _plugin.cancel(_taskNotificationId(taskId));
    } catch (_) {}
  }

  Future<void> showPomodoroCompleted() async {
    try {
      await _plugin.show(
        999998,
        'Session focus terminée',
        'Excellent travail. Prends une pause ou lance un nouveau cycle.',
        _focusDetails(),
      );
    } catch (_) {}
  }

  Future<bool?> canScheduleExactAlarms() async {
    try {
      final dynamic androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool? value = await androidPlugin?.canScheduleExactNotifications();
      return value;
    } catch (_) {
      return null;
    }
  }

  Future<bool> requestExactAlarmPermission() async {
    try {
      final dynamic androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted = await androidPlugin?.requestExactAlarmsPermission();
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }
}
