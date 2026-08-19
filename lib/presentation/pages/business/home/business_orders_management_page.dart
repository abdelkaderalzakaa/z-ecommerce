import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/order/invoice_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/invoice_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/orders/order_details_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/common/status_dialogs.dart'; 
class BusinessOrdersManagementPage extends StatefulWidget {
  final String businessId;

  const BusinessOrdersManagementPage({super.key, required this.businessId});

  @override
  State<BusinessOrdersManagementPage> createState() =>
      _BusinessOrdersManagementPageState();
}

class _BusinessOrdersManagementPageState
    extends State<BusinessOrdersManagementPage> {
  String _selectedStatusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          final filteredInvoices = provider.invoices.where((invoice) {
            final matchesStore = invoice.storeId == widget.businessId;
            final matchesStatus =
                _selectedStatusFilter == 'all' ||
                invoice.status.name.toLowerCase() ==
                    _selectedStatusFilter.toLowerCase();

            return matchesStore && matchesStatus;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                Text(
                  TranslationKeys.ordersManagement.tr(context),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // AppDataTable for Store Invoices
                Expanded(
                  child: AppDataTable<InvoiceModel>(
                    items: filteredInvoices,
                    selectable: true,
                    showIndexColumn: true,
                    onBulkDelete: (selected) {
                      setState(() {
                        for (var inv in selected) {
                          provider.invoices.removeWhere(
                            (item) => item.id == inv.id,
                          );
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${TranslationKeys.deleteSelected.tr(context)} (${selected.length})',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    searchMatcher: (invoice, q) =>
                        invoice.id.toLowerCase().contains(q) ||
                        invoice.shippingAddress.city
                            .get(context)
                            .toLowerCase()
                            .contains(q),
                    onFilterTap: () => _showFilterDialog(context),
                    emptyMessage: TranslationKeys.noDataAvailable.tr(context),
                    onRowTap: (order) => changeScreen(
                      context,
                      OrderDetailsPage(orderId: order.id),
                    ),
                    columns: [
                      AppTableColumn<InvoiceModel>(
                        title: TranslationKeys.orderNumber.tr(context),
                        flex: 2,
                        sortable: true,
                        sortKey: (order) => order.id,
                        cellBuilder: (order) => TableImageTextCell(
                          title: '#${order.id}',
                          subtitle:
                              '${order.shippingAddress.city}, ${order.shippingAddress.country}',
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
                        sortKey: (order) => order.createdAt,
                        cellBuilder: (order) => TableTextCell(
                          title:
                              '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                      AppTableColumn<InvoiceModel>(
                        title: TranslationKeys.statusActive.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (order) => order.status.name,
                        cellBuilder: (order) => InkWell(
                          onTap: () => showOrderStatusDialog(context, order),
                          borderRadius: BorderRadius.circular(16),
                          child: TableStatusBadge.fromStatus(order.status.name),
                        ),
                      ),
                      AppTableColumn<InvoiceModel>(
                        title: TranslationKeys.actions.tr(context),
                        width: 70,
                        alignment: Alignment.center,
                        cellBuilder: (order) => TablePopupMenuActions(
                          onView: () => changeScreen(
                            context,
                            OrderDetailsPage(orderId: order.id),
                          ),
                          onEdit: () => showOrderStatusDialog(context, order),
                          onDelete: () {
                            setState(() {
                              provider.invoices.removeWhere(
                                (item) => item.id == order.id,
                              );
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم حذف طلب الفاتورة #${order.id} بنجاح',
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
