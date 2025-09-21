// pages/insights_page.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

import '../models/product_model.dart';
import '../services/insights_service.dart';
import '../utils/insights_utils.dart';
import '../components/insights/marketing_tip_card.dart';
import '../components/insights/production_chart.dart';
import '../components/insights/stat_cards.dart';
import '../components/insights/production_history.dart';
import '../components/insights/report_preview.dart';
import 'add_product_page.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  List<Product> products = [];
  bool isLoading = true;
  String? errorMessage;
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
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      final fetchedProducts = await InsightsService.fetchProducts();
      final marketingData = InsightsUtils.generateMarketingTip(fetchedProducts);
      
      setState(() {
        products = fetchedProducts;
        marketingTip = marketingData['tip'];
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
        ),
      );
    }
  }

  Future<void> _downloadReport() async {
    try {
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

      final response = await InsightsService.downloadReport(selectedMonth, selectedYear);

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
                        'Failed to load insights',
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
                        onPressed: _fetchProducts,
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
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          // Marketing Tip Card
                          Container(
                            margin: const EdgeInsets.all(16),
                            child: MarketingTipCard(marketingTip: marketingTip),
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
                                                    ? ProductionChart(products: products)
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
                                              if (products.isNotEmpty) StatCards(products: products),
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
                                                      ? ProductionChart(products: products)
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
                                                if (products.isNotEmpty) StatCards(products: products),
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
                                child: ProductionHistory(products: products),
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
                                      : RepaintBoundary(
                                          key: previewContainer,
                                          child: ReportPreview(products: products),
                                        ),
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
          MaterialPageRoute(builder: (context) => const AddProductPage()),
        ).then((_) => _fetchProducts()),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}