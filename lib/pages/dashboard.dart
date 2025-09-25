import 'package:flutter/material.dart';
import 'package:pass_log/components/bottom_nav_bar.dart';
import 'package:pass_log/models/beekeeper_model.dart';
import 'package:pass_log/models/product_model.dart';
import 'package:pass_log/models/hive_model.dart';

import '../services/api_service.dart';
import '../services/shared_prefs_service.dart';
import '../components/dashboard/welcome_card.dart';
import '../components/dashboard/hive_stats_grid.dart';
import '../components/dashboard/production_stats_grid.dart';
import '../components/dashboard/quick_actions_grid.dart';
import 'notification_manager.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  Beekeeper? beekeeper;
  List<Hive> hives = [];
  List<Product> products = [];
  bool isLoading = true;
  bool showInspectionNotification = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkNotificationStatus();
  }

  Future<void> _loadData() async {
    try {
      beekeeper = await SharedPrefsService.getBeekeeper();
      
      if (beekeeper == null) {
        beekeeper = await ApiService.fetchBeekeeperData();
        if (beekeeper != null) {
          await SharedPrefsService.saveBeekeeper(beekeeper!);
        }
      }
      
      final results = await Future.wait([
        ApiService.fetchHives(),
        ApiService.fetchProducts(),
      ]);
      
      setState(() {
        hives = (results[0] as List).cast<Hive>();
        products = (results[1] as List).cast<Product>();
      });
    } catch (error) {
      _showErrorSnackbar('Error loading data: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkNotificationStatus() async {
    final shouldShow = await getNotificationManager().shouldShowNotification();
    setState(() {
      showInspectionNotification = shouldShow;
    });
  }

  Future<void> _markInspectionDone() async {
    await getNotificationManager().markInspectionDone();
    setState(() {
      showInspectionNotification = false;
    });
    _showSuccessSnackbar('Inspection marked as completed!');
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    final routes = {
      1: '/hives',
      2: '/insights',
    };
    
    if (routes.containsKey(index)) {
      Navigator.pushNamed(context, routes[index]!);
    }
  }

  Widget _buildInspectionNotification() {
    if (!showInspectionNotification) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.amber[800], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Hive Inspection',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Time to inspect your hives for today',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _markInspectionDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
  // Welcome Card first
  WelcomeCard(
    beekeeper: beekeeper,
    hiveCount: hives.length,
    productCount: products.length,
  ),
  
  const SizedBox(height: 16), // Optional spacing
  
  // Inspection Notification Card after welcome card
  _buildInspectionNotification(),
  
  const SizedBox(height: 24),
  HiveStatsGrid(hives: hives),
  const SizedBox(height: 24),
  ProductionStatsGrid(products: products),
  const SizedBox(height: 24),
  const QuickActionsGrid(),
],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[800],
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}