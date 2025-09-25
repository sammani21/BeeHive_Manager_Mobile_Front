import 'package:flutter/material.dart';

class NotificationPreferences {
  bool dailyInspectionEnabled;
  TimeOfDay notificationTime;
  DateTime? lastInspectionDate;

  NotificationPreferences({
    this.dailyInspectionEnabled = true,
    this.notificationTime = const TimeOfDay(hour: 9, minute: 0),
    this.lastInspectionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyInspectionEnabled': dailyInspectionEnabled,
      'notificationTimeHour': notificationTime.hour,
      'notificationTimeMinute': notificationTime.minute,
      'lastInspectionDate': lastInspectionDate?.toIso8601String(),
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      dailyInspectionEnabled: json['dailyInspectionEnabled'] ?? true,
      notificationTime: TimeOfDay(
        hour: json['notificationTimeHour'] ?? 9,
        minute: json['notificationTimeMinute'] ?? 0,
      ),
      lastInspectionDate: json['lastInspectionDate'] != null 
          ? DateTime.parse(json['lastInspectionDate'])
          : null,
    );
  }

  bool get shouldShowNotification {
    // First check if daily inspection is enabled
    if (!dailyInspectionEnabled) return false;
    
    // If no inspection has ever been done, show notification
    if (lastInspectionDate == null) return true;
    
    // Check if inspection was done today
    final now = DateTime.now();
    final lastDate = DateTime(
      lastInspectionDate!.year,
      lastInspectionDate!.month,
      lastInspectionDate!.day,
    );
    final currentDate = DateTime(now.year, now.month, now.day);
    
    // Show notification if last inspection was before today
    return lastDate.isBefore(currentDate);
  }
}