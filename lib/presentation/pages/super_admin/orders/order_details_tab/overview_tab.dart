import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/order/invoice_model.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class OrderOverviewTab extends StatelessWidget {
  final InvoiceModel invoice;

  const OrderOverviewTab({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Financial Summary Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TranslationKeys.orderSummary.tr(context),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _buildPriceRow(context, TranslationKeys.subtotal.tr(context), invoice.subTotal),
                  const Divider(),
                  _buildPriceRow(context, TranslationKeys.discount.tr(context), -invoice.discount),
                  const Divider(),
                  _buildPriceRow(context, TranslationKeys.tax.tr(context), invoice.tax),
                  const Divider(),
                  _buildPriceRow(context, TranslationKeys.deliveryFee.tr(context), invoice.shippingCost),
                  const Divider(),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TranslationKeys.total.tr(context),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${invoice.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Order Meta Info Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'معلومات وتاريخ الطلب',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _buildMetaRow(context, TranslationKeys.orderNumber.tr(context), invoice.invoiceId),
                  const Divider(),
                  _buildMetaRow(context, TranslationKeys.associatedStore.tr(context), 'متجر ${invoice.storeId}'),
                  const Divider(),
                  _buildMetaRow(
                    context,
                    TranslationKeys.placedOn.tr(context),
                    '${invoice.date.year}-${invoice.date.month.toString().padLeft(2, '0')}-${invoice.date.day.toString().padLeft(2, '0')}',
                  ),
                  const Divider(),
                  _buildMetaRow(context, TranslationKeys.statusActive.tr(context), invoice.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, double amount) {
    final theme = Theme.of(context);
    final isNegative = amount < 0;
    final formatted = isNegative
        ? '-\$${amount.abs().toStringAsFixed(2)}'
        : '\$${amount.toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color),
          ),
          Text(
            formatted,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isNegative ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
