import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/orders/order_details_page.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';

class UserOrdersTab extends StatefulWidget {
  final UserModel user;

  const UserOrdersTab({super.key, required this.user});

  @override
  State<UserOrdersTab> createState() => _UserOrdersTabState();
}

class _UserOrdersTabState extends State<UserOrdersTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().listenToCustomerOrders(widget.user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final userOrders = provider.customerOrders;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppDataTable<OrderModel>(
            items: userOrders,
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
                order.id.toLowerCase().contains(q.toLowerCase()),
            emptyMessage: TranslationKeys.noDataAvailable.tr(context),
            columns: [
              AppTableColumn<OrderModel>(
                title: TranslationKeys.orderId.tr(context),
                flex: 2,
                sortable: true,
                sortKey: (order) => order.id,
                cellBuilder: (order) => TableTextCell(
                  title: '#${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
                  subtitle:
                      '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')}',
                  isBold: true,
                ),
              ),
              AppTableColumn<OrderModel>(
                title: TranslationKeys.total.tr(context),
                flex: 1,
                sortable: true,
                sortKey: (order) => order.storeTotal,
                cellBuilder: (order) => TablePriceCell(amount: order.storeTotal),
              ),
              AppTableColumn<OrderModel>(
                title: TranslationKeys.statusActive.tr(context),
                flex: 1,
                sortable: true,
                sortKey: (order) => order.status.name,
                cellBuilder: (order) => TableStatusBadge.fromStatus(order.status.name),
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
