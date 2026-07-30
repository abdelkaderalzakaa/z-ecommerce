import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/company/company_settings_model.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class OverviewTab extends StatelessWidget {
  final CompanySettingsModel store;

  const OverviewTab({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalOrders = store.orders ?? 0;
    final totalFollowers = store.followers ?? 0;
    final totalVisitors = store.visitor ?? 0;
    final rating = store.rate.toStringAsFixed(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.overviewTab.tr(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Metric Cards Row
          Row(
            children: [
              _buildMetricCard(
                context,
                TranslationKeys.ordersCount.tr(context),
                '$totalOrders',
                Icons.shopping_bag_rounded,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                context,
                TranslationKeys.visits.tr(context),
                '$totalVisitors',
                Icons.visibility_rounded,
                Colors.purple,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                context,
                'المتابعون',
                '$totalFollowers',
                Icons.people_rounded,
                Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                context,
                TranslationKeys.rating.tr(context),
                '⭐ $rating',
                Icons.star_rounded,
                Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Analytics Overview Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TranslationKeys.salesOverview.tr(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.analytics_rounded, color: theme.primaryColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.08),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 48,
                            color: theme.primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'مخطط تحليل أداء المبيعات والزيارات اليومية',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(icon, color: color, size: 20),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}