// components/reports/hive_report.dart
import 'package:flutter/material.dart';
import 'package:pass_log/models/hive_model.dart';
import 'package:pass_log/utils/report_utils.dart';

import 'empty_state.dart';

class HiveReport extends StatelessWidget {
  final List<Hive> hives;

  const HiveReport({super.key, required this.hives});

  @override
  Widget build(BuildContext context) {
    if (hives.isEmpty) {
      return EmptyState(
        icon: Icons.hive,
        message: 'No hive data available',
        subtitle: 'Try adding data or check your connection',
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
                    rows: hives.map((hive) {
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
                                  color: ReportUtils.getStrengthColor(hive.strength),
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
                                ReportUtils.getHiveStatus(hive.strength),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: ReportUtils.getStatusColor(hive.strength),
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
}