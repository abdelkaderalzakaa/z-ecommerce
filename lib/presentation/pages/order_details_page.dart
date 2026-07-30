import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/order/invoice_model.dart';
import '../global/core/constants/app_constants.dart';
import '../global/core/responsive/responsive_layout.dart';
import '../widgets/common/headers/header_details.dart';
import '../widgets/common/footer_section.dart';
import '../widgets/cart/cart_item.dart';
import 'package:provider/provider.dart';
import '../../data/providers/company_provider.dart';
import '../global/translate/app_localizations.dart';
import '../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/order_details_page.dart';

class OrderDetailsPage extends StatelessWidget {
  final InvoiceModel invoice;

  const OrderDetailsPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final companyData = context.watch<CompanyProvider>().companySettings;
    final currency = companyData?.currency ?? '\$';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.orderDetails.tr(context),
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.profile.tr(context),
          TranslationKeys.orderDetails.tr(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: isMobile ? 24 : 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              TranslationKeys.orderNumber
                                  .tr(context)
                                  .replaceAll('{id}', invoice.invoiceId),
                              style: AppTextStyles.heroTitle(
                                context,
                                isMobile,
                              ).copyWith(fontSize: 24),
                            ),
                            _StatusBadge(status: invoice.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          TranslationKeys.placedOn
                              .tr(context)
                              .replaceAll(
                                '{date}',
                                DateFormat(
                                  'MMMM d, yyyy - h:mm a',
                                ).format(invoice.date),
                              ),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content Layout
                  isMobile
                      ? _buildMobileContent(context, currency)
                      : _buildDesktopContent(context, currency),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context, String currency) {
    return Column(
      children: [
        _buildItemsCard(context, currency),
        const SizedBox(height: 24),
        _buildAddressCard(context),
        const SizedBox(height: 24),
        _buildSummaryCard(context, currency),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context, String currency) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildItemsCard(context, currency),
              const SizedBox(height: 24),
              _buildAddressCard(context),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(flex: 1, child: _buildSummaryCard(context, currency)),
      ],
    );
  }

  Widget _buildItemsCard(BuildContext context, String currency) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.items.tr(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoice.items.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 32, color: AppColors.divider),
            itemBuilder: (context, index) {
              final item = invoice.items[index];
              return CartItemWidget(
                title: item.product.name,
                size:
                    item.selectedSize ??
                    TranslationKeys.defaultText.tr(context),
                color: item.selectedColor != null
                    ? '#${item.selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}'
                    : TranslationKeys.defaultText.tr(context),
                price: item.product.price,
                quantity: item.quantity,
                isReadOnly: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.shippingAddress.tr(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (invoice.shippingAddress.label != null) ...[
            Text(
              invoice.shippingAddress.label!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            '${invoice.shippingAddress.street}\\n${invoice.shippingAddress.city}, ${invoice.shippingAddress.state} ${invoice.shippingAddress.zipCode}\\n${invoice.shippingAddress.country}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String currency) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.orderSummary.tr(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _SummaryRow(
            label: TranslationKeys.subtotal.tr(context),
            value: '$currency${invoice.subTotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: TranslationKeys.discount.tr(context),
            value: '-$currency${invoice.discount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: TranslationKeys.tax.tr(context),
            value: '$currency${invoice.tax.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: TranslationKeys.deliveryFee.tr(context),
            value: '$currency${invoice.shippingCost.toStringAsFixed(2)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: AppColors.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TranslationKeys.total.tr(context),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$currency${invoice.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDiscount ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String translatedStatus = status;

    switch (status) {
      case 'Delivered':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        translatedStatus = TranslationKeys.statusDelivered.tr(context);
        break;
      case 'Processing':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        translatedStatus = TranslationKeys.statusProcessing.tr(context);
        break;
      case 'Cancelled':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        translatedStatus = TranslationKeys.statusCancelled.tr(context);
        break;
      default:
        bgColor = Theme.of(context).cardColor;
        textColor = const Color(0xFF6B6B6B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        translatedStatus,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
