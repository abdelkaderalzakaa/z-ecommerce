import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/order/invoice_model.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class OrderShippingTab extends StatelessWidget {
  final InvoiceModel invoice;

  const OrderShippingTab({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = invoice.shippingAddress;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.shippingAddress.tr(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.location_on_rounded, color: theme.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        address.label ?? 'عنوان الشحن',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAddressRow(context, TranslationKeys.streetAddress.tr(context), address.street),
                  const Divider(),
                  _buildAddressRow(context, TranslationKeys.city.tr(context), address.city),
                  const Divider(),
                  _buildAddressRow(context, TranslationKeys.state.tr(context), address.state),
                  const Divider(),
                  _buildAddressRow(context, TranslationKeys.zipCode.tr(context), address.zipCode),
                  const Divider(),
                  _buildAddressRow(context, TranslationKeys.country.tr(context), address.country),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(BuildContext context, String label, String value) {
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
