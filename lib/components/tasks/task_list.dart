// components/tasks/task_list.dart
import 'package:flutter/material.dart';
import 'package:pass_log/models/task_model.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final String status;
  final Function(String, String) onUpdateStatus;
  final Function(String) onDelete;
  final Future<void> Function() onRefresh;

  const TaskList({
    super.key,
    required this.tasks,
    required this.status,
    required this.onUpdateStatus,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No $status tasks',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskItem(
            task: task,
            onUpdateStatus: (newStatus) => onUpdateStatus(task.id, newStatus),
            onDelete: onDelete,
          );
        },
      ),
    );
  }
}