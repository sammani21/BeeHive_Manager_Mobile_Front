import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin localNotifications;
  late AndroidNotificationDetails androidDetails;
  late DarwinNotificationDetails iosDetails;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    
    localNotifications = FlutterLocalNotificationsPlugin();
    
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    
    await localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: onSelectNotification,
    );
    
    androidDetails = const AndroidNotificationDetails(
      'beekeeper_channel',
      'Beekeeper Notifications',
      channelDescription: 'Notifications for hive management',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    
    iosDetails = const DarwinNotificationDetails();
  }

  void onSelectNotification(NotificationResponse response) {
    // Handle notification tap if needed
  }

  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // If the time has already passed today, schedule for next week
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    await localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> scheduleMonthlyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      1, // First day of month
      time.hour,
      time.minute,
    );
    
    // If the time has already passed this month, schedule for next month
    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.month == 12 ? now.year + 1 : now.year,
        now.month == 12 ? 1 : now.month + 1,
        1,
        time.hour,
        time.minute,
      );
    }
    
    await localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> cancelNotification(int id) async {
    await localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await localNotifications.cancelAll();
  }

  scheduleDailyNotification({required int id, required String title, required String body, required TimeOfDay time}) {}
}