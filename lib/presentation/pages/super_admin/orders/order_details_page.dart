import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/details_template.dart';

import 'order_details_tab/overview_tab.dart';
import 'order_details_tab/items_tab.dart';
import 'order_details_tab/shipping_tab.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final allOrders = provider.allOrders.isNotEmpty
            ? provider.allOrders
            : (provider.businessOrders.isNotEmpty ? provider.businessOrders : provider.customerOrders);

        if (allOrders.isEmpty) {
          return const Scaffold(body: Center(child: Text("No data found")));
        }

        final order = allOrders.firstWhere(
          (o) => o.id == orderId,
          orElse: () => allOrders.first,
        );

        return DetailsTemplate(
          title: TranslationKeys.orderDetails.tr(context),
          name: '${TranslationKeys.orderId.tr(context)}: #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
          subtitle:
              '${TranslationKeys.associatedStore.tr(context)}: متجر ${order.businessId} • ${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')}',
          fallbackIcon: Icons.receipt_long_rounded,
          statusBadge: TableStatusBadge.fromStatus(order.status.name),
          headerMetrics: [
            Chip(
              avatar: const Icon(
                Icons.attach_money_rounded,
                size: 16,
                color: Colors.green,
              ),
              label: Text('\$${order.storeTotal.toStringAsFixed(2)}'),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
          onRefresh: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث بيانات الطلب')),
            );
          },
          onEdit: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${TranslationKeys.editAddress.tr(context)} "${order.id}"',
                ),
              ),
            );
          },
          onDelete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${TranslationKeys.deleteSelected.tr(context)} "${order.id}"',
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
          tabs: [
            Tab(text: TranslationKeys.overviewTab.tr(context)),
            Tab(text: TranslationKeys.orderItems.tr(context)),
            Tab(text: TranslationKeys.shippingAddress.tr(context)),
          ],
          tabViews: [
            OrderOverviewTab(order: order),
            OrderItemsTab(items: order.items),
            OrderShippingTab(order: order),
          ],
        );
      },
    );
  }
}
