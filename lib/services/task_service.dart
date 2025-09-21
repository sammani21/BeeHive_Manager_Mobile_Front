// services/task_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pass_log/models/task_model.dart';
import '../constants.dart';

class TaskService {
  static Future<List<Task>> fetchTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication expired. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$apiBaseUrl/tasks/my-tasks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> taskList = data['data'];
        return taskList.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching tasks: $error');
    }
  }

  static Future<void> addTask({
    required String title,
    required String description,
    required DateTime? dueDate,
    required String status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication expired. Please log in again.');
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/tasks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'dueDate': dueDate?.toIso8601String(),
          'status': status,
        }),
      );

      if (response.statusCode != 201) {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ?? 'Failed to add task';
        throw Exception(errorMessage);
      }
    } catch (error) {
      throw Exception('Error adding task: $error');
    }
  }

  static Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.patch(
        Uri.parse('$apiBaseUrl/tasks/$taskId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error updating task: $error');
    }
  }

  static Future<void> deleteTask(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('$apiBaseUrl/tasks/$taskId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error deleting task: $error');
    }
  }
}