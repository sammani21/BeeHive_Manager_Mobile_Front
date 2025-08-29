import 'dart:convert';

import 'package:flutter/material.dart';
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
    await _loadPreferences();
    await _scheduleAllNotifications();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('notificationPreferences');
    
    _preferences = json != null
        ? NotificationPreferences.fromJson(jsonDecode(json))
        : NotificationPreferences();
  }

  Future<void> _scheduleAllNotifications() async {
    if (_preferences == null) await _loadPreferences();
    
    // Cancel all existing notifications
    await _notificationService.cancelAllNotifications();
    
    // Schedule new notifications based on preferences
    if (_preferences!.hiveInspectionEnabled) {
      await _scheduleHiveInspectionNotifications();
    }
    
    if (_preferences!.queenCheckEnabled) {
      await _scheduleQueenCheckNotifications();
    }
    
    if (_preferences!.monthlyReviewEnabled) {
      await _scheduleMonthlyReviewNotifications();
    }
  }

  Future<void> _scheduleHiveInspectionNotifications() async {
    await _notificationService.scheduleWeeklyNotification(
      id: 1,
      title: 'Hive Inspection Reminder',
      body: "It's time to inspect your hives today.",
      time: _preferences!.notificationTime,
    );
  }

  Future<void> _scheduleQueenCheckNotifications() async {
    await _notificationService.scheduleWeeklyNotification(
      id: 2,
      title: 'Queen Check Reminder',
      body: "Reminder: Perform your weekly queen check on your hives.",
      time: _preferences!.notificationTime,
    );
  }

  Future<void> _scheduleMonthlyReviewNotifications() async {
    await _notificationService.scheduleMonthlyNotification(
      id: 3,
      title: 'Monthly Hive Review',
      body: "Today is your monthly hive checkup day.",
      time: _preferences!.notificationTime,
    );
  }

  Future<void> showHiveUpdateRecommendation(String hiveName, String recommendation) async {
    if (_preferences == null) await _loadPreferences();
    
    if (_preferences!.eventBasedEnabled && 
        _preferences!.deliveryMethods.contains('inApp')) {
      await _notificationService.showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Hive Update Recommendation',
        body: "You updated $hiveName. Recommendation: $recommendation",
      );
    }
  }

  Future<void> showNewHiveRecommendation(String hiveName, String recommendation) async {
    if (_preferences == null) await _loadPreferences();
    
    if (_preferences!.eventBasedEnabled && 
        _preferences!.deliveryMethods.contains('inApp')) {
      await _notificationService.showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'New Hive Recommendation',
        body: "New hive added: We recommend $recommendation for $hiveName",
      );
    }
  }

  Future<void> refreshNotifications() async {
    await _scheduleAllNotifications();
  }
}