import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/order/invoice_model.dart';
import 'package:z_ecommerce/data/providers/invoice_provider.dart';
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
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        final allInvoices = provider.invoices.isNotEmpty
            ? provider.invoices
            : null;

        final invoice = allInvoices!.firstWhere(
          (inv) => inv.id == orderId,
          orElse: () => allInvoices.first,
        );

        return DetailsTemplate(
          title: TranslationKeys.orderDetails.tr(context),
          name: '${TranslationKeys.orderId.tr(context)}: ${invoice.id}',
          subtitle:
              '${TranslationKeys.associatedStore.tr(context)}: متجر ${invoice.storeId} • ${invoice.createdAt.year}-${invoice.createdAt.month.toString().padLeft(2, '0')}-${invoice.createdAt.day.toString().padLeft(2, '0')}',
          fallbackIcon: Icons.receipt_long_rounded,
          statusBadge: TableStatusBadge.fromStatus(invoice.status.name),
          headerMetrics: [
            Chip(
              avatar: const Icon(
                Icons.attach_money_rounded,
                size: 16,
                color: Colors.green,
              ),
              label: Text('\$${invoice.total.toStringAsFixed(2)}'),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Chip(
              avatar: const Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: Colors.blue,
              ),
              label: Text(
                '${invoice.items.length} ${TranslationKeys.items.tr(context)}',
              ),
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
                  '${TranslationKeys.editAddress.tr(context)} "${invoice.id}"',
                ),
              ),
            );
          },
          onDelete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${TranslationKeys.deleteSelected.tr(context)} "${invoice.id}"',
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
            OrderOverviewTab(invoice: invoice),
            OrderItemsTab(invoice: invoice),
            OrderShippingTab(invoice: invoice),
          ],
        );
      },
    );
  }
}
