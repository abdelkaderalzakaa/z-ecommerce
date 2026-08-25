import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/order/cart_model.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/product_variant.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/cart_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/common/custom_network_image.dart';
import 'quantity_selector.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final ProductModel? product;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onRemove;
  final bool isReadOnly;
  final bool isGift;
  final bool isBundle;

  const CartItemWidget({
    super.key,
    required this.item,
    this.product,
    this.onQuantityChanged,
    this.onRemove,
    this.isReadOnly = false,
    this.isGift = false,
    this.isBundle = false,
  });

  void _openVariantPicker(BuildContext context) {
    if (product == null || product!.variants.length <= 1) return;

    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final businessId = context.read<BusinessProvider>().selectedBusiness.id;
    final cartProvider = context.read<CartProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'تغيير خيارات المنتج' : 'Change Product Options',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.productName ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: product!.variants.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) {
                      final variant = product!.variants[index];
                      final isSelected = item.selectedVariant == variant ||
                          (item.selectedVariant != null &&
                              item.selectedVariant!.variantKey == variant.variantKey);
                      final variantPrice = product!.getPriceForVariant(variant);

                      return InkWell(
                        onTap: () {
                          cartProvider.updateItemVariant(
                            businessId: businessId,
                            itemId: item.id,
                            newVariant: variant,
                            newPrice: variantPrice,
                          );
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isAr ? 'تم تحديث خيارات المنتج' : 'Option updated successfully',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor.withOpacity(0.08)
                                : Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).dividerColor.withOpacity(0.2),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      variant.name.isNotEmpty
                                          ? variant.name
                                          : (variant.variantKey.isNotEmpty
                                              ? variant.variantKey
                                                  .replaceAll('|', ' - ')
                                                  .replaceAll(':', ': ')
                                              : (isAr ? 'الخيار الافتراضي' : 'Default Option')),
                                      style: TextStyle(
                                        fontWeight:
                                            isSelected ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (variant.stock > 0)
                                      Text(
                                        isAr
                                            ? 'المتوفر: ${variant.stock}'
                                            : 'Stock: ${variant.stock}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${variantPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final imageSize = isMobile ? 90.0 : 110.0;
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final currency = selectedBusiness.currency.symbol;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final variant = item.selectedVariant;
    final List<String> variantDetails = [];
    if (variant != null) {
      if (variant.size != null) {
        variantDetails.add('${TranslationKeys.size.tr(context)}: ${variant.size!.name}');
      }
      if (variant.color != null) {
        variantDetails.add('${TranslationKeys.color.tr(context)}: ${variant.color!.name}');
      }
      if (variant.weight != null && variant.weight! > 0) {
        variantDetails.add('${variant.weight} ${variant.weightUnit?.name ?? ''}');
      }
      if (variant.name.isNotEmpty && !variantDetails.contains(variant.name)) {
        variantDetails.add(variant.name);
      }
    }

    final hasMultipleVariants = product != null && product!.variants.length > 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image Thumbnail
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: (item.productImage != null && item.productImage!.isNotEmpty)
                ? CustomNetworkImage(
                    imageUrl: item.productImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 32,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 32,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
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
                            item.productName ?? item.offerName ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
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
                          if (variantDetails.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: variantDetails.map((detail) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor.withOpacity(0.15),
                                    ),
                                  ),
                                  child: Text(
                                    detail,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          if (hasMultipleVariants && !isReadOnly) ...[
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _openVariantPicker(context),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.tune_rounded,
                                      size: 14,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isAr ? 'تغيير الخيارات' : 'Change Options',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isReadOnly)
                      InkWell(
                        onTap: onRemove,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currency${item.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    if (!isReadOnly && !isGift)
                      QuantitySelector(
                        initialQuantity: item.quantity,
                        onChanged: onQuantityChanged ?? (val) {},
                      )
                    else if (isGift)
                      Text(
                        '${TranslationKeys.qty.tr(context)}: ${item.quantity}',
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
