// home_page.dart
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Try to get beekeeper from shared preferences first
      beekeeper = await SharedPrefsService.getBeekeeper();
      
      // If not in shared preferences, fetch from API
      if (beekeeper == null) {
        beekeeper = await ApiService.fetchBeekeeperData();
        if (beekeeper != null) {
          await SharedPrefsService.saveBeekeeper(beekeeper!);
        }
      }
      
      // Fetch hives and products in parallel
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
                    WelcomeCard(
                      beekeeper: beekeeper,
                      hiveCount: hives.length,
                      productCount: products.length,
                    ),
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