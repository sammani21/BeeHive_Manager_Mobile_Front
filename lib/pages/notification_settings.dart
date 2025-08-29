import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Notification Types'),
          _buildSwitchListTile(
            'Hive Inspection Reminders',
            'Weekly reminders to inspect your hives',
            preferences.hiveInspectionEnabled,
            (value) {
              setState(() {
                preferences.hiveInspectionEnabled = value;
              });
              _savePreferences();
            },
          ),
          _buildSwitchListTile(
            'Monthly Review Notifications',
            'Monthly reminders for full hive reviews',
            preferences.monthlyReviewEnabled,
            (value) {
              setState(() {
                preferences.monthlyReviewEnabled = value;
              });
              _savePreferences();
            },
          ),
          _buildSwitchListTile(
            'Queen Check Notifications',
            'Weekly reminders to check on your queens',
            preferences.queenCheckEnabled,
            (value) {
              setState(() {
                preferences.queenCheckEnabled = value;
              });
              _savePreferences();
            },
          ),
          _buildSwitchListTile(
            'Event-Based Notifications',
            'Recommendations when adding/updating hives',
            preferences.eventBasedEnabled,
            (value) {
              setState(() {
                preferences.eventBasedEnabled = value;
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
          _buildSectionHeader('Delivery Methods'),
          _buildDeliveryMethodCheckbox('In-App Notifications', 'inApp'),
          _buildDeliveryMethodCheckbox('Email', 'email'),
          _buildDeliveryMethodCheckbox('SMS', 'sms'),
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

  Widget _buildDeliveryMethodCheckbox(String title, String value) {
    return CheckboxListTile(
      title: Text(title),
      value: preferences.deliveryMethods.contains(value),
      onChanged: (bool? checked) {
        setState(() {
          if (checked == true) {
            preferences.deliveryMethods.add(value);
          } else {
            preferences.deliveryMethods.remove(value);
          }
        });
        _savePreferences();
      },
      activeColor: Colors.amber[800],
    );
  }
}