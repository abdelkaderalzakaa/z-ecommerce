import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../../data/providers/company_provider.dart';
import '../../../../data/providers/offer_provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import '../../global/router/app_routes.dart';

class OrderSummary extends StatefulWidget {
  final bool isCheckoutPage;
  final VoidCallback? onCheckout;
  final int multiplier;

  const OrderSummary({
    super.key,
    this.isCheckoutPage = false,
    this.onCheckout,
    this.multiplier = 1,
  });

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final companyData = context.watch<CompanyProvider>().companySettings;
    final currency = companyData?.currency ?? '\$';

    final companyId = companyData?.id ?? 'cmp_001';
    final cartProvider = context.watch<CartProvider>();
    final offerProvider = context.watch<OfferProvider>();

    final baseSubtotal = cartProvider.subTotal(companyId);
    final cartProductIds = cartProvider.items(companyId).map((e) => e.product.id).toList();

    final baseDiscount = offerProvider.calculateDiscount(
      companyId,
      baseSubtotal,
      cartProductIds,
      cartProvider.couponCode(companyId),
    );
    final isFreeShipping = offerProvider.hasFreeShipping(companyId, baseSubtotal);

    final baseDeliveryFee = (baseSubtotal > 0 && !isFreeShipping)
        ? (companyData?.deliveryFee ?? 15.0)
        : 0.0;

    final subtotal = baseSubtotal * widget.multiplier;
    var discount = baseDiscount * widget.multiplier;
    if (discount > subtotal) {
      discount = subtotal;
    }
    final deliveryFee = baseDeliveryFee * widget.multiplier;
    final total = subtotal - discount + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.orderSummary.tr(context),
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: TranslationKeys.couponCode.tr(context),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                ),
                onPressed: () {
                  if (_couponController.text.isNotEmpty) {
                    cartProvider.applyCoupon(companyId, _couponController.text);
                  }
                },
                child: Text(
                  TranslationKeys.notAvailable.tr(context) == 'not_available'
                      ? 'Apply'
                      : 'تطبيق',
                ),
              ),
            ],
          ),
          if (cartProvider.couponCode(companyId) != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Coupon ${cartProvider.couponCode(companyId)} applied',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      cartProvider.applyCoupon(companyId, null);
                      _couponController.clear();
                    },
                    child: const Icon(Icons.close, color: Colors.red, size: 16),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          if (widget.multiplier > 1) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      TranslationKeys.pricingMultiplied
                          .tr(context)
                          .replaceAll('{multiplier}', '${widget.multiplier}'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _SummaryRow(
            label: TranslationKeys.subtotal.tr(context),
            value: '$currency${subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 20),
          _SummaryRow(
            label: TranslationKeys.discount.tr(context),
            value: '-$currency${discount.toStringAsFixed(0)}',
            isValueRed: true,
          ),
          const SizedBox(height: 20),
          _SummaryRow(
            label: TranslationKeys.deliveryFee.tr(context),
            value: isFreeShipping
                ? 'Free'
                : '$currency${deliveryFee.toStringAsFixed(0)}',
            isValueRed: isFreeShipping,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Theme.of(context).dividerColor, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TranslationKeys.total.tr(context),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                '$currency${total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _CheckoutButton(
            isCheckoutPage: widget.isCheckoutPage,
            onTap: cartProvider.items(companyId).isEmpty
                ? null
                : (widget.onCheckout ??
                    () {
                      final cid = context
                              .read<CompanyProvider>()
                              .companySettings
                              ?.id ??
                          'cmp_001';
                      context.go(AppRoutes.toCheckout(cid));
                    }),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isValueRed;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isValueRed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final fontSize = isMobile ? 16.0 : 20.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: isValueRed
                ? AppColors.discountText
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final bool isCheckoutPage;
  final VoidCallback? onTap;

  const _CheckoutButton({required this.isCheckoutPage, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          isCheckoutPage ? Icons.check : Icons.arrow_forward,
          size: 20,
        ),
        label: Text(
          isCheckoutPage
              ? TranslationKeys.placeOrder.tr(context)
              : TranslationKeys.goToCheckout.tr(context),
        ),
      ),
    );
  }
}
