import 'package:flutter/material.dart';

class NotificationPreferences {
  bool hiveInspectionEnabled;
  bool monthlyReviewEnabled;
  bool queenCheckEnabled;
  bool eventBasedEnabled;
  TimeOfDay notificationTime;
  List<String> deliveryMethods; // 'inApp', 'email', 'sms'

  NotificationPreferences({
    this.hiveInspectionEnabled = true,
    this.monthlyReviewEnabled = true,
    this.queenCheckEnabled = true,
    this.eventBasedEnabled = true,
    this.notificationTime = const TimeOfDay(hour: 9, minute: 0),
    this.deliveryMethods = const ['inApp'],
  });

  Map<String, dynamic> toJson() {
    return {
      'hiveInspectionEnabled': hiveInspectionEnabled,
      'monthlyReviewEnabled': monthlyReviewEnabled,
      'queenCheckEnabled': queenCheckEnabled,
      'eventBasedEnabled': eventBasedEnabled,
      'notificationTimeHour': notificationTime.hour,
      'notificationTimeMinute': notificationTime.minute,
      'deliveryMethods': deliveryMethods,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      hiveInspectionEnabled: json['hiveInspectionEnabled'] ?? true,
      monthlyReviewEnabled: json['monthlyReviewEnabled'] ?? true,
      queenCheckEnabled: json['queenCheckEnabled'] ?? true,
      eventBasedEnabled: json['eventBasedEnabled'] ?? true,
      notificationTime: TimeOfDay(
        hour: json['notificationTimeHour'] ?? 9,
        minute: json['notificationTimeMinute'] ?? 0,
      ),
      deliveryMethods: List<String>.from(json['deliveryMethods'] ?? ['inApp']),
    );
  }
}