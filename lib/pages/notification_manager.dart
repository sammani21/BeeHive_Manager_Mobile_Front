import 'dart:convert';

import 'notification_service.dart';
import 'notification_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationService _notificationService = NotificationService();
  NotificationPreferences? _preferences;

  Future<void> initialize() async {
    await _notificationService.initialize();
    await _loadPreferences();
    await _scheduleDailyNotification();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('notificationPreferences');
    
    _preferences = json != null
        ? NotificationPreferences.fromJson(jsonDecode(json))
        : NotificationPreferences();
  }

  Future<void> _scheduleDailyNotification() async {
    if (_preferences == null) await _loadPreferences();
    
    // Cancel existing notification
    await _notificationService.cancelNotification(1);
    
    // Only schedule if daily inspection is enabled
    if (_preferences!.dailyInspectionEnabled) {
      await _notificationService.scheduleDailyNotification(
        id: 1,
        title: 'Daily Hive Inspection',
        body: "Don't forget to inspect your hives today!",
        time: _preferences!.notificationTime,
      );
    }
  }

  Future<void> markInspectionDone() async {
    if (_preferences == null) await _loadPreferences();
    
    // Update the last inspection date
    _preferences!.lastInspectionDate = DateTime.now();
    
    await _savePreferences();
    
    // Cancel any pending notification for today
    await _notificationService.cancelNotification(1);
  }

  Future<bool> shouldShowNotification() async {
    if (_preferences == null) await _loadPreferences();
    return _preferences!.shouldShowNotification;
  }

  Future<void> refreshNotifications() async {
    await _scheduleDailyNotification();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'notificationPreferences',
      jsonEncode(_preferences!.toJson()),
    );
  }
}

// Helper method to get the notification manager instance
NotificationManager getNotificationManager() => NotificationManager();