import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/fake_data/users.dart';
import 'package:z_ecommerce/data/models/user_model.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/data/providers/invoice_provider.dart';
import 'package:z_ecommerce/data/providers/offer_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_stores_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/categories/categories_management_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/offers/offers_management_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/orders/orders_management_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/products/product_details_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/products/products_management_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/stores/store_details_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/stores/stores_management_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/users/users_management_page.dart';

class DashboardOverviewPage extends StatelessWidget {
  const DashboardOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer5<SuperAdminStoresProvider, ProductProvider, InvoiceProvider, OfferProvider, CategoryProvider>(
      builder: (context, storesProvider, productProvider, invoiceProvider, offerProvider, categoryProvider, child) {
        if (storesProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Calculations & Summaries across all providers
        final totalStores = storesProvider.totalStores;
        final activeStores = storesProvider.activeStores;

        final totalProducts = productProvider.allProducts.length;
        final topSellingProductsCount = productProvider.topSelling.length;

        final totalOrders = invoiceProvider.invoices.length;
        final completedOrders = invoiceProvider.invoices.where((i) => i.status == 'Completed' || i.status == 'Paid').length;
        final pendingOrders = invoiceProvider.invoices.where((i) => i.status == 'Pending').length;

        final totalUsers = fakeUsers.length;
        final customersCount = fakeUsers.where((u) => u.role == UserRole.customer).length;
        final ownersCount = fakeUsers.where((u) => u.role == UserRole.companyOwner).length;

        final totalOffers = offerProvider.allOffers.length;
        final activeOffers = offerProvider.allOffers.where((o) => o.isActive).length;

        // Average Platform Rating
        double avgRating = 0.0;
        if (productProvider.allProducts.isNotEmpty) {
          final sum = productProvider.allProducts.fold<double>(0.0, (s, p) => s + p.rating);
          avgRating = sum / productProvider.allProducts.length;
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Time Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationKeys.superAdminDashboard.tr(context),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'نظرة شاملة وموسعة على المتاجر، المنتجات، الطلبات، التقييمات، المستخدمين، والعروض',
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
                        Icon(Icons.dashboard_customize_rounded, size: 16, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        const Text('التقرير التجميعي الشامل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 1. KPI Stats Grid (6 Diverse Section Cards)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 1100;
                  final isMedium = constraints.maxWidth > 700;
                  final crossAxisCount = isWide ? 6 : (isMedium ? 3 : 2);

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: isWide ? 1.35 : 1.5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildKpiCard(
                        context,
                        title: 'المتاجر المسجلة',
                        value: '$totalStores متجر',
                        subText: '$activeStores نشط الآن',
                        icon: Icons.storefront_rounded,
                        color: const Color(0xFF4F46E5),
                        onTap: () => changeScreen(context, const StoresManagementPage()),
                      ),
                      _buildKpiCard(
                        context,
                        title: 'منتجات المنصة',
                        value: '$totalProducts منتج',
                        subText: '$topSellingProductsCount أكثر مبيعاً',
                        icon: Icons.inventory_2_rounded,
                        color: const Color(0xFF10B981),
                        onTap: () => changeScreen(context, const ProductsManagementPage()),
                      ),
                      _buildKpiCard(
                        context,
                        title: 'حركة الطلبات',
                        value: '$totalOrders طلب',
                        subText: '$completedOrders مكتمل • $pendingOrders معلق',
                        icon: Icons.shopping_cart_rounded,
                        color: const Color(0xFFF59E0B),
                        onTap: () => changeScreen(context, const OrdersManagementPage()),
                      ),
                      _buildKpiCard(
                        context,
                        title: 'المستخدمون',
                        value: '$totalUsers حساب',
                        subText: '$customersCount عميل • $ownersCount مدير',
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xFFEC4899),
                        onTap: () => changeScreen(context, const UsersManagementPage()),
                      ),
                      _buildKpiCard(
                        context,
                        title: 'العروض والكوبونات',
                        value: '$totalOffers عرض',
                        subText: '$activeOffers عرض مفعل',
                        icon: Icons.local_offer_rounded,
                        color: const Color(0xFF8B5CF6),
                        onTap: () => changeScreen(context, const OffersManagementPage()),
                      ),
                      _buildKpiCard(
                        context,
                        title: 'متوسط التقييمات',
                        value: '⭐ ${avgRating.toStringAsFixed(1)}',
                        subText: 'تقييم عام ممتاز',
                        icon: Icons.star_rounded,
                        color: const Color(0xFFEAB308),
                        onTap: () {},
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 2. Visual Orders Flow Chart & Category Progress Bars (2 Column Layout)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildOrdersFlowChart(context, invoiceProvider)),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: _buildCategoriesDistribution(context, categoryProvider, productProvider)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildOrdersFlowChart(context, invoiceProvider),
                      const SizedBox(height: 20),
                      _buildCategoriesDistribution(context, categoryProvider, productProvider),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 3. Top Rated Leaderboards (Top Products & Top Rated Stores)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildTopRatedProducts(context, productProvider)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildTopRatedStores(context, storesProvider)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildTopRatedProducts(context, productProvider),
                      const SizedBox(height: 20),
                      _buildTopRatedStores(context, storesProvider),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 4. User Roles Breakdown & Active Offers Cards (2 Column Layout)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildUserRolesDistribution(context)),
                        const SizedBox(width: 20),
                        Expanded(flex: 3, child: _buildActiveOffersWidget(context, offerProvider)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildUserRolesDistribution(context),
                      const SizedBox(height: 20),
                      _buildActiveOffersWidget(context, offerProvider),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  // Widget: KPI Card Component
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: theme.textTheme.bodySmall?.color),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subText,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Orders Visual Flow Chart
  Widget _buildOrdersFlowChart(BuildContext context, InvoiceProvider invoiceProvider) {
    final theme = Theme.of(context);
    final days = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    final heights = [0.5, 0.8, 0.6, 0.95, 0.7, 0.85, 0.4];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'مخطط حركة الطلبات الأسبوعي',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'مقارنة توزيع الطلبات اليومية عبر أيام الأسبوع',
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => changeScreen(context, const OrdersManagementPage()),
                icon: const Icon(Icons.shopping_cart_outlined, size: 14),
                label: const Text('إدارة الطلبات', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom Orders Bar Visuals
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
                      width: 26,
                      height: 130 * hFactor,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.35),
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

  // Widget: Categories & Products Distribution
  Widget _buildCategoriesDistribution(BuildContext context, CategoryProvider categoryProvider, ProductProvider productProvider) {
    final theme = Theme.of(context);
    final categories = categoryProvider.categories.take(4).toList();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'توزيع الأقسام والتصنيفات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                onPressed: () => changeScreen(context, const CategoriesManagementPage()),
              ),
            ],
          ),
          Text(
            'نسب المنتجات المعروضة بكل قسم',
            style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
          ),
          const SizedBox(height: 16),
          ...categories.map((cat) {
            final count = productProvider.getProductsByCategory(cat.label).length;
            final total = productProvider.allProducts.length;
            final double percent = total > 0 ? (count / total) : 0.25;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(cat.icon ?? Icons.category_rounded, size: 16, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          Text(cat.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Text('$count منتج (${(percent * 100).toInt()}%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percent > 0 ? percent : 0.15,
                      minHeight: 7,
                      backgroundColor: theme.primaryColor.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(cat.bgColor.computeLuminance() > 0.8 ? theme.primaryColor : cat.bgColor),
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

  // Widget: Top Rated Products Leaderboard
  Widget _buildTopRatedProducts(BuildContext context, ProductProvider productProvider) {
    final theme = Theme.of(context);
    final topProducts = List.from(productProvider.allProducts)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final displayProducts = topProducts.take(4).toList();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المنتجات الأعلى تقييماً',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => changeScreen(context, const ProductsManagementPage()),
                child: const Text('إدارة المنتجات'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...displayProducts.map((p) {
            return InkWell(
              onTap: () => changeScreen(context, ProductDetailsPage(productId: p.id)),
              borderRadius: BorderRadius.circular(12),
              child: Container(
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
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                          const SizedBox(width: 4),
                          Text(
                            p.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Widget: Top Rated Stores Leaderboard
  Widget _buildTopRatedStores(BuildContext context, SuperAdminStoresProvider storesProvider) {
    final theme = Theme.of(context);
    final stores = storesProvider.stores.take(4).toList();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المتاجر الأعلى تقييماً ونشاطاً',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => changeScreen(context, const StoresManagementPage()),
                child: const Text('إدارة المتاجر'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stores.map((s) {
            double rating = 4.8;
            if (s.ratingStore != null && s.ratingStore!.isNotEmpty) {
              final sum = s.ratingStore!.fold<int>(0, (prev, r) => prev + r.rating);
              rating = sum / s.ratingStore!.length;
            }

            return InkWell(
              onTap: () => changeScreen(context, StoreDetailsPage(storeId: s.id)),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.storefront_rounded, color: theme.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name.get(context),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '${s.category} • ${s.orders} طلب',
                            style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Widget: User Roles Breakdown Card
  Widget _buildUserRolesDistribution(BuildContext context) {
    final theme = Theme.of(context);
    final total = fakeUsers.length;
    final customers = fakeUsers.where((u) => u.role == UserRole.customer).length;
    final owners = fakeUsers.where((u) => u.role == UserRole.companyOwner).length;
    final admins = fakeUsers.where((u) => u.role == UserRole.superAdmin).length;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'توزيع أدوار المستخدمين',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                onPressed: () => changeScreen(context, const UsersManagementPage()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRoleRow(context, 'العملاء (Customers)', customers, total, const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _buildRoleRow(context, 'مدراء المتاجر (Store Owners)', owners, total, const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          _buildRoleRow(context, 'مسؤولو المنصة (Super Admins)', admins, total, const Color(0xFF6366F1)),
        ],
      ),
    );
  }

  Widget _buildRoleRow(BuildContext context, String roleTitle, int count, int total, Color color) {
    final double percent = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(roleTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('$count ($count)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // Widget: Active Offers & Marketing Widget
  Widget _buildActiveOffersWidget(BuildContext context, OfferProvider offerProvider) {
    final theme = Theme.of(context);
    final activeOffers = offerProvider.allOffers.where((o) => o.isActive).take(3).toList();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الحملات والعروض التسويقية الفعالة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => changeScreen(context, const OffersManagementPage()),
                child: const Text('إدارة العروض'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activeOffers.map((offer) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_offer_rounded, color: Color(0xFF4F46E5), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.name.get(context),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'كود: ${offer.couponCode ?? "عام"} • ينتهي في: ${offer.endDate.year}-${offer.endDate.month.toString().padLeft(2, '0')}-${offer.endDate.day.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                        ),
                      ],
                    ),
                  ),
                  TableStatusBadge.fromStatus(TranslationKeys.statusActive.tr(context)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
