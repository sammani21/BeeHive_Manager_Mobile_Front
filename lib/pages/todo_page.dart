// pages/todo_page.dart
import 'package:flutter/material.dart';
import 'package:pass_log/services/task_service.dart';
import 'package:pass_log/models/task_model.dart';
import 'package:pass_log/components/tasks/add_task_form.dart';
import 'package:pass_log/components/tasks/task_list.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Task> tasks = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final fetchedTasks = await TaskService.fetchTasks();
      setState(() {
        tasks = fetchedTasks;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
      
      if (error.toString().contains('Authentication expired')) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnackBar('Error fetching tasks. Please try again.');
      }
    }
  }

  Future<void> _addTask({
    required String title,
    required String description,
    required DateTime? dueDate,
  }) async {
    try {
      await TaskService.addTask(
        title: title,
        description: description,
        dueDate: dueDate,
        status: 'todo',
      );

      _showSnackBar('Task added successfully');
      _fetchTasks();
    } catch (error) {
      if (error.toString().contains('Authentication expired')) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnackBar('Error adding task. Please try again.');
      }
    }
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      await TaskService.updateTaskStatus(taskId, newStatus);
      _fetchTasks();
    } catch (error) {
      if (error.toString().contains('Authentication expired')) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnackBar('Failed to update task');
      }
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await TaskService.deleteTask(taskId);
      _fetchTasks();
      _showSnackBar('Task deleted');
    } catch (error) {
      if (error.toString().contains('Authentication expired')) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnackBar('Failed to delete task');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Manager',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load tasks',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchTasks,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    AddTaskForm(onAddTask: _addTask),
                    Expanded(
                      child: DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            Container(
                              color: Colors.grey[200],
                              child: TabBar(
                                indicatorColor: Colors.amber[800],
                                labelColor: Colors.amber[800],
                                unselectedLabelColor: Colors.black54,
                                labelStyle:
                                    const TextStyle(fontWeight: FontWeight.bold),
                                tabs: [
                                  Tab(
                                    icon: const Icon(Icons.list),
                                    text:
                                        'To Do (${tasks.where((t) => t.status == 'todo').length})',
                                  ),
                                  Tab(
                                    icon: const Icon(Icons.work),
                                    text:
                                        'In Progress (${tasks.where((t) => t.status == 'inProgress').length})',
                                  ),
                                  Tab(
                                    icon: const Icon(Icons.done_all),
                                    text:
                                        'Done (${tasks.where((t) => t.status == 'done').length})',
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  TaskList(
                                    tasks: tasks.where((t) => t.status == 'todo').toList(),
                                    status: 'todo',
                                    onUpdateStatus: _updateTaskStatus,
                                    onDelete: _deleteTask,
                                    onRefresh: _fetchTasks,
                                  ),
                                  TaskList(
                                    tasks: tasks.where((t) => t.status == 'inProgress').toList(),
                                    status: 'inProgress',
                                    onUpdateStatus: _updateTaskStatus,
                                    onDelete: _deleteTask,
                                    onRefresh: _fetchTasks,
                                  ),
                                  TaskList(
                                    tasks: tasks.where((t) => t.status == 'done').toList(),
                                    status: 'done',
                                    onUpdateStatus: _updateTaskStatus,
                                    onDelete: _deleteTask,
                                    onRefresh: _fetchTasks,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}