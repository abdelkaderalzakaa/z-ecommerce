import 'package:z_ecommerce/presentation/pages/cart_page.dart';
import 'package:z_ecommerce/presentation/pages/product_details_page.dart';
import 'package:flutter/material.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../../data/models/product/product_model.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/company_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          changeScreen(context, ProductDetailsPage(product: widget.product));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImagePlaceholder(
                product: widget.product,
                bgColor: widget.product.cardBgColor,
                hovered: _hovered,
                discountPercent: widget.product.discountPercent,
              ),
              const SizedBox(height: 12),
              _ProductInfo(
                name: widget.product.name,
                price: widget.product.price,
                originalPrice: widget.product.originalPrice,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  final Product product;
  final Color bgColor;
  final bool hovered;
  final int? discountPercent;

  const _ProductImagePlaceholder({
    required this.product,
    required this.bgColor,
    required this.hovered,
    this.discountPercent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 260,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: hovered
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
          width: hovered ? 1.5 : 1.0,
        ),
        boxShadow: hovered
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),
          if (discountPercent != null)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.discountBadge,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Text(
                  '-$discountPercent%',
                  style: AppTextStyles.discountBadge(context),
                ),
              ),
            ),
          Positioned(
            top: 12,
            right: 12,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final isFavorite =
                    authProvider.currentUser?.wishlist.contains(product.id) ??
                    false;

                return GestureDetector(
                  onTap: () {
                    if (authProvider.isAuthenticated) {
                      authProvider.toggleWishlist(product.id);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            TranslationKeys.pleaseLoginToSaveItems.tr(context),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Consumer2<CartProvider, CompanyProvider>(
              builder: (context, cartProvider, companyProvider, child) {
                final businessId =
                    companyProvider.companySettings?.id ?? 'cmp_001';
                final isInCart = cartProvider
                    .items(businessId)
                    .any((item) => item.product.id == product.id);
                return GestureDetector(
                  onTap: () {
                    if (isInCart) {
                      changeScreen(context, const CartPage());
                    } else {
                      cartProvider.addToCart(
                        businessId,
                        product,
                        selectedColor: product.colors.isNotEmpty
                            ? product.colors.first
                            : null,
                        selectedSize: product.sizes.isNotEmpty
                            ? product.sizes.first
                            : null,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Item added to cart'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'View Cart',
                            onPressed: () =>
                                changeScreen(context, const CartPage()),
                          ),
                        ),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isInCart
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isInCart ? Icons.check : Icons.add_shopping_cart,
                      size: 20,
                      color: isInCart
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final String name;
  final double price;
  final double? originalPrice;

  const _ProductInfo({
    required this.name,
    required this.price,
    this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: AppTextStyles.productName(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        _PriceRow(price: price, originalPrice: originalPrice),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final double price;
  final double? originalPrice;

  const _PriceRow({required this.price, this.originalPrice});

  @override
  Widget build(BuildContext context) {
    final companyData = context.watch<CompanyProvider>().companySettings;
    final currency = companyData?.currency ?? '\$';

    return Row(
      children: [
        Text(
          '$currency${price.toInt()}',
          style: AppTextStyles.priceStyle(context),
        ),
        if (originalPrice != null) ...[
          const SizedBox(width: 10),
          Text(
            '$currency${originalPrice!.toInt()}',
            style: AppTextStyles.priceStrike(context),
          ),
        ],
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? viewAllLabel;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.viewAllLabel,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.sectionTitle(
            context,
            ResponsiveLayout.isMobile(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ViewAllButton extends StatelessWidget {
  final VoidCallback onTap;
  const ViewAllButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(TranslationKeys.viewAll.tr(context)),
    );
  }
}
