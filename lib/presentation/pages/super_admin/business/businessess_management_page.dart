import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
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
  String _searchQuery = '';
  String _selectedStatusFilter = 'all';
  List<BusinessModel> _selectedStores = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessProvider>(
      builder: (context, provider, child) {
        final filteredStores = provider.businesses.where((store) {
          final nameStr = store.localization.name.get(context).toLowerCase();
          final categoryStr = store.businessType.name
              .get(context)
              .toLowerCase();
          final matchesQuery =
              _searchQuery.isEmpty ||
              nameStr.contains(_searchQuery.toLowerCase()) ||
              categoryStr.contains(_searchQuery.toLowerCase()) ||
              store.id.toLowerCase().contains(_searchQuery.toLowerCase());

          final matchesStatus =
              _selectedStatusFilter == 'all' ||
              (store.status ?? 'Active').toLowerCase() ==
                  _selectedStatusFilter.toLowerCase();

          return matchesQuery && matchesStatus;
        }).toList();

        final totalItems = filteredStores.length;
        final totalPages = (totalItems / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
        final paginatedStores = (startIndex < totalItems)
            ? filteredStores.sublist(startIndex, endIndex)
            : <BusinessModel>[];

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TranslationKeys.storesManagement.tr(context),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Full Height Expanded AppDataTable Component
                Expanded(
                  child: AppDataTable<BusinessModel>(
                    items: paginatedStores,
                    isLoading: provider.isLoading,
                    selectable: true,
                    showIndexColumn: true,
                    selectedItems: _selectedStores,
                    onSelectionChanged: (selected) {
                      setState(() {
                        _selectedStores = selected;
                      });
                    },
                    onBulkDelete: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${TranslationKeys.deleteSelected.tr(context)} (${_selectedStores.length})',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      setState(() {
                        _selectedStores.clear();
                      });
                    },

                    // Search and Filter Handlers
                    searchQuery: _searchQuery,
                    onSearchChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _currentPage = 1;
                      });
                    },
                    onFilterTap: () => _showFilterDialog(context),

                    // Primary Action Button
                    primaryActionButton: ElevatedButton.icon(
                      onPressed: () =>
                          changeScreen(context, const CreateBusinessPage()),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(TranslationKeys.addNewStore.tr(context)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Pagination Properties
                    currentPage: _currentPage,
                    totalPages: totalPages > 0 ? totalPages : 1,
                    totalItems: totalItems,
                    itemsPerPage: _itemsPerPage,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    onItemsPerPageChanged: (rows) {
                      setState(() {
                        _itemsPerPage = rows;
                        _currentPage = 1;
                      });
                    },

                    emptyMessage: _searchQuery.isNotEmpty
                        ? TranslationKeys.noMatchingResults.tr(context)
                        : TranslationKeys.noDataAvailable.tr(context),
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
                          subtitle: store.contactEmail ?? store.id,
                          imageUrl: store.logoUrl,
                          fallbackIcon: Icons.storefront_rounded,
                        ),
                      ),
                      AppTableColumn<BusinessModel>(
                        title: TranslationKeys.category.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (store) => store.category.name.get(context),
                        cellBuilder: (store) => TableTextCell(
                          title: store.category.name.get(context),
                        ),
                      ),
                      AppTableColumn<BusinessModel>(
                        title: TranslationKeys.ordersAndRating.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (store) => store.orders ?? 0,
                        cellBuilder: (store) => TableTextCell(
                          title: '${store.orders ?? 0}',
                          subtitle: '⭐ ${store.rate.toStringAsFixed(1)}',
                        ),
                      ),
                      AppTableColumn<BusinessModel>(
                        title: TranslationKeys.contact.tr(context),
                        flex: 1,
                        cellBuilder: (store) => TableTextCell(
                          title:
                              store.contactPhone ?? store.contactEmail ?? '-',
                        ),
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
