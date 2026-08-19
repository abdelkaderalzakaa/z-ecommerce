import 'package:flutter/material.dart';
import '../../global/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'quantity_selector.dart';

class CartItemWidget extends StatelessWidget {
  final String title;
  final String size;
  final String color;
  final double price;
  final int quantity;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onRemove;
  final bool isReadOnly;
  final bool isGift;
  final bool isBundle;

  const CartItemWidget({
    super.key,
    required this.title,
    required this.size,
    required this.color,
    required this.price,
    required this.quantity,
    this.onQuantityChanged,
    this.onRemove,
    this.isReadOnly = false,
    this.isGift = false,
    this.isBundle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final imageSize = isMobile ? 100.0 : 124.0;
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final currency = selectedBusiness.currency.symbol;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 40,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            constraints: BoxConstraints(minHeight: imageSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isGift)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Free Gift',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (isBundle)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Bundle Offer',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            '${TranslationKeys.size.tr(context)}: $size',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${TranslationKeys.color.tr(context)}: $color',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isReadOnly)
                      InkWell(
                        onTap: onRemove,
                        child: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 24,
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currency${price.toInt()}',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    if (!isReadOnly && !isGift)
                      QuantitySelector(
                        initialQuantity: quantity,
                        onChanged: onQuantityChanged ?? (val) {},
                      )
                    else if (isGift)
                      Text(
                        '${TranslationKeys.qty.tr(context)}: $quantity',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
