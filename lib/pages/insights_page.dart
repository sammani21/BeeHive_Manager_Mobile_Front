import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'dart:html' as html;
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import '../models/product_model.dart';
import 'add_product_page.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  List<Product> products = [];
  bool isLoading = true;
  String marketingTip = "Analyzing your production data...";
  GlobalKey previewContainer = GlobalKey();
  bool isPreviewVisible = false;
  Uint8List? reportPreviewImage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
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
          isLoading = false;
          _generateMarketingTip();
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _generateMarketingTip() {
    if (products.isEmpty) {
      setState(() {
        marketingTip = "Add your first product to get marketing insights!";
      });
      return;
    }

    double totalProduction = products.fold(0, (sum, product) => sum + product.quantity);
    Map<int, double> monthlyProduction = {};
    
    for (var product in products) {
      int month = product.harvestDate.month;
      monthlyProduction[month] = (monthlyProduction[month] ?? 0) + product.quantity;
    }
    
    int peakMonth = 0;
    double maxProduction = 0;
    monthlyProduction.forEach((month, production) {
      if (production > maxProduction) {
        maxProduction = production;
        peakMonth = month;
      }
    });
    
    String monthName = DateFormat('MMMM').format(DateTime(2023, peakMonth, 1));
    
    setState(() {
      marketingTip = "Your production peaks in $monthName - consider increasing stock before this period. "
          "Total production: ${totalProduction.toStringAsFixed(2)} ${
          products.isNotEmpty ? products.first.unit : 'units'}";
    });
  }

  Future<void> _downloadReport() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      DateTime now = DateTime.now();
      DateTime? selected = await showMonthPicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2020),
        lastDate: now,
      );

      if (selected == null) return;

      int selectedMonth = selected.month;
      int selectedYear = selected.year;

      final uri = Uri.parse(
        'http://localhost:3000/api/v1/product/download-report?'
        'month=$selectedMonth&year=$selectedYear',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('application/pdf') == true) {
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..download = 'production_report_${selectedYear}_$selectedMonth.pdf'
          ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report for $selectedMonth/$selectedYear downloaded'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errMsg = response.body.isNotEmpty
            ? json.decode(response.body)['error'] ?? "Failed to download report"
            : "Failed to download report";
        throw Exception(errMsg);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateReportPreview() async {
    try {
      final boundary = previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final imageBytes = byteData!.buffer.asUint8List();

      setState(() {
        reportPreviewImage = imageBytes;
        isPreviewVisible = true;
      });
    } catch (e) {
      print('Error generating preview: $e');
    }
  }

  Widget _buildReportPreview() {
    return RepaintBoundary(
      key: previewContainer,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'PRODUCTION REPORT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const Divider(thickness: 2),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Production Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber[700],
              ),
            ),
            const SizedBox(height: 12),
            
            if (products.isNotEmpty) ..._buildSummaryCards(),
            
            const SizedBox(height: 24),
            
            Text(
              'Production by Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber[700],
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              height: 200,
              child: products.isNotEmpty 
                  ? _buildProductionChart()
                  : const Center(
                      child: Text('No production data available'),
                    ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Production Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber[700],
              ),
            ),
            const SizedBox(height: 12),
            
            ..._buildProductionDetails(),
            
            const SizedBox(height: 24),
            
            const Divider(thickness: 2),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Generated on: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'FarmInsights Pro',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSummaryCards() {
    double totalProduction = products.fold(0, (sum, product) => sum + product.quantity);
    int productTypes = products.map((e) => e.productType).toSet().length;
    
    Map<int, double> monthlyProduction = {};
    for (var product in products) {
      int month = product.harvestDate.month;
      monthlyProduction[month] = (monthlyProduction[month] ?? 0) + product.quantity;
    }
    
    int peakMonth = 0;
    double maxProduction = 0;
    monthlyProduction.forEach((month, production) {
      if (production > maxProduction) {
        maxProduction = production;
        peakMonth = month;
      }
    });
    
    String monthName = DateFormat('MMMM').format(DateTime(2023, peakMonth, 1));
    
    return [
      Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Production',
              '${totalProduction.toStringAsFixed(2)} ${products.isNotEmpty ? products.first.unit : 'units'}',
              Icons.agriculture,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Product Types',
              productTypes.toString(),
              Icons.category,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Peak Production Month',
              monthName,
              Icons.trending_up,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Products Listed',
              products.length.toString(),
              Icons.list,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[100]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProductionDetails() {
    if (products.isEmpty) {
      return [const Text('No production data available')];
    }
    
    return [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Quantity'), numeric: true),
            DataColumn(label: Text('Harvest Date')),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(Text(product.productName)),
                DataCell(Text(product.productType)),
                DataCell(Text('${product.quantity} ${product.unit}')),
                DataCell(Text(DateFormat('MMM d, yyyy').format(product.harvestDate))),
              ],
            );
          }).toList(),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isMediumScreen = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Marketing Insights',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 20 : 24,
          ),
        ),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: _generateReportPreview,
            tooltip: 'Preview Report',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadReport,
            tooltip: 'Download Report',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Marketing Tip Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Marketing Tip',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 16 : 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(marketingTip),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Chart and Statistics
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: isSmallScreen
                            ? Column(
                                children: [
                                  // Chart
                                  Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Production by Type',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: isSmallScreen ? 14 : 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 200,
                                            child: products.isNotEmpty 
                                                ? _buildProductionChart()
                                                : const Center(
                                                    child: Text('No production data available'),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Statistics
                                  Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Quick Stats',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: isSmallScreen ? 14 : 16,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          if (products.isNotEmpty) ..._buildStatCards(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Chart
                                  Expanded(
                                    flex: 2,
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Production by Type',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isMediumScreen ? 14 : 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 200,
                                              child: products.isNotEmpty 
                                                  ? _buildProductionChart()
                                                  : const Center(
                                                      child: Text('No production data available'),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 16),
                                  
                                  // Statistics
                                  Expanded(
                                    flex: 1,
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Quick Stats',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isMediumScreen ? 14 : 16,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            if (products.isNotEmpty) ..._buildStatCards(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      
                      // Production History
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Production History',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 16 : 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                products.isNotEmpty
                                    ? Column(
                                        children: products.map((product) => _buildProductItem(product)).toList(),
                                      )
                                    : const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text('No products yet'),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Report Preview Overlay
                if (isPreviewVisible) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isPreviewVisible = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {}, // Prevent closing when clicking on the preview
                          child: SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: reportPreviewImage != null
                                  ? Image.memory(reportPreviewImage!)
                                  : _buildReportPreview(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddProductPage()),
        ).then((_) => _fetchProducts()),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildStatCards() {
    double totalProduction = products.fold(0, (sum, product) => sum + product.quantity);
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
    
    return [
      _buildStatItem('Total Products', products.length.toString(), Icons.inventory),
      const SizedBox(height: 8),
      _buildStatItem('Product Types', productTypes.toString(), Icons.category),
      const SizedBox(height: 8),
      _buildStatItem('Total Production', '${totalProduction.toStringAsFixed(2)} ${products.isNotEmpty ? products.first.unit : 'units'}', Icons.agriculture),
      const SizedBox(height: 8),
      _buildStatItem('Most Produced', mostProducedType, Icons.emoji_events),
    ];
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber[700]),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[700])),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildProductionChart() {
    Map<String, double> productionByType = {};
    for (var product in products) {
      productionByType[product.productType] = 
          (productionByType[product.productType] ?? 0) + product.quantity;
    }
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: productionByType.isNotEmpty ? productionByType.values.reduce((a, b) => a > b ? a : b) * 1.2 : 100,
        barGroups: productionByType.entries.map((entry) {
          return BarChartGroupData(
            x: productionByType.keys.toList().indexOf(entry.key),
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.amber,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= productionByType.keys.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    productionByType.keys.toList()[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.agriculture, color: Colors.amber[700]),
        title: Text(
          product.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${product.quantity} ${product.unit} - ${DateFormat('MMM d, yyyy').format(product.harvestDate)}',
        ),
        trailing: Chip(
          label: Text(
            product.productType,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: Colors.amber[700],
        ),
      ),
    );
  }
}