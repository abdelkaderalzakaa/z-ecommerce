import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/create_business_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/business_details_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/common/status_dialogs.dart';

class BusinessessManagementPage extends StatefulWidget {
  const BusinessessManagementPage({super.key});

  @override
  State<BusinessessManagementPage> createState() =>
      _BusinessessManagementPageState();
}

class _BusinessessManagementPageState extends State<BusinessessManagementPage> {
  String _selectedStatusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessProvider>(
      builder: (context, provider, child) {
        final filteredStores = provider.businesses.where((store) {
          final matchesStatus =
              _selectedStatusFilter == 'all' ||
              (store.status ?? 'Active').toLowerCase() ==
                  _selectedStatusFilter.toLowerCase();

          return matchesStatus;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Height Expanded AppDataTable Component
                Expanded(
                  child: AppDataTable<BusinessModel>(
                    items: filteredStores,
                    isLoading: provider.isLoading,
                    selectable: true,
                    showIndexColumn: true,
                    onBulkDelete: (selected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${TranslationKeys.deleteSelected.tr(context)} (${selected.length})',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },

                    // Search and Filter Handlers
                    searchMatcher: (store, q) =>
                        store.localization.name.get(context).toLowerCase().contains(q) ||
                        store.businessType.name.toLowerCase().contains(q) ||
                        store.id.toLowerCase().contains(q),
                    onFilterTap: () => _showFilterDialog(context),

                    // Primary Action Button
                    primaryActionButton: ButtonApp(
                      onPressed: () =>
                          changeScreen(context, const CreateBusinessPage()),
                      icon: Icons.add,
                      label: TranslationKeys.addNewStore.tr(context),
                    ),

                    emptyMessage: TranslationKeys.noDataAvailable.tr(context),
                    onRowTap: (store) => changeScreen(
                      context,
                      BusinessDetailsPage(storeId: store.id),
                    ),

                    // Table Columns Configuration
                    columns: [
                      AppTableColumn<BusinessModel>(
                        title: TranslationKeys.store.tr(context),
                        flex: 2,
                        sortable: true,
                        sortKey: (store) =>
                            store.localization.name.get(context),
                        cellBuilder: (store) => TableImageTextCell(
                          title: store.localization.name.get(context),
                          subtitle: store.ownerEmail ?? '',
                          imageUrl: store.theme.logoUrl,
                          fallbackIcon: Icons.storefront_rounded,
                        ),
                      ),
                      AppTableColumn<BusinessModel>(
                        title: TranslationKeys.category.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (store) => store.businessType.name,
                        cellBuilder: (store) =>
                            TableTextCell(title: store.businessType.name),
                      ),
                      AppTableColumn<BusinessModel>(
                        title: TranslationKeys.ordersAndRating.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (store) => store.orders,
                        cellBuilder: (store) => TableTextCell(
                          title: '${store.orders}',
                          subtitle: '⭐ ${store.rating.toStringAsFixed(1)}',
                        ),
                      ),
                      AppTableColumn<BusinessModel>(
                        title: TranslationKeys.contact.tr(context),
                        flex: 1,
                        cellBuilder: (store) =>
                            TableTextCell(title: store.ownerEmail ?? ''),
                      ),
                      AppTableColumn<BusinessModel>(
                        title: TranslationKeys.statusActive.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (store) => store.status ?? 'Active',
                        cellBuilder: (store) => InkWell(
                          onTap: () => showStoreStatusDialog(context, store),
                          borderRadius: BorderRadius.circular(16),
                          child: TableStatusBadge.fromStatus(
                            (store.status ?? 'Active') == 'Active'
                                ? TranslationKeys.statusActive.tr(context)
                                : TranslationKeys.statusInactive.tr(context),
                          ),
                        ),
                      ),
                      AppTableColumn<BusinessModel>(
                        title: TranslationKeys.actions.tr(context),
                        width: 70,
                        alignment: Alignment.center,
                        cellBuilder: (store) => TablePopupMenuActions(
                          onView: () => changeScreen(
                            context,
                            BusinessDetailsPage(storeId: store.id),
                          ),
                          onEdit: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${TranslationKeys.editAddress.tr(context)}: "${store.localization.name.get(context)}"',
                                ),
                              ),
                            );
                          },
                          onDelete: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${TranslationKeys.deleteSelected.tr(context)}: "${store.localization.name.get(context)}"',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationKeys.filter.tr(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(TranslationKeys.allProducts.tr(context)),
              value: 'all',
              groupValue: _selectedStatusFilter,
              onChanged: (val) {
                setState(() => _selectedStatusFilter = val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(TranslationKeys.statusActive.tr(context)),
              value: 'Active',
              groupValue: _selectedStatusFilter,
              onChanged: (val) {
                setState(() => _selectedStatusFilter = val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(TranslationKeys.statusInactive.tr(context)),
              value: 'Inactive',
              groupValue: _selectedStatusFilter,
              onChanged: (val) {
                setState(() => _selectedStatusFilter = val!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
