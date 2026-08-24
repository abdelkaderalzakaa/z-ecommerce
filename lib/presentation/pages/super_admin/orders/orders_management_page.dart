import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
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
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().listenToAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final allOrders = provider.allOrders;

        final filteredOrders = allOrders.where((order) {
          final matchesStatus =
              _selectedStatusFilter == 'all' ||
              order.status.name.toLowerCase() ==
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
                // Full Height Expanded AppDataTable for OrderModel
                Expanded(
                  child: AppDataTable<OrderModel>(
                    items: filteredOrders,
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
                    searchMatcher: (order, q) =>
                        order.id.toLowerCase().contains(q) ||
                        order.businessId.toLowerCase().contains(q),
                    onFilterTap: () => _showFilterDialog(context),
                    emptyMessage: TranslationKeys.noDataAvailable.tr(context),
                    onRowTap: (order) => changeScreen(
                      context,
                      OrderDetailsPage(orderId: order.id),
                    ),
                    columns: [
                      AppTableColumn<OrderModel>(
                        title: TranslationKeys.orderId.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (order) => order.id,
                        cellBuilder: (order) =>
                            TableTextCell(title: '#${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}', isBold: true),
                      ),
                      AppTableColumn<OrderModel>(
                        title: TranslationKeys.store.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (order) => order.businessId,
                        cellBuilder: (order) => TableImageTextCell(
                          title:
                              '${TranslationKeys.store.tr(context)} ${order.businessId}',
                          fallbackIcon: Icons.storefront_rounded,
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
                        sortKey: (order) => order.status.index,
                        cellBuilder: (order) => InkWell(
                          onTap: () {}, // Handled differently if needed
                          borderRadius: BorderRadius.circular(16),
                          child: TableStatusBadge.fromStatus(
                            order.status == OrderStatus.pending
                                ? TranslationKeys.statusPending.tr(context)
                                : (order.status == OrderStatus.confirmed
                                      ? TranslationKeys.statusPaid.tr(context)
                                      : TranslationKeys.statusCompleted.tr(
                                          context,
                                        )),
                          ),
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
                                  '${TranslationKeys.deleteSelected.tr(context)} #${order.id}',
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
