import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pass_log/models/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Task> tasks = [];
  bool isLoading = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication expired. Please log in again.');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/tasks/my-tasks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> taskList = data['data'];
        setState(() {
          tasks = taskList.map((json) => Task.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        _showSnackBar('Failed to fetch tasks');
      }
    } catch (error) {
      debugPrint('Error fetching tasks: $error');
      _showSnackBar('Error fetching tasks. Please try again.');
    }
  }

  Future<void> _addTask() async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Task title is required');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication expired. Please log in again.');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http
          .post(
            Uri.parse('http://localhost:3000/api/v1/tasks'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'title': _titleController.text,
              'description': _descriptionController.text,
              'dueDate': _selectedDate?.toIso8601String(),
              'status': 'todo',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        _titleController.clear();
        _descriptionController.clear();
        setState(() => _selectedDate = null);

        _showSnackBar('Task added successfully');
        _fetchTasks();
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['message'] ?? 'Failed to add task';
        _showSnackBar(errorMessage);
      }
    } on TimeoutException {
      _showSnackBar('Request timed out. Please try again.');
    } catch (error) {
      debugPrint('Error adding task: $error');
      _showSnackBar('Error adding task. Please try again.');
    }
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.patch(
        Uri.parse('http://localhost:3000/api/v1/tasks/$taskId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        _fetchTasks();
      } else {
        _showSnackBar('Failed to update task');
      }
    } catch (error) {
      debugPrint('Error updating task: $error');
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/v1/tasks/$taskId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _fetchTasks();
        _showSnackBar('Task deleted');
      } else {
        _showSnackBar('Failed to delete task');
      }
    } catch (error) {
      debugPrint('Error deleting task: $error');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildTaskList(String status) {
    final filteredTasks =
        tasks.where((task) => task.status == status).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Text(
          'No $status tasks',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTasks,
      child: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        status.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: status == 'todo'
                          ? Colors.redAccent
                          : status == 'inProgress'
                              ? Colors.blueAccent
                              : Colors.green,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status != 'done')
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {
                        final newStatus =
                            status == 'todo' ? 'inProgress' : 'done';
                        _updateTaskStatus(task.id, newStatus);
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteTask(task.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
        //centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'No due date selected'
                                  : 'Due: ${DateFormat.yMMMd().format(_selectedDate!)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today,
                                color: Colors.amber),
                            label: const Text('Set Due Date'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[800],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add Task',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                              _buildTaskList('todo'),
                              _buildTaskList('inProgress'),
                              _buildTaskList('done'),
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
