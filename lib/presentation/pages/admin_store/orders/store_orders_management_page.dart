import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/invoice_model.dart';
import 'package:z_ecommerce/data/providers/invoice_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/common/status_dialogs.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/orders/order_details_page.dart';

class StoreOrdersManagementPage extends StatefulWidget {
  final String companyId;

  const StoreOrdersManagementPage({
    super.key,
    this.companyId = 'cmp_001',
  });

  @override
  State<StoreOrdersManagementPage> createState() => _StoreOrdersManagementPageState();
}

class _StoreOrdersManagementPageState extends State<StoreOrdersManagementPage> {
  String _searchQuery = '';
  String _selectedStatusFilter = 'all';
  List<InvoiceModel> _selectedInvoices = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          final filteredInvoices = provider.invoices.where((invoice) {
            final matchesStore = invoice.storeId == widget.companyId || invoice.storeId == 'cmp_001';
            final matchesQuery = _searchQuery.isEmpty ||
                invoice.invoiceId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                invoice.shippingAddress.city.toLowerCase().contains(_searchQuery.toLowerCase());

            final matchesStatus = _selectedStatusFilter == 'all' ||
                invoice.status.toLowerCase() == _selectedStatusFilter.toLowerCase();

            return matchesStore && matchesQuery && matchesStatus;
          }).toList();

          final totalItems = filteredInvoices.length;
          final totalPages = (totalItems / _itemsPerPage).ceil();
          final startIndex = (_currentPage - 1) * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
          final paginatedInvoices = (startIndex < totalItems)
              ? filteredInvoices.sublist(startIndex, endIndex)
              : <InvoiceModel>[];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TranslationKeys.ordersManagement.tr(context),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'متابعة ومعالجة الطلبات الواردة لمتجرك وتحديث حالتها',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // AppDataTable for Store Invoices
                Expanded(
                  child: AppDataTable<InvoiceModel>(
                    items: paginatedInvoices,
                    selectable: true,
                    showIndexColumn: true,
                    selectedItems: _selectedInvoices,
                    onSelectionChanged: (selected) {
                      setState(() {
                        _selectedInvoices = selected;
                      });
                    },
                    onBulkDelete: () {
                      setState(() {
                        for (var inv in _selectedInvoices) {
                          provider.invoices.removeWhere((item) => item.invoiceId == inv.invoiceId);
                        }
                        _selectedInvoices.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${TranslationKeys.deleteSelected.tr(context)} (${_selectedInvoices.length})'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    searchQuery: _searchQuery,
                    onSearchChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _currentPage = 1;
                      });
                    },
                    onFilterTap: () => _showFilterDialog(context),
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
                    onRowTap: (order) => changeScreen(
                      context,
                      OrderDetailsPage(orderId: order.invoiceId),
                    ),
                    columns: [
                      AppTableColumn<InvoiceModel>(
                        title: TranslationKeys.orderNumber.tr(context),
                        flex: 2,
                        sortable: true,
                        sortKey: (order) => order.invoiceId,
                        cellBuilder: (order) => TableImageTextCell(
                          title: '#${order.invoiceId}',
                          subtitle: '${order.shippingAddress.city}, ${order.shippingAddress.country}',
                          fallbackIcon: Icons.receipt_long_rounded,
                        ),
                      ),
                      AppTableColumn<InvoiceModel>(
                        title: TranslationKeys.total.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (order) => order.total,
                        cellBuilder: (order) => TablePriceCell(
                          amount: order.total > 0 ? order.total : 120.0,
                        ),
                      ),
                      AppTableColumn<InvoiceModel>(
                        title: TranslationKeys.orderDate.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (order) => order.date,
                        cellBuilder: (order) => TableTextCell(
                          title: '${order.date.year}-${order.date.month.toString().padLeft(2, '0')}-${order.date.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                      AppTableColumn<InvoiceModel>(
                        title: TranslationKeys.statusActive.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (order) => order.status,
                        cellBuilder: (order) => InkWell(
                          onTap: () => showOrderStatusDialog(context, order),
                          borderRadius: BorderRadius.circular(16),
                          child: TableStatusBadge.fromStatus(
                            order.status == 'Pending'
                                ? TranslationKeys.statusPending.tr(context)
                                : (order.status == 'Paid'
                                    ? TranslationKeys.statusPaid.tr(context)
                                    : TranslationKeys.statusCompleted.tr(context)),
                          ),
                        ),
                      ),
                      AppTableColumn<InvoiceModel>(
                        title: TranslationKeys.actions.tr(context),
                        width: 70,
                        alignment: Alignment.center,
                        cellBuilder: (order) => TablePopupMenuActions(
                          onView: () => changeScreen(
                            context,
                            OrderDetailsPage(orderId: order.invoiceId),
                          ),
                          onEdit: () => showOrderStatusDialog(context, order),
                          onDelete: () {
                            setState(() {
                              provider.invoices.removeWhere((item) => item.invoiceId == order.invoiceId);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم حذف طلب الفاتورة #${order.invoiceId} بنجاح'),
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
          );
        },
      ),
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
              title: Text(TranslationKeys.statusPending.tr(context)),
              value: 'Pending',
              groupValue: _selectedStatusFilter,
              onChanged: (val) {
                setState(() => _selectedStatusFilter = val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(TranslationKeys.statusPaid.tr(context)),
              value: 'Paid',
              groupValue: _selectedStatusFilter,
              onChanged: (val) {
                setState(() => _selectedStatusFilter = val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(TranslationKeys.statusCompleted.tr(context)),
              value: 'Completed',
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
