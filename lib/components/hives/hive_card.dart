// components/hives/hive_card.dart
import 'package:flutter/material.dart';
import 'package:pass_log/models/hive_model.dart';

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
        _buildHiveIcon(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHiveName(),
              const SizedBox(height: 4),
              _buildHiveType(),
              const SizedBox(height: 4),
              _buildLocation(),
              const SizedBox(height: 8),
              _buildStrengthIndicator(),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
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
            _buildHiveIcon(size: 50),
            const SizedBox(width: 16),
            Expanded(
              child: _buildHiveName(fontSize: 20),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTypeWithIcon(),
            const Spacer(),
            _buildLocationWithIcon(),
          ],
        ),
        const SizedBox(height: 12),
        _buildStrengthIndicator(showLabel: true),
      ],
    );
  }

  Widget _buildHiveIcon({double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFF9E58C),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.hive_outlined,
        size: size * 0.5,
        color: Colors.amber[700],
      ),
    );
  }

  Widget _buildHiveName({double fontSize = 18}) {
    return Text(
      hive.hiveName,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildHiveType() {
    return Text(
      hive.hiveType,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            hive.location,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeWithIcon() {
    return Row(
      children: [
        const Icon(
          Icons.category_outlined,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          hive.hiveType,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationWithIcon() {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hive.location,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthIndicator({bool showLabel = false}) {
    return Row(
      children: [
        if (showLabel)
          Text(
            'Strength:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        if (showLabel) const SizedBox(width: 12),
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
    );
  }
}