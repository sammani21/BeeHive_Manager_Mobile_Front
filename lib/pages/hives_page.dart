// pages/hives_page.dart
import 'package:flutter/material.dart';
import 'package:pass_log/pages/add_edit_hive_page.dart';
import 'package:pass_log/pages/hive_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/hive_model.dart';

class HivesPage extends StatefulWidget {
  const HivesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HivesPageState createState() => _HivesPageState();
}

class _HivesPageState extends State<HivesPage> {
  List<Hive> hives = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHives();
  }

  Future<void> _fetchHives() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/hive/my-hives'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          hives = data.map((json) => Hive.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load hives');
      }
    } catch (error) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Calculate hive statistics for the summary
  Map<String, dynamic> _calculateHiveStats() {
    if (hives.isEmpty) {
      return {
        'total': 0,
        'averageStrength': 0.0,
        'strongHives': 0,
        'weakHives': 0,
      };
    }

    double totalStrength = hives.fold(0, (sum, hive) => sum + hive.strength);
    double averageStrength = totalStrength / hives.length;
    int strongHives = hives.where((hive) => hive.strength > 7).length;
    int weakHives = hives.where((hive) => hive.strength <= 4).length;

    return {
      'total': hives.length,
      'averageStrength': averageStrength,
      'strongHives': strongHives,
      'weakHives': weakHives,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateHiveStats();
    
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddHivePage()),
            ).then((_) => _fetchHives()),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 255, 255, 255)!,
              const Color.fromARGB(255, 255, 255, 255)!,
            ],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  strokeWidth: 4,
                ),
              )
            : Column(
                children: [
                  // Summary Section
                  if (hives.isNotEmpty) 
                    HivesSummary(stats: stats),
                  
                  // Hives List/Grid
                  Expanded(
                    child: hives.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hive_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hives yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add your first hive',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AddHivePage()),
                                  ).then((_) => _fetchHives()),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Hive'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber[700],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchHives,
                            color: Colors.amber[700],
                            child: ResponsiveHiveGrid(
                              hives: hives,
                              onHiveTap: (hive) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HiveDetailPage(hive: hive),
                                ),
                              ).then((_) => _fetchHives()),
                            ),
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: hives.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddHivePage()),
              ).then((_) => _fetchHives()),
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

// Hives Summary Widget
class HivesSummary extends StatelessWidget {
  final Map<String, dynamic> stats;

  const HivesSummary({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            title: 'Total Hives',
            value: stats['total'].toString(),
            icon: Icons.hive_outlined,
            color: Colors.blue,
          ),
          _SummaryItem(
            title: 'Avg Strength',
            value: stats['total'] > 0 ? stats['averageStrength'].toStringAsFixed(1) : '0',
            icon: Icons.assessment_outlined,
            color: Colors.green,
          ),
          _SummaryItem(
            title: 'Strong Hives',
            value: stats['strongHives'].toString(),
            icon: Icons.thumb_up_outlined,
            color: Colors.green,
          ),
          _SummaryItem(
            title: 'Weak Hives',
            value: stats['weakHives'].toString(),
            icon: Icons.thumb_down_outlined,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// Responsive Grid/List View for Hives
class ResponsiveHiveGrid extends StatelessWidget {
  final List<Hive> hives;
  final Function(Hive) onHiveTap;

  const ResponsiveHiveGrid({
    super.key,
    required this.hives,
    required this.onHiveTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return isDesktop
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
            ),
            itemCount: hives.length,
            itemBuilder: (context, index) => HiveCard(
              hive: hives[index],
              onTap: () => onHiveTap(hives[index]),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hives.length,
            itemBuilder: (context, index) => HiveCard(
              hive: hives[index],
              onTap: () => onHiveTap(hives[index]),
            ),
          );
  }
}

class HiveCard extends StatelessWidget {
  final Hive hive;
  final VoidCallback onTap;

  const HiveCard({super.key, required this.hive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 249, 229, 140),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.hive_outlined,
            size: 32,
            color: Colors.amber[700],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hive.hiveName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                hive.hiveType,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      hive.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Strength:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: hive.strength / 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        hive.strength > 7
                            ? Colors.green
                            : hive.strength > 4
                                ? Colors.orange
                                : Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${hive.strength}/10',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey[500],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.amber[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hive_outlined,
                size: 28,
                color: Colors.amber[700],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                hive.hiveName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey[500],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.category_outlined,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              hive.hiveType,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hive.location,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Strength:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LinearProgressIndicator(
                value: hive.strength / 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  hive.strength > 7
                      ? Colors.green
                      : hive.strength > 4
                          ? Colors.orange
                          : Colors.red,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${hive.strength}/10',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}