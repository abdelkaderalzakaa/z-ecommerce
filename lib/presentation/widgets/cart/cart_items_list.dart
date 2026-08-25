import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/cart_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'cart_item.dart';

class CartItemsList extends StatelessWidget {
  const CartItemsList({super.key});

  @override
  Widget build(BuildContext context) {
    final businessId = context.read<BusinessProvider>().selectedBusiness.id;
    final cartProvider = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
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
            final matchingProduct = productProvider.allProducts.firstWhere(
              (p) => p.id == item.productId,
              orElse: () => ProductModel.empty(),
            );

            return Column(
              children: [
                CartItemWidget(
                  item: item,
                  product: matchingProduct.isEmpty ? null : matchingProduct,
                  isGift: item.type == CartItemType.gift,
                  isBundle: false,
                  onQuantityChanged: (newQuantity) {
                    cartProvider.updateQuantity(
                      businessId: businessId,
                      itemId: item.id,
                      newQuantity: newQuantity,
                    );
                  },
                  onRemove: () {
                    cartProvider.removeItem(
                      businessId: businessId,
                      itemId: item.id,
                    );
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
