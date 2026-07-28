import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/invoice_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/admin_store/orders/store_orders_management_page.dart';
import 'package:z_ecommerce/presentation/pages/admin_store/products/store_products_management_page.dart';

class StoreDashboardOverviewPage extends StatelessWidget {
  final String companyId;

  const StoreDashboardOverviewPage({
    super.key,
    this.companyId = 'cmp_001',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer2<ProductProvider, InvoiceProvider>(
        builder: (context, productProvider, invoiceProvider, child) {
          // My Store Data Filters
          final myStoreInvoices = invoiceProvider.invoices.where((i) => i.storeId == companyId || i.storeId == 'cmp_001').toList();
          final myStoreProducts = productProvider.allProducts;

          final totalOrdersCount = myStoreInvoices.length;
          final completedOrdersCount = myStoreInvoices.where((i) => i.status == 'Completed' || i.status == 'Paid').length;
          final pendingOrdersCount = myStoreInvoices.where((i) => i.status == 'Pending').length;
          final totalProductsCount = myStoreProducts.length;

          // Average Rating for my store products
          double avgStoreRating = 4.8;
          if (myStoreProducts.isNotEmpty) {
            final sum = myStoreProducts.fold<double>(0.0, (s, p) => s + p.rating);
            avgStoreRating = sum / myStoreProducts.length;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لوحة تحكم المتجر',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'متابعة أداء المبيعات والمنتجات والطلبات الخاصة بمتجرك',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.storefront_rounded, size: 16, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'المتجر الرئيسي ($companyId)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                          title: 'منتجات المتجر',
                          value: '$totalProductsCount منتج',
                          subText: 'جميع المنتجات المعروضة',
                          icon: Icons.inventory_2_rounded,
                          color: const Color(0xFF4F46E5),
                          onTap: () {},
                        ),
                        _buildKpiCard(
                          context,
                          title: 'إجمالي الطلبات',
                          value: '$totalOrdersCount طلب',
                          subText: '$completedOrdersCount مكتمل • $pendingOrdersCount معلق',
                          icon: Icons.shopping_cart_rounded,
                          color: const Color(0xFF10B981),
                          onTap: () {},
                        ),
                        _buildKpiCard(
                          context,
                          title: 'الطلبات المعلقة',
                          value: '$pendingOrdersCount طلب',
                          subText: 'تتطلب المراجعة والتجهيز',
                          icon: Icons.hourglass_top_rounded,
                          color: const Color(0xFFF59E0B),
                          onTap: () {},
                        ),
                        _buildKpiCard(
                          context,
                          title: 'تقييم المتجر',
                          value: '⭐ ${avgStoreRating.toStringAsFixed(1)}',
                          subText: 'تقييم العملاء العام',
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
                          Expanded(flex: 3, child: _buildOrdersFlowChart(context)),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: _buildTopSellingProducts(context, productProvider)),
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  borderRadius: BorderRadius.circular(12),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
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
    final days = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
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
          const Text(
            'مخطط طلبات المتجر الأسبوعي',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'توزيع الطلبات اليومية المستلمة في المتجر',
            style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
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

  Widget _buildTopSellingProducts(BuildContext context, ProductProvider productProvider) {
    final theme = Theme.of(context);
    final topProducts = productProvider.topSelling.take(4).toList();

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
          const Text(
            'المنتجات الأكثر مبيعاً بمتجرك',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'المنتجات الفائزة بأعلى الطلبات',
            style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
          ),
          const SizedBox(height: 16),
          ...topProducts.map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  TableImageTextCell(
                    title: p.name,
                    subtitle: '\$${p.price}',
                    imageUrl: p.images.isNotEmpty ? p.images.first : null,
                    fallbackIcon: Icons.shopping_bag_outlined,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⭐ ${p.rating.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF137333)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
