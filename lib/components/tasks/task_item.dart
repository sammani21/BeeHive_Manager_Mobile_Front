// components/tasks/task_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pass_log/models/task_model.dart';
import 'package:pass_log/utils/task_utils.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(String) onUpdateStatus;
  final Function(String) onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(task.description),
              ),
            if (task.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Due: ${DateFormat.yMMMd().format(task.dueDate!)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  TaskUtils.getStatusText(task.status),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: TaskUtils.getStatusColor(task.status),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.status != 'done')
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () {
                  final newStatus = TaskUtils.getNextStatus(task.status);
                  onUpdateStatus(newStatus);
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => onDelete(task.id),
            ),
          ],
        ),
      ),
    );
  }
}