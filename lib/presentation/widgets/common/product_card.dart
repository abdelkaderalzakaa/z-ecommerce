import 'package:z_ecommerce/presentation/widgets/common/custom_network_image.dart';
import 'package:z_ecommerce/presentation/pages/customer/cart/cart_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/product_details_page.dart';
import 'package:flutter/material.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../../data/models/product/product_model.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/data/providers/like_provider.dart';
import 'package:z_ecommerce/data/models/shared/like_model.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;

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
      child: InkWell(
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
                bgColor: Theme.of(context).cardColor,
                hovered: _hovered,
                discountPercent: widget.product.discountPercent,
              ),
              const SizedBox(height: 12),
              _ProductInfo(
                product: widget.product,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  final ProductModel product;
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
    final String? imageUrl = (product.thumbnail != null && product.thumbnail!.isNotEmpty)
        ? product.thumbnail
        : (product.images.isNotEmpty ? product.images.first : null);

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
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card - 1),
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? CustomNetworkImage(imageUrl: 
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                    ),
            ),
          ),
          if (discountPercent != null && discountPercent! > 0)
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
          if (product.isRecommended)
            Positioned(
              top: (discountPercent != null && discountPercent! > 0) ? 44 : 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      TranslationKeys.recommended.tr(context),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (context.watch<BusinessProvider>().selectedBusiness.allowLikes)
            Positioned(
              top: 12,
              right: 12,
              child: Consumer2<AuthProvider, LikeProvider>(
              builder: (context, authProvider, likeProvider, child) {
                final isFavorite = likeProvider.hasLiked(product.id);

                return InkWell(
                  onTap: () async {
                    if (authProvider.isAuthenticated) {
                      final like = LikeModel(
                        id: '',
                        userId: authProvider.currentUser!.id,
                        targetId: product.id,
                        targetType: 'product',
                        createdAt: DateTime.now(),
                      );
                      await likeProvider.toggleLike(like);
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
            child: Consumer2<CartProvider, BusinessProvider>(
              builder: (context, cartProvider, businessProvider, child) {
                final businessId = businessProvider.selectedBusiness.id;
                final isInCart = cartProvider
                    .items(businessId)
                    .any((item) => item.productId == product.id);
                return InkWell(
                  onTap: () {
                    if (isInCart) {
                      changeScreen(context, const CartPage());
                    } else {
                      cartProvider.addProductToCart(
                      businessId: businessId,
                      product: product,
                    );
                    }
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
  final ProductModel product;

  const _ProductInfo({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: AppTextStyles.productName(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        _PriceRow(
          isFree: product.isFreeProduct || product.basePrice == 0,
          price: product.basePrice,
          originalPrice: product.originalPrice,
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final bool isFree;
  final double price;
  final double? originalPrice;

  const _PriceRow({
    required this.isFree,
    required this.price,
    this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    if (isFree) {
      return Text(
        TranslationKeys.free.tr(context),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final currency = selectedBusiness.currency.symbol;

    return Row(
      children: [
        Text(
          '$currency${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}',
          style: AppTextStyles.priceStyle(context),
        ),
        if (originalPrice != null && originalPrice! > price) ...[
          const SizedBox(width: 10),
          Text(
            '$currency${originalPrice!.toStringAsFixed(originalPrice!.truncateToDouble() == originalPrice ? 0 : 2)}',
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
