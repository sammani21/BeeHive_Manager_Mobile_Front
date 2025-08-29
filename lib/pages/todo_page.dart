import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pass_log/models/task_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/tasks/my-tasks'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> taskList = data['data'];
        setState(() {
          tasks = taskList.map((json) => Task.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (error) {
      print('Error fetching tasks: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addTask() async {
  try {
    // Validate input
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task title is required')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error. Please log in again.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final response = await http.post(
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
    ).timeout(const Duration(seconds: 10));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedDate = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task added successfully')),
      );
      _fetchTasks(); // Refresh the task list
    } else {
      // Try to parse error message from response
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String errorMessage = responseData['message'] ?? 'Failed to add task';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      throw Exception(errorMessage);
    }
  } on http.ClientException catch (e) {
    print('Network error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Network error. Please check your connection.')),
    );
  } on TimeoutException catch (e) {
    print('Request timeout: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request timeout. Please try again.')),
    );
  } on FormatException catch (e) {
    print('JSON format error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data format error. Please try again.')),
    );
  } catch (error) {
    print('Error adding task: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unexpected error. Please try again.')),
    );
  }
}

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.patch(
        Uri.parse('http://localhost:3000/api/v1/tasks/$taskId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        _fetchTasks(); // Refresh the task list
      } else {
        throw Exception('Failed to update task');
      }
    } catch (error) {
      print('Error updating task: $error');
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/v1/tasks/$taskId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _fetchTasks(); // Refresh the task list
      } else {
        throw Exception('Failed to delete task');
      }
    } catch (error) {
      print('Error deleting task: $error');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildTaskList(List<Task> tasks, String status) {
    List<Task> filteredTasks = tasks.where((task) => task.status == status).toList();
    
    if (filteredTasks.isEmpty) {
      return Center(
        child: Text(
          'No $status tasks',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        Task task = filteredTasks[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            title: Text(task.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description.isNotEmpty) Text(task.description),
                if (task.dueDate != null) 
                  Text('Due: ${DateFormat.yMd().format(task.dueDate!)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status != 'done')
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      String newStatus = status == 'todo' ? 'inProgress' : 'done';
                      _updateTaskStatus(task.id, newStatus);
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(task.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        backgroundColor: Colors.amber[800],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Add new task form
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'No due date'
                                  : 'Due: ${DateFormat.yMd().format(_selectedDate!)}',
                            ),
                          ),
                          TextButton(
                            onPressed: () => _selectDate(context),
                            child: Text('Set Due Date'),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _addTask,
                        child: Text('Add Task'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[800],
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
                        TabBar(
                          indicatorColor: Colors.amber[800],
                          labelColor: Colors.amber[800],
                          tabs: [
                            Tab(text: 'To Do (${tasks.where((t) => t.status == 'todo').length})'),
                            Tab(text: 'In Progress (${tasks.where((t) => t.status == 'inProgress').length})'),
                            Tab(text: 'Done (${tasks.where((t) => t.status == 'done').length})'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildTaskList(tasks, 'todo'),
                              _buildTaskList(tasks, 'inProgress'),
                              _buildTaskList(tasks, 'done'),
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