// pages/hives_page.dart
import 'package:flutter/material.dart';
import 'package:pass_log/pages/add_edit_hive_page.dart';
import 'package:pass_log/pages/hive_detail_page.dart';
import 'package:pass_log/services/hives_service.dart';
import 'package:pass_log/utils/hive_utils.dart';

import '../components/hives/hives_summary.dart';
import '../components/hives/responsive_hive_grid.dart';
import '../components/hives/empty_hives_state.dart';
import '../models/hive_model.dart';

class HivesPage extends StatefulWidget {
  const HivesPage({super.key});

  @override
  State<HivesPage> createState() => _HivesPageState();
}

class _HivesPageState extends State<HivesPage> {
  List<Hive> hives = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHives();
  }

  Future<void> _fetchHives() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      final fetchedHives = await HiveService.fetchHives();
      
      setState(() {
        hives = fetchedHives;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToAddHive() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHivePage()),
    ).then((_) => _fetchHives());
  }

  void _navigateToHiveDetail(Hive hive) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HiveDetailPage(hive: hive),
      ),
    ).then((_) => _fetchHives());
  }

  @override
  Widget build(BuildContext context) {
    final stats = HiveUtils.calculateHiveStats(hives);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Hives',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: _navigateToAddHive,
            tooltip: 'Add New Hive',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _fetchHives,
            tooltip: 'Refresh Hives',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  strokeWidth: 4,
                ),
              )
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
                        Text(
                          'Failed to load hives',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _fetchHives,
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
                      if (hives.isNotEmpty) 
                        HivesSummary(stats: stats),
                      
                      Expanded(
                        child: hives.isEmpty
                            ? EmptyHivesState(onAddHive: _navigateToAddHive)
                            : RefreshIndicator(
                                onRefresh: _fetchHives,
                                color: Colors.amber[700],
                                child: ResponsiveHiveGrid(
                                  hives: hives,
                                  onHiveTap: _navigateToHiveDetail,
                                ),
                              ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: hives.isNotEmpty
          ? FloatingActionButton(
              onPressed: _navigateToAddHive,
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
    );
  }
}