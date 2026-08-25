import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_buisness.dart';
import '../../data/models/order/order_model.dart';
import '../../data/providers/order_provider.dart';
import '../global/core/constants/app_constants.dart';
import '../global/core/responsive/responsive_layout.dart';
import '../widgets/common/headers/header_details.dart';
import '../widgets/common/footers/footer_section.dart';
import '../widgets/cart/cart_item.dart';
import 'package:provider/provider.dart';
import '../../data/providers/business_provider.dart';
import '../global/translate/app_localizations.dart';
import '../global/translate/translation_keys.dart';
import '../../presentation/global/core/constants/enum_data.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/common/address_model.dart';
import '../../data/services/address_service.dart';
import '../widgets/order/order_tracker_widget.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final currency = selectedBusiness.currency.symbol;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.orderDetails.tr(context),
        showBackButton: true,
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
                                  .replaceAll('{id}', order.id),
                              style: AppTextStyles.heroTitle(
                                context,
                                isMobile,
                              ).copyWith(fontSize: 24),
                            ),
                            _StatusBadge(status: order.status),
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
                                ).format(order.createdAt),
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
            FooterBuisness(idBuisness: order.businessId),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context, String currency) {
    return Column(
      children: [
        OrderTrackerWidget(
          order: order,
          currentStatus: order.status,
          isMobile: true,
        ),
        const SizedBox(height: 24),
        _buildAddressCard(context),
        const SizedBox(height: 24),
        _buildItemsCard(context, currency),
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
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 1, 
          child: Column(
            children: [
              OrderTrackerWidget(
                order: order,
                currentStatus: order.status,
                isMobile: false,
              ),
              const SizedBox(height: 24),
              _buildAddressCard(context),
              const SizedBox(height: 24),
              _buildSummaryCard(context, currency),
            ],
          )
        ),
      ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TranslationKeys.shippingAddress.tr(context),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (order.status == OrderStatus.pending)
                TextButton(
                  onPressed: () => _showAddressSelectionDialog(context),
                  child: Text(TranslationKeys.editAddress.tr(context)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (order.shippingAddressSnapshot != null)
            Text(
              order.shippingAddressSnapshot!.getFormattedAddress(),
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            )
          else
            Text(
              TranslationKeys.notAvailable.tr(context),
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddressSelectionDialog(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? '';
    final addresses = userId.isNotEmpty
        ? await AddressService().getAddressesByUserId(userId)
        : <AddressModel>[];

    if (!context.mounted) return;
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TranslationKeys.noSavedAddresses.tr(context))),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TranslationKeys.selectShippingAddress.tr(context),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...addresses.map((address) => ListTile(
                    title: Text(address.title),
                    subtitle: Text(address.getFormattedAddress()),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final success = await context.read<OrderProvider>().updateOrderAddress(order.id, address);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم التحديث بنجاح')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('حدث خطأ أثناء التحديث')),
                        );
                      }
                    },
                  )),
            ],
          ),
        );
      },
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
          if (order.items.isEmpty)
            Center(child: Text(TranslationKeys.notAvailable.tr(context)))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 32, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return CartItemWidget(
                  item: item,
                  isReadOnly: true,
                  isGift: item.unitPrice == 0.0,
                  isBundle: false,
                );
              },
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
            value: '$currency${order.subTotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: TranslationKeys.discount.tr(context),
            value: '-$currency${0.0.toStringAsFixed(2)}', // TODO: order discount if available
            isDiscount: true,
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: TranslationKeys.deliveryFee.tr(context),
            value: '$currency${order.shippingCost.toStringAsFixed(2)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
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
                '$currency${order.storeTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
            const SizedBox(height: 24),
          if (order.status == OrderStatus.pending)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _cancelOrder(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel Order'),
              ),
            ),
        ],
      ),
    );
  }

  void _cancelOrder(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(TranslationKeys.cancel.tr(context)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await context.read<OrderProvider>().updateOrderStatus(order.id, OrderStatus.cancelled);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الإلغاء بنجاح')),
        );
      }
    }
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
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String translatedStatus = status.name;

    switch (status) {
      case OrderStatus.delivered:
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        translatedStatus = TranslationKeys.statusDelivered.tr(context);
        break;
      case OrderStatus.preparing:
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        translatedStatus = TranslationKeys.statusProcessing.tr(context);
        break;
      case OrderStatus.cancelled:
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
