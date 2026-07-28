import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/address_model.dart';
import 'package:z_ecommerce/data/models/invoice_model.dart';
import 'package:z_ecommerce/data/providers/invoice_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/orders/order_details_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/common/status_dialogs.dart';

class OrdersManagementPage extends StatefulWidget {
  const OrdersManagementPage({super.key});

  @override
  State<OrdersManagementPage> createState() => _OrdersManagementPageState();
}

class _OrdersManagementPageState extends State<OrdersManagementPage> {
  String _searchQuery = '';
  String _selectedStatusFilter = 'all';
  List<InvoiceModel> _selectedOrders = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        final allOrders = provider.invoices.isNotEmpty
            ? provider.invoices
            : List.generate(
                8,
                (index) => InvoiceModel(
                  invoiceId: 'ORD-2026-${1000 + index}',
                  storeId: 'cmp_00${(index % 3) + 1}',
                  items: [],
                  tax: 15.0,
                  shippingCost: 10.0,
                  date: DateTime.now().subtract(Duration(days: index * 2)),
                  status: index == 0 ? 'Pending' : (index == 1 ? 'Paid' : 'Completed'),
                  shippingAddress: dynamicAddressPlaceholder(),
                ),
              );

        final filteredOrders = allOrders.where((order) {
          final matchesQuery = _searchQuery.isEmpty ||
              order.invoiceId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              order.storeId.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesStatus = _selectedStatusFilter == 'all' ||
              order.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
          return matchesQuery && matchesStatus;
        }).toList();

        final totalItems = filteredOrders.length;
        final totalPages = (totalItems / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
        final paginatedOrders = (startIndex < totalItems)
            ? filteredOrders.sublist(startIndex, endIndex)
            : <InvoiceModel>[];

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
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
                        'استعراض ومتابعة كافة الطلبات المنفذة عبر جميع المتاجر',
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

              // Full Height Expanded AppDataTable for InvoiceModel
              Expanded(
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
                        content: Text('${TranslationKeys.deleteSelected.tr(context)} (${_selectedOrders.length})'),
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
                      title: TranslationKeys.orderId.tr(context),
                      flex: 1,
                      sortable: true,
                      sortKey: (order) => order.invoiceId,
                      cellBuilder: (order) => TableTextCell(
                        title: '#${order.invoiceId}',
                        isBold: true,
                      ),
                    ),
                    AppTableColumn<InvoiceModel>(
                      title: TranslationKeys.store.tr(context),
                      flex: 1,
                      sortable: true,
                      sortKey: (order) => order.storeId,
                      cellBuilder: (order) => TableImageTextCell(
                        title: '${TranslationKeys.store.tr(context)} ${order.storeId}',
                        fallbackIcon: Icons.storefront_rounded,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${TranslationKeys.deleteSelected.tr(context)} #${order.invoiceId}'),
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

AddressModel dynamicAddressPlaceholder() {
  return AddressModel(
    id: 'addr_default',
    label: 'العنوان الرئيسي',
    street: 'شارع الملك فهد',
    city: 'الرياض',
    state: 'الرياض',
    zipCode: '11564',
    country: 'المملكة العربية السعودية',
  );
}
