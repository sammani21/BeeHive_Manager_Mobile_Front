// pages/reports_page.dart
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/hive_model.dart';
import '../models/product_model.dart';
import '../services/report_service.dart';
import '../utils/report_utils.dart';
import '../components/reports/report_selector.dart';
import '../components/reports/summary_row.dart';
import '../components/reports/hive_report.dart';
import '../components/reports/product_report.dart';
import '../components/reports/empty_state.dart';
import '../components/reports/loading_state.dart';

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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final results = await Future.wait([
        ReportService.fetchHives(),
        ReportService.fetchProducts(),
      ]);
      
      setState(() {
        _hives = List<Hive>.from(results[0]);
        _products = List<Product>.from(results[1]);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'), 
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.amber[700],
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        foregroundColor: Colors.white,
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
          ? const LoadingState()
          : _errorMessage != null
              ? EmptyState(
                  icon: Icons.error_outline,
                  message: 'Failed to load data',
                  subtitle: _errorMessage,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report type selector
                    ReportSelector(
                      selectedReport: _selectedReport,
                      reportTypes: _reportTypes,
                      onReportChanged: (newValue) {
                        setState(() => _selectedReport = newValue);
                      },
                    ),
                    
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

  Widget _buildHiveSummaryCards() {
    final stats = ReportUtils.calculateHiveStats(_hives);
    
    return SummaryRow(
      cards: [
        {
          'title': 'Total Hives',
          'value': stats['total'].toString(),
          'icon': Icons.hive,
          'color': Colors.blue,
        },
        {
          'title': 'Strength',
          'value': stats['avgStrength'].toStringAsFixed(1),
          'icon': Icons.auto_graph,
          'color': Colors.green,
        },
        {
          'title': 'Strong Hives',
          'value': stats['strongHives'].toString(),
          'icon': Icons.health_and_safety,
          'color': Colors.amber,
        },
      ],
    );
  }

  Widget _buildProductSummaryCards() {
    final stats = ReportUtils.calculateProductStats(_products);
    final unit = _products.isNotEmpty ? _products.first.unit : '';
    
    return SummaryRow(
      cards: [
        {
          'title': 'Total',
          'value': stats['total'].toString(),
          'icon': Icons.inventory,
          'color': Colors.purple,
        },
        {
          'title': 'Total Weight',
          'value': '${stats['totalWeight'].toStringAsFixed(1)} $unit',
          'icon': Icons.scale,
          'color': Colors.orange,
        },
        {
          'title': 'Avg Weight',
          'value': '${stats['avgWeight'].toStringAsFixed(1)} $unit',
          'icon': Icons.bar_chart,
          'color': Colors.teal,
        },
      ],
    );
  }

  Widget _buildReportContent() {
    switch (_selectedReport) {
      case 'Hive Report':
        return HiveReport(hives: _hives);
      case 'Product Report':
        return ProductReport(products: _products);
      default:
        return EmptyState(
          icon: Icons.analytics,
          message: 'Select a report type to view data',
        );
    }
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