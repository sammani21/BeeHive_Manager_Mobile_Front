import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pass_log/components/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/beekeeper_model.dart';
import '../models/product_model.dart';
import '../models/hive_model.dart';

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
      await _getBeekeeperFromSharedPreferences();
      if (beekeeper == null) {
        await _fetchBeekeeperData();
      }
      await _fetchProducts();
      await _fetchHives();
    } catch (error) {
      print('Error loading data: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getBeekeeperFromSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? beekeeperJson = prefs.getString('beekeeper');
      if (beekeeperJson != null) {
        final data = jsonDecode(beekeeperJson);
        setState(() {
          beekeeper = Beekeeper.fromJson(data);
        });
      }
    } catch (error) {
      print('Error getting beekeeper from shared preferences: $error');
    }
  }

  Future<void> _fetchBeekeeperData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/beekeepers/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          beekeeper = Beekeeper.fromJson(data['data']);
        });
        prefs.setString('beekeeper', json.encode(data['data']));
      } else {
        throw Exception('Failed to load beekeeper data');
      }
    } catch (error) {
      print('Error fetching beekeeper data: $error');
    }
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
        });
      } else {
        throw Exception('Failed to load hives');
      }
    } catch (error) {
      print('Error fetching hives: $error');
    }
  }

  Future<void> _fetchProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/product/my-products'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> productList = data['data'];
        setState(() {
          products = productList.map((json) => Product.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/hives');
        break;
      case 2:
        Navigator.pushNamed(context, '/insights');
        break;
      case 3:
        break;
    }
  }

  // ------------------- UI PARTS -------------------
  @override
  Widget _buildStatItem(String title, String value, IconData icon,
      {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color ?? Colors.amber[700], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color ?? Colors.amber[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    double totalProduction =
        products.fold(0, (sum, product) => sum + product.quantity);
    int productTypes = products.map((e) => e.productType).toSet().length;

    Map<String, double> productionByType = {};
    for (var product in products) {
      productionByType[product.productType] =
          (productionByType[product.productType] ?? 0) + product.quantity;
    }

    String mostProducedType = "None";
    double maxProduction = 0;
    productionByType.forEach((type, production) {
      if (production > maxProduction) {
        maxProduction = production;
        mostProducedType = type;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Production Overview",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.amber[800],
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
            double childAspectRatio = constraints.maxWidth > 600 ? 1.8 : 1.6;
            
            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              children: [
                _buildStatItem(
                    'Total Products', products.length.toString(), Icons.inventory),
                _buildStatItem(
                    'Product Types', productTypes.toString(), Icons.category),
                _buildStatItem(
                    'Total Production',
                    '${totalProduction.toStringAsFixed(2)} ${products.isNotEmpty ? products.first.unit : 'units'}',
                    Icons.agriculture),
                _buildStatItem(
                    'Most Produced', mostProducedType, Icons.emoji_events),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHiveStats() {
    int totalHives = hives.length;
    double avgStrength = hives.isEmpty
        ? 0
        : hives.map((hive) => hive.strength).reduce((a, b) => a + b) /
            hives.length;

    Map<String, int> hivesByType = {};
    for (var hive in hives) {
      hivesByType[hive.hiveType] = (hivesByType[hive.hiveType] ?? 0) + 1;
    }

    String mostCommonType = "None";
    int maxCount = 0;
    hivesByType.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonType = type;
      }
    });

    int strongestHive = hives.isEmpty
        ? 0
        : hives.map((hive) => hive.strength).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hive Overview",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.amber[800],
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
            double childAspectRatio = constraints.maxWidth > 600 ? 1.8 : 1.6;
            
            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              children: [
                _buildStatItem('Total Hives', totalHives.toString(), Icons.hive),
                _buildStatItem('Average Strength', avgStrength.toStringAsFixed(1),
                    Icons.auto_graph),
                _buildStatItem('Most Common Type', mostCommonType, Icons.category),
                _buildStatItem(
                    'Strongest Hive',
                    hives.isEmpty ? 'N/A' : '$strongestHive/10',
                    Icons.emoji_events),
                  
              ],
            );
          },
        ),
      ],
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
                    // Welcome card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber[800],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.amber.shade100,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            beekeeper?.name ?? "Beekeeper",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "You have ${hives.length} hives and ${products.length} products",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amber.shade100,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Hive Stats section
                    _buildHiveStats(),
                    const SizedBox(height: 24),

                    // Quick Stats section
                    _buildQuickStats(),
                    const SizedBox(height: 24),

                    // Quick actions
                    Text(
                      "Quick Actions",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.amber[800],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 600 ? 6 : 3;
                        double childAspectRatio = constraints.maxWidth > 600 ? 1.0 : 0.9;
                        
                        return GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: childAspectRatio,
                          ),
                          children: [
                            _quickActionButton(Icons.task, "Tasks", () {
                              Navigator.pushNamed(context, '/todo');
                            }),
                            _quickActionButton(Icons.bar_chart, "Reports", () {
                              Navigator.pushNamed(context, '/reports');
                            }),
                            _quickActionButton(Icons.lightbulb_outline, "Recommendations", () {
                              Navigator.pushNamed(context, '/recommendations');
                            }),
                            _quickActionButton(Icons.hive, "My Hives", () {
                              Navigator.pushNamed(context, '/hives');
                            }),
                            _quickActionButton(Icons.analytics, "Insights", () {
                              Navigator.pushNamed(context, '/insights');
                            }),
                            _quickActionButton(Icons.notifications, "Notifications", () {
                              Navigator.pushNamed(context, '/notifications');
                            }),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[800],
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }

  Widget _quickActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.amber[800]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[800],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
