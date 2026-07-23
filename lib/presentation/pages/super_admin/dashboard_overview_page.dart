import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/super_admin_stores_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import '../../widgets/admin/stores/store_statistics_cards.dart';

class DashboardOverviewPage extends StatelessWidget {
  const DashboardOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SuperAdminStoresProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TranslationKeys.superAdminDashboard.tr(context),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              StoreStatisticsCards(
                totalStores: provider.totalStores,
                activeStores: provider.activeStores,
                inactiveStores: provider.inactiveStores,
              ),
            ],
          ),
        );
      },
    );
  }
}
