import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/order/invoice_model.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/providers/invoice_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class UserOrdersTab extends StatefulWidget {
  final UserModel user;

  const UserOrdersTab({super.key, required this.user});

  @override
  State<UserOrdersTab> createState() => _UserOrdersTabState();
}

class _UserOrdersTabState extends State<UserOrdersTab> {
  String _searchQuery = '';
  List<InvoiceModel> _selectedOrders = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        final userInvoices = provider.invoices.where((inv) {
          final matchesQuery =
              _searchQuery.isEmpty ||
              inv.id.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesQuery;
        }).toList();

        final totalItems = userInvoices.length;
        final totalPages = (totalItems / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
        final paginatedOrders = (startIndex < totalItems)
            ? userInvoices.sublist(startIndex, endIndex)
            : <InvoiceModel>[];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppDataTable<InvoiceModel>(
            items: paginatedOrders,
            selectable: true,
            showIndexColumn: true,
            selectedItems: _selectedOrders,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedOrders = selected;
              });
            },
            onBulkDelete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${TranslationKeys.deleteSelected.tr(context)} (${_selectedOrders.length})',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() {
                _selectedOrders.clear();
              });
            },
            searchQuery: _searchQuery,
            onSearchChanged: (val) {
              setState(() {
                _searchQuery = val;
                _currentPage = 1;
              });
            },
            currentPage: _currentPage,
            totalPages: totalPages > 0 ? totalPages : 1,
            totalItems: totalItems,
            itemsPerPage: _itemsPerPage,
            onPageChanged: (page) => setState(() => _currentPage = page),
            onItemsPerPageChanged: (rows) {
              setState(() {
                _itemsPerPage = rows;
                _currentPage = 1;
              });
            },
            emptyMessage: _searchQuery.isNotEmpty
                ? TranslationKeys.noMatchingResults.tr(context)
                : TranslationKeys.noDataAvailable.tr(context),
            columns: [
              AppTableColumn<InvoiceModel>(
                title: TranslationKeys.orderId.tr(context),
                flex: 2,
                sortable: true,
                sortKey: (inv) => inv.id,
                cellBuilder: (inv) => TableTextCell(
                  title: inv.id,
                  subtitle:
                      '${inv.createdAt.year}-${inv.createdAt.month.toString().padLeft(2, '0')}-${inv.createdAt.day.toString().padLeft(2, '0')}',
                  isBold: true,
                ),
              ),
              AppTableColumn<InvoiceModel>(
                title: TranslationKeys.total.tr(context),
                flex: 1,
                sortable: true,
                sortKey: (inv) => inv.total,
                cellBuilder: (inv) => TablePriceCell(amount: inv.total),
              ),
              AppTableColumn<InvoiceModel>(
                title: TranslationKeys.statusActive.tr(context),
                flex: 1,
                sortable: true,
                sortKey: (inv) => inv.status.name,
                cellBuilder: (inv) => TableStatusBadge.fromStatus(inv.status.name),
              ),
              AppTableColumn<InvoiceModel>(
                title: TranslationKeys.actions.tr(context),
                width: 70,
                alignment: Alignment.center,
                cellBuilder: (inv) => TablePopupMenuActions(
                  onView: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
