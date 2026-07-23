import 'package:flutter/material.dart';

class StoreStatisticsCards extends StatelessWidget {
  final int totalStores;
  final int activeStores;
  final int inactiveStores;

  const StoreStatisticsCards({
    super.key,
    required this.totalStores,
    required this.activeStores,
    required this.inactiveStores,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(context, 'Total Stores', totalStores.toString(), Icons.store),
        const SizedBox(width: 16),
        _buildStatCard(context, 'Active Stores', activeStores.toString(), Icons.check_circle),
        const SizedBox(width: 16),
        _buildStatCard(context, 'Inactive Stores', inactiveStores.toString(), Icons.cancel),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
