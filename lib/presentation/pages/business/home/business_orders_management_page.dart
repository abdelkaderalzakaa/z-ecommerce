import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/orders/order_details_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/common/status_dialogs.dart'; 
import 'package:z_ecommerce/presentation/pages/business/orders/store_orders_flow_tab.dart';

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
  bool _isFlowView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().listenToBusinessOrders(widget.businessId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isFlowView) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'مسار تنفيذ وتوصيل الطلبات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.table_chart_outlined, size: 18),
                    label: const Text('عرض جدول الطلبات'),
                    onPressed: () => setState(() => _isFlowView = false),
                  ),
                ],
              ),
            ),
            const Expanded(child: StoreOrdersFlowTab()),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          final filteredOrders = provider.businessOrders.where((order) {
            final matchesStatus =
                _selectedStatusFilter == 'all' ||
                order.status.name.toLowerCase() ==
                    _selectedStatusFilter.toLowerCase();

            return matchesStatus;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TranslationKeys.ordersManagement.tr(context),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.view_kanban_outlined, size: 18),
                      label: const Text('عرض مراحل التنفيذ الحية 🚀'),
                      onPressed: () => setState(() => _isFlowView = true),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // AppDataTable for Store Orders
                Expanded(
                  child: AppDataTable<OrderModel>(
                    items: filteredOrders,
                    selectable: true,
                    showIndexColumn: true,
                    onBulkDelete: (selected) {
                      // Handled by backend in a real app
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${TranslationKeys.deleteSelected.tr(context)} (${selected.length})',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    searchMatcher: (order, q) =>
                        order.id.toLowerCase().contains(q) ||
                        (order.shippingAddressSnapshot?.title.toLowerCase().contains(q) ?? false),
                    onFilterTap: () => _showFilterDialog(context),
                    emptyMessage: TranslationKeys.noDataAvailable.tr(context),
                    onRowTap: (order) => changeScreen(
                      context,
                      OrderDetailsPage(orderId: order.id),
                    ),
                    columns: [
                      AppTableColumn<OrderModel>(
                        title: TranslationKeys.orderNumber.tr(context),
                        flex: 2,
                        sortable: true,
                        sortKey: (order) => order.id,
                        cellBuilder: (order) => TableImageTextCell(
                          title: '#${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
                          subtitle: order.shippingAddressSnapshot?.title ?? '',
                          fallbackIcon: Icons.receipt_long_rounded,
                        ),
                      ),
                      AppTableColumn<OrderModel>(
                        title: TranslationKeys.total.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (order) => order.storeTotal,
                        cellBuilder: (order) => TablePriceCell(
                          amount: order.storeTotal,
                        ),
                      ),
                      AppTableColumn<OrderModel>(
                        title: TranslationKeys.orderDate.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (order) => order.createdAt,
                        cellBuilder: (order) => TableTextCell(
                          title:
                              '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                      AppTableColumn<OrderModel>(
                        title: TranslationKeys.statusActive.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (order) => order.status.name,
                        cellBuilder: (order) => InkWell(
                          // Need to pass order into dialog or similar if you edit status
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16),
                          child: TableStatusBadge.fromStatus(order.status.name),
                        ),
                      ),
                      AppTableColumn<OrderModel>(
                        title: TranslationKeys.actions.tr(context),
                        width: 70,
                        alignment: Alignment.center,
                        cellBuilder: (order) => TablePopupMenuActions(
                          onView: () => changeScreen(
                            context,
                            OrderDetailsPage(orderId: order.id),
                          ),
                          onEdit: () {},
                          onDelete: () {
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
