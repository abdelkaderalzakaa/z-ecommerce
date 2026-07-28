import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/details_template.dart';
import '../../../../../data/providers/super_admin_stores_provider.dart';

// Tab View Components
import 'store_details_tab/overview_tab.dart';
import 'store_details_tab/products_tab.dart';
import 'store_details_tab/orders_tab.dart';
import 'store_details_tab/reviews_tab.dart';
import 'store_details_tab/category_tab.dart';
import 'store_details_tab/settings_tab.dart';

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
          title: TranslationKeys.storeDetailsTitle.tr(context),
          name: store.name.get(context),
          subtitle: '${TranslationKeys.category.tr(context)}: ${store.category.name.get(context)} • ${store.id}',
          avatarUrl: store.logoUrl,
          fallbackIcon: Icons.storefront_rounded,
          statusBadge: TableStatusBadge.fromStatus(store.status ?? 'Active'),
          headerMetrics: [
            Chip(
              avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
              label: Text('⭐ ${store.rate.toStringAsFixed(1)}'),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Chip(
              avatar: const Icon(Icons.shopping_bag, size: 16, color: Colors.blue),
              label: Text('${store.orders ?? 0} ${TranslationKeys.orders.tr(context)}'),
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
              SnackBar(content: Text('${TranslationKeys.editAddress.tr(context)} "${store.name.get(context)}"')),
            );
          },
          onDelete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${TranslationKeys.deleteSelected.tr(context)} "${store.name.get(context)}"'),
                backgroundColor: Colors.red,
              ),
            );
          },
          tabs: [
            Tab(text: TranslationKeys.overviewTab.tr(context)),
            Tab(text: TranslationKeys.productsTab.tr(context)),
            Tab(text: TranslationKeys.ordersTab.tr(context)),
            const Tab(text: 'التقييمات والمتابعات'),
            const Tab(text: 'الأقسام والعلامات'),
            Tab(text: TranslationKeys.settingsTab.tr(context)),
          ],
          tabViews: [
            OverviewTab(store: store),
            ProductsTab(store: store),
            OrdersTab(store: store),
            ReviewsTab(store: store),
            CategoryTab(store: store),
            SettingsTab(store: store),
          ],
        );
      },
    );
  }
}
