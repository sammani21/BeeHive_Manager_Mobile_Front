import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/hive_model.dart';
import '../models/product_model.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedReport = 'Hive Report';
  final List<String> _reportTypes = [
    'Hive Report',
    'Product Report',
    'Recommendation Report',
    'Production Summary',
    'Financial Report'
  ];

  List<Hive> _hives = [];
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHives();
    _fetchProducts();
  }

  Future<void> _fetchHives() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/hive/my-hives'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          _hives = data.map((json) => Hive.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load hives');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/v1/product/my-products'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> productList = data['data'];
        setState(() {
          _products = productList.map((json) => Product.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber[700],
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, size: 26),
            onPressed: _generateAndSavePdf,
            tooltip: 'Download Report',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report type selector
                _buildReportSelector(),
                
                // Summary cards
                if (_selectedReport == 'Hive Report' && _hives.isNotEmpty) 
                  _buildHiveSummaryCards(),
                if (_selectedReport == 'Product Report' && _products.isNotEmpty)
                  _buildProductSummaryCards(),
                
                // Report content
                Expanded(child: _buildReportContent()),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading report data...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedReport,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
          elevation: 8,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          items: _reportTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() => _selectedReport = newValue!);
          },
        ),
      ),
    );
  }

  Widget _buildHiveSummaryCards() {
    final avgStrength = _hives.map((h) => h.strength).reduce((a, b) => a + b) / _hives.length;
    final strongHives = _hives.where((hive) => hive.strength >= 7).length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              title: 'Total Hives',
              value: _hives.length.toString(),
              icon: Icons.hive,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              title: 'Avg Strength',
              value: avgStrength.toStringAsFixed(1),
              icon: Icons.auto_graph,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              title: 'Strong Hives',
              value: strongHives.toString(),
              icon: Icons.health_and_safety,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSummaryCards() {
    final totalWeight = _products.map((p) => p.quantity).reduce((a, b) => a + b);
    final avgWeight = totalWeight / _products.length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              title: 'Total Products',
              value: _products.length.toString(),
              icon: Icons.inventory,
              color: Colors.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              title: 'Total Weight',
              value: '${totalWeight.toStringAsFixed(1)} ${_products.isNotEmpty ? _products.first.unit : ''}',
              icon: Icons.scale,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              title: 'Avg Weight',
              value: '${avgWeight.toStringAsFixed(1)} ${_products.isNotEmpty ? _products.first.unit : ''}',
              icon: Icons.bar_chart,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    switch (_selectedReport) {
      case 'Hive Report':
        return _buildHiveReport();
      case 'Product Report':
        return _buildProductReport();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Select a report type to view data',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildHiveReport() {
    if (_hives.isEmpty) {
      return _buildEmptyState(
        icon: Icons.hive,
        message: 'No hive data available',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hive Status Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Detailed overview of all your hives',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    headingRowColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => Colors.amber[50]!,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Hive Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Strength',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Location',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: _hives.map((hive) {
                      return DataRow(
                        cells: [
                          DataCell(Text(hive.hiveName)),
                          DataCell(Text(hive.hiveType)),
                          DataCell(
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_graph,
                                  size: 16,
                                  color: _getStrengthColor(hive.strength),
                                ),
                                const SizedBox(width: 4),
                                Text(hive.strength.toString()),
                              ],
                            ),
                          ),
                          DataCell(Text(hive.location)),
                          DataCell(
                            Chip(
                              label: Text(
                                _getHiveStatus(hive.strength),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _getStatusColor(hive.strength),
                              //labelColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductReport() {
    if (_products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory,
        message: 'No product data available',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Inventory Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Overview of your harvested products',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    headingRowColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => Colors.amber[50]!,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Product',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Quantity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Harvest Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: _products.map((product) {
                      return DataRow(
                        cells: [
                          DataCell(Text(product.productName)),
                          DataCell(Text(product.productType)),
                          DataCell(Text('${product.quantity} ${product.unit}')),
                          DataCell(Text(DateFormat('yyyy-MM-dd').format(product.harvestDate))),
                          DataCell(
                            Chip(
                              label: Text(
                                _getProductStatus(product.harvestDate),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _getProductStatusColor(product.harvestDate),
                              //labelColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adding data or check your connection',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor(int strength) {
    if (strength >= 8) return Colors.green;
    if (strength >= 5) return Colors.orange;
    return Colors.red;
  }

  String _getHiveStatus(int strength) {
    if (strength >= 8) return 'Strong';
    if (strength >= 5) return 'Moderate';
    return 'Weak';
  }

  Color _getStatusColor(int strength) {
    if (strength >= 8) return Colors.green;
    if (strength >= 5) return Colors.orange;
    return Colors.red;
  }

  String _getProductStatus(DateTime harvestDate) {
    final now = DateTime.now();
    final difference = now.difference(harvestDate).inDays;
    
    if (difference < 30) return 'Fresh';
    if (difference < 90) return 'Aging';
    return 'Mature';
  }

  Color _getProductStatusColor(DateTime harvestDate) {
    final now = DateTime.now();
    final difference = now.difference(harvestDate).inDays;
    
    if (difference < 30) return Colors.green;
    if (difference < 90) return Colors.orange;
    return Colors.purple;
  }

  Future<void> _generateAndSavePdf() async {
    final pdf = pw.Document();
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(now);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'BeeHive Manager - $_selectedReport',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Generated on: $formattedDate'),
              pw.SizedBox(height: 20),
              _buildPdfContent(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfContent() {
    switch (_selectedReport) {
      case 'Hive Report':
        return pw.TableHelper.fromTextArray(
          data: <List<String>>[
            <String>['Hive Name', 'Type', 'Strength', 'Location'],
            ..._hives.map((hive) => [hive.hiveName, hive.hiveType, hive.strength.toString(), hive.location]),
          ],
        );
      case 'Product Report':
        return pw.TableHelper.fromTextArray(
          data: <List<String>>[
            <String>['Product', 'Type', 'Quantity', 'Date'],
            ..._products.map((product) => [
                  product.productName,
                  product.productType,
                  '${product.quantity} ${product.unit}',
                  DateFormat('yyyy-MM-dd').format(product.harvestDate),
                ]),
          ],
        );
      default:
        return pw.Text('Report content for $_selectedReport');
    }
  }
}