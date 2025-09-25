import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationPreferences preferences;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('notificationPreferences');
    
    setState(() {
      preferences = json != null
          ? NotificationPreferences.fromJson(jsonDecode(json))
          : NotificationPreferences();
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'notificationPreferences',
      jsonEncode(preferences.toJson()),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: preferences.notificationTime,
    );
    
    if (picked != null) {
      setState(() {
        preferences.notificationTime = picked;
      });
      await _savePreferences();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Daily Hive Inspection'),
          _buildSwitchListTile(
            'Daily Inspection Reminders',
            'Receive daily reminders to inspect your hives',
            preferences.dailyInspectionEnabled,
            (value) {
              setState(() {
                preferences.dailyInspectionEnabled = value;
              });
              _savePreferences();
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Notification Time'),
          ListTile(
            title: const Text('Daily Notification Time'),
            subtitle: Text(
              '${preferences.notificationTime.format(context)}',
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectTime(context),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Last Inspection'),
          ListTile(
            title: const Text('Last Inspection Completed'),
            subtitle: Text(
              preferences.lastInspectionDate != null
                  ? '${preferences.lastInspectionDate!.day}/${preferences.lastInspectionDate!.month}/${preferences.lastInspectionDate!.year}'
                  : 'Never',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  preferences.lastInspectionDate = null;
                });
                _savePreferences();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
      ),
    );
  }

  Widget _buildSwitchListTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.amber[800],
    );
  }
}