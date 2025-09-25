// utils/task_utils.dart
import 'package:flutter/material.dart';

class TaskUtils {
  static Color getStatusColor(String status) {
    switch (status) {
      case 'todo':
        return Colors.redAccent;
      case 'inProgress':
        return Colors.blueAccent;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(String status) {
    switch (status) {
      case 'todo':
        return 'TO DO';
      case 'inProgress':
        return 'IN PROGRESS';
      case 'done':
        return 'DONE';
      default:
        return 'UNKNOWN';
    }
  }

  static String getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'todo':
        return 'inProgress';
      case 'inProgress':
        return 'done';
      default:
        return currentStatus;
    }
  }
}