import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'cart_item.dart';
import '../../../../data/providers/company_provider.dart';

class CartItemsList extends StatelessWidget {
  const CartItemsList({super.key});

  String _colorToHex(BuildContext context, Color? color) {
    if (color == null) return TranslationKeys.notAvailable.tr(context);
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final businessId =
        context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001';
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items(businessId);

    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Theme.of(context).dividerColor,
              ),
              const SizedBox(height: 16),
              Text(
                TranslationKeys.yourCartIsEmpty.tr(context),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                TranslationKeys.cartEmptySubtitle.tr(context),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];
            return Column(
              children: [
                CartItemWidget(
                  title: item.product.name,
                  size:
                      item.selectedSize ??
                      TranslationKeys.notAvailable.tr(context),
                  color: _colorToHex(context, item.selectedColor),
                  price: item.isGift ? 0.0 : item.product.price,
                  quantity: item.quantity,
                  isGift: item.isGift,
                  isBundle: item.isBundle,
                  onQuantityChanged: (newQuantity) {
                    cartProvider.updateQuantity(
                      businessId,
                      item.id,
                      newQuantity,
                    );
                  },
                  onRemove: () {
                    cartProvider.removeFromCart(businessId, item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          TranslationKeys.itemRemovedFromCart.tr(context),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                if (index < items.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Divider(
                      color: Theme.of(context).dividerColor,
                      height: 1,
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
