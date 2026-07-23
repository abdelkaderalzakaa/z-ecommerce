import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/widgets/templates/details_template.dart';
import '../../../../../data/providers/super_admin_stores_provider.dart';

class StoreDetailsPage extends StatelessWidget {
  final String storeId;

  const StoreDetailsPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Consumer<SuperAdminStoresProvider>(
      builder: (context, provider, child) {
        final store = provider.stores.firstWhere(
          (s) => s.id == storeId,
          orElse: () => provider.stores.first,
        );

        return DetailsTemplate(
          title: 'تفاصيل المتجر',
          name: store.name.get(context),
          subtitle: 'قسم: ${store.category.name.get(context)} • معرف: ${store.id}',
          avatarUrl: store.logoUrl,
          fallbackIcon: Icons.storefront_rounded,
          statusBadge: TableStatusBadge.fromStatus(store.status ?? 'Active'),
          headerMetrics: [
            Chip(
              avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
              label: Text('تقييم ${store.rate.toStringAsFixed(1)}'),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Chip(
              avatar: const Icon(Icons.shopping_bag, size: 16, color: Colors.blue),
              label: Text('${store.orders ?? 0} طلبات'),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            if (store.contactPhone != null)
              Chip(
                avatar: const Icon(Icons.phone, size: 16, color: Colors.green),
                label: Text(store.contactPhone!),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
          onRefresh: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث بيانات المتجر')),
            );
          },
          onEdit: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تعديل المتجر "${store.name.get(context)}"')),
            );
          },
          onDelete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حذف المتجر "${store.name.get(context)}"'),
                backgroundColor: Colors.red,
              ),
            );
          },
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'المنتجات'),
            Tab(text: 'الطلبات'),
            Tab(text: 'الإعدادات'),
          ],
          tabViews: [
            _buildOverviewTab(context, store),
            const Center(child: Text('المنتجات التابعة للمتجر')),
            const Center(child: Text('الطلبات المنفذة في المتجر')),
            const Center(child: Text('إعدادات المتجر الهيكلية')),
          ],
        );
      },
    );
  }

  Widget _buildOverviewTab(BuildContext context, store) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نظرة عامة على الأداء',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard(context, 'إجمالي المنتجات', '156', Icons.inventory),
              const SizedBox(width: 16),
              _buildMetricCard(context, 'إجمالي الطلبات', '${store.orders ?? 0}', Icons.shopping_bag),
              const SizedBox(width: 16),
              _buildMetricCard(context, 'إجمالي المتابعين', '${store.followers ?? 0}', Icons.people),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: const SizedBox(
              height: 260,
              width: double.infinity,
              child: Center(
                child: Text('رسم بياني لأداء المبيعات والزيارات (Sales Analytics Chart)'),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon) {
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  Icon(icon, color: theme.primaryColor, size: 20),
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
