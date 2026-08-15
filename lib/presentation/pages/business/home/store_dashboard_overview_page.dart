import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/order/invoice_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/invoice_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/business/home/business_orders_management_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/store_products_management_page.dart';

class StoreDashboardOverviewPage extends StatelessWidget {
  final String businessId;

  const StoreDashboardOverviewPage({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer2<ProductProvider, InvoiceProvider>(
        builder: (context, productProvider, invoiceProvider, child) {
          final currentStoreId =
              context.read<BusinessProvider>().selectedBusiness?.id ??
              context.read<AuthProvider>().currentUser?.businessId ??
              businessId;
          final myStoreProducts = productProvider.allProducts
              .where((p) => p.businessId == currentStoreId)
              .toList();

          final totalProductsCount = myStoreProducts.length;

          // Average Rating for my store products
          double avgStoreRating = 4.8;
          if (myStoreProducts.isNotEmpty) {
            final sum = myStoreProducts.fold<double>(
              0.0,
              (s, p) => s + p.rating,
            );
            avgStoreRating = sum / myStoreProducts.length;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        TranslationKeys.storeDashboardTitle.tr(context),
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${TranslationKeys.mainStore.tr(context)} ($businessId)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. Store KPI Cards (4 Cards)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 1000;
                    final isMedium = constraints.maxWidth > 650;
                    final crossAxisCount = isWide ? 4 : (isMedium ? 2 : 1);

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isWide ? 1.7 : 2.0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildKpiCard(
                          context,
                          title: TranslationKeys.storeProducts.tr(context),
                          value:
                              '$totalProductsCount ${TranslationKeys.product.tr(context)}',
                          subText: TranslationKeys.allProducts.tr(context),
                          icon: Icons.inventory_2_rounded,
                          color: const Color(0xFF4F46E5),
                          onTap: () {},
                        ),

                        _buildKpiCard(
                          context,
                          title: TranslationKeys.storeRating.tr(context),
                          value: '⭐ ${avgStoreRating.toStringAsFixed(1)}',
                          subText: TranslationKeys.rating.tr(context),
                          icon: Icons.star_rounded,
                          color: const Color(0xFFEC4899),
                          onTap: () {},
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 2. Visual Orders Flow Chart & Best Selling Products (2 Column Layout)
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildOrdersFlowChart(context),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: _buildTopSellingProducts(
                              context,
                              productProvider,
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _buildOrdersFlowChart(context),
                        const SizedBox(height: 20),
                        _buildTopSellingProducts(context, productProvider),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subText,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final businessProvider = Provider.of<BusinessProvider>(context);
    final storeTheme = businessProvider.selectedBusiness?.theme;
    final fontFamily = storeTheme?.fontFamily ?? 'Cairo';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: storeTheme?.cardBorderRadius ?? BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius:
                      storeTheme?.buttonBorderRadius ??
                      BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 12,
                  color:
                      storeTheme?.textColorValue.withOpacity(0.6) ??
                      theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersFlowChart(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final days = isArabic
        ? [
            'السبت',
            'الأحد',
            'الإثنين',
            'الثلاثاء',
            'الأربعاء',
            'الخميس',
            'الجمعة',
          ]
        : ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final heights = [0.6, 0.85, 0.5, 0.9, 0.75, 0.8, 0.45];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.weeklyOrdersChart.tr(context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(days.length, (i) {
                final hFactor = heights[i];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 140 * hFactor,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingProducts(
    BuildContext context,
    ProductProvider productProvider,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.topSellingStoreProducts.tr(context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'المنتجات الفائزة بأعلى الطلبات',
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
