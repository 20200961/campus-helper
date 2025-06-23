import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlarmItem {
  final int id;
  final DateTime scheduledDateTime;
  final String title;
  final String body;

  AlarmItem({
    required this.id,
    required this.scheduledDateTime,
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': scheduledDateTime.toIso8601String(),
    'title': title,
    'body': body,
  };

  factory AlarmItem.fromJson(Map<String, dynamic> json) => AlarmItem(
    id: json['id'],
    scheduledDateTime: DateTime.parse(json['time']),
    title: json['title'],
    body: json['body'],
  );
}

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final List<AlarmItem> _scheduledAlarms = [];

  static List<AlarmItem> getScheduledAlarms() =>
      List.unmodifiable(_scheduledAlarms);

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    await _loadSavedAlarms();
  }

  static Future<void> scheduleAlarm(
    DateTime dateTime, {
    required String title,
  }) async {
    final int alarmId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      '알람 채널',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notificationsPlugin.zonedSchedule(
      alarmId,
      title,
      '알람 시간입니다!',
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(android: androidDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    final alarm = AlarmItem(
      id: alarmId,
      scheduledDateTime: dateTime,
      title: title,
      body: '알람 시간입니다!',
    );

    _scheduledAlarms.add(alarm);
    await _saveAlarms();
  }

  static Future<void> cancelAlarm(int id) async {
    await _notificationsPlugin.cancel(id);
    _scheduledAlarms.removeWhere((alarm) => alarm.id == id);
    await _saveAlarms();
  }

  static Future<void> cancelAllAlarms() async {
    await _notificationsPlugin.cancelAll();
    _scheduledAlarms.clear();
    await _saveAlarms();
  }

  static Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        _scheduledAlarms.map((alarm) => jsonEncode(alarm.toJson())).toList();
    await prefs.setStringList('alarms', jsonList);
  }

  static Future<void> _loadSavedAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('alarms') ?? [];

    _scheduledAlarms.clear();
    _scheduledAlarms.addAll(
      jsonList.map((jsonStr) => AlarmItem.fromJson(jsonDecode(jsonStr))),
    );
  }
}
