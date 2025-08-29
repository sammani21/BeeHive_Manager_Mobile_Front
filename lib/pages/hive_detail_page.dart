// pages/hive_detail_page.dart
import 'package:flutter/material.dart';
import '../models/hive_model.dart';
import 'package:pass_log/pages/add_edit_hive_page.dart';

class HiveDetailPage extends StatelessWidget {
  final Hive hive;

  const HiveDetailPage({super.key, required this.hive});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hive.hiveName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddHivePage(hive: hive),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard(context, [
                  _buildDetailItem(Icons.label, 'Hive Name', hive.hiveName),
                  _buildDetailItem(Icons.category, 'Hive Type', hive.hiveType),
                  _buildDetailItem(Icons.calendar_today, 'Installation Date',
                      hive.installationDate.toString()),
                  _buildDetailItem(Icons.search, 'Last Inspection',
                      hive.lastInspection.toString()),
                ]),
                _buildInfoCard(context, [
                  _buildDetailItem(Icons.group, 'Population',
                      hive.population.toString()),
                  _buildDetailItem(Icons.bug_report, 'Pest Level',
                      hive.pestLevel.toString()),
                  _buildDetailItem(Icons.emoji_emotions, 'Strength',
                      hive.strength.toString()),
                  _buildDetailItem(
                      Icons.female, 'Queen Status', hive.queenStatus),
                  _buildDetailItem(Icons.apps, 'Brood Pattern',
                      hive.broodPattern),
                  _buildDetailItem(Icons.emoji_food_beverage, 'Honey Stores',
                      hive.honeyStores.toString()),
                  _buildDetailItem(Icons.location_on, 'Location', hive.location),
                ]),
                _buildExpandableSection(
                  title: "Disease Signs",
                  icon: Icons.medical_services,
                  children: hive.diseaseSigns
                      .map((sign) => ListTile(
                            leading: const Icon(Icons.warning, color: Colors.red),
                            title: Text(sign),
                          ))
                      .toList(),
                ),
                _buildExpandableSection(
                  title: "Treatments",
                  icon: Icons.healing,
                  children: hive.treatments
                      .map((treatment) => ListTile(
                            leading: const Icon(Icons.medication),
                            title: Text(treatment.treatmentType),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date: ${treatment.applicationDate}"),
                                Text("Notes: ${treatment.notes}"),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Card wrapper for grouping related details
  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: children
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: e,
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Single detail row with icon
  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: "$title: ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Expandable section for long lists (disease/treatments)
  Widget _buildExpandableSection(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 12),
        children: children,
      ),
    );
  }
}
