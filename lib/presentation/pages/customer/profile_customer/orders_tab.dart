import 'package:z_ecommerce/presentation/pages/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import '../../../../data/providers/invoice_provider.dart';
import '../../../../data/providers/business_provider.dart';
import '../../../../data/models/order/invoice_model.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final invoiceProvider = context.watch<InvoiceProvider>();
    final orders = invoiceProvider.invoices.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.orderHistory.tr(context),
          style: AppTextStyles.heroTitle(context, isMobile).copyWith(
            fontSize: 24,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          TranslationKeys.viewYourRecentOrders.tr(context),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        const SizedBox(height: 32),
        
        orders.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      TranslationKeys.noOrdersYet.tr(context),
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TranslationKeys.yourRecentOrdersWillAppearHere.tr(context),
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (context, index) => Divider(color: Theme.of(context).dividerColor, height: 32),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _OrderItem(
                    invoice: order,
                    isMobile: isMobile,
                  );
                },
              ),
      ],
    );
  }
}

class _OrderItem extends StatelessWidget {
  final InvoiceModel invoice;
  final bool isMobile;

  const _OrderItem({
    required this.invoice,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final currency = selectedBusiness?.currency.symbol ?? '\$';

    return isMobile ? _buildMobile(context, currency) : _buildDesktop(context, currency);
  }

  Widget _buildMobile(BuildContext context, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.id,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Store: ${invoice.storeId.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            _StatusBadge(status: invoice.history.isNotEmpty ? invoice.history.last.status.name : 'pending'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMM dd, yyyy').format(invoice.createdAt),
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
            ),
            Text(
              '$currency${invoice.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ViewDetailsButton(invoice: invoice),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context, String currency) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.id,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Store: ${invoice.storeId.toUpperCase()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(invoice.createdAt),
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _StatusBadge(status: invoice.history.isNotEmpty ? invoice.history.last.status.name : 'pending'),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '$currency${invoice.total.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        _ViewDetailsButton(invoice: invoice),
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
    String displayStatus;
    
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        displayStatus = TranslationKeys.statusDelivered.tr(context);
        break;
      case 'Processing':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        displayStatus = TranslationKeys.statusProcessing.tr(context);
        break;
      case 'Cancelled':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        displayStatus = TranslationKeys.statusCancelled.tr(context);
        break;
      default:
        bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
        textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary;
        displayStatus = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ViewDetailsButton extends StatefulWidget {
  final InvoiceModel invoice;
  
  const _ViewDetailsButton({required this.invoice});

  @override
  State<_ViewDetailsButton> createState() => _ViewDetailsButtonState();
}

class _ViewDetailsButtonState extends State<_ViewDetailsButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          changeScreen(context, OrderDetailsPage(invoice: widget.invoice));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: _hovered ? Theme.of(context).primaryColor : Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Text(
            TranslationKeys.viewDetails.tr(context),
            style: TextStyle(
              color: _hovered ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
