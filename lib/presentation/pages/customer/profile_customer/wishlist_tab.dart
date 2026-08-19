import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/shared/like_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/like_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/product_details_page.dart';

class WishlistTab extends StatelessWidget {
  const WishlistTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final likeProvider = context.watch<LikeProvider>();
    final userLikesIds = likeProvider.userLikes
        .where((l) => l.targetType == 'product')
        .map((l) => l.targetId)
        .toList();

    final allProducts = context.watch<ProductProvider>().allProducts;
    final favoriteProducts = allProducts.where((p) => userLikesIds.contains(p.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.myWishlist.tr(context),
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isAr
              ? 'المنتجات المميزة والمفضلة التي قمت بحفظها للشراء لاحقاً'
              : 'Products you have liked and saved for later purchase',
          style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
        ),
        const SizedBox(height: 28),

        if (favoriteProducts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: theme.primaryColor.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  TranslationKeys.yourWishlistIsEmpty.tr(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  TranslationKeys.tapHeartToSave.tr(context),
                  style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isMobile ? 1.1 : 1.15,
            ),
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              return _WishlistProductCard(product: favoriteProducts[index]);
            },
          ),
      ],
    );
  }
}

class _WishlistProductCard extends StatelessWidget {
  final ProductModel product;

  const _WishlistProductCard({required this.product});

  void _visitProduct(BuildContext context) {
    changeScreen(context, ProductDetailsPage(product: product));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final currency = selectedBusiness.currency.symbol;

    final name = product.name;
    final description = product.description;

    final hasRatings = product.ratings.isNotEmpty;
    final double avgRating = hasRatings
        ? (product.ratings.map((r) => r.rating).reduce((a, b) => a + b) / product.ratings.length)
        : 0.0;
    final String ratingDisplay = hasRatings ? avgRating.toStringAsFixed(1) : (isAr ? 'جديد' : 'New');

    final mainImage = product.images.firstOrNull ?? product.thumbnail ?? '';
    final price = product.variants.firstOrNull?.price ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Thumbnail Image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                    image: (mainImage.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(mainImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: mainImage.isEmpty
                      ? Icon(
                          Icons.inventory_2_outlined,
                          color: theme.primaryColor,
                          size: 32,
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Name & Heart Toggle & Price Stack
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Heart Like Toggle Button
                          Consumer2<AuthProvider, LikeProvider>(
                            builder: (context, authProvider, likeProvider, child) {
                              final isLiked = likeProvider.hasLiked(product.id);
                              return IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : AppColors.textMuted,
                                  size: 22,
                                ),
                                onPressed: () async {
                                  if (authProvider.isAuthenticated) {
                                    final like = LikeModel(
                                      id: '',
                                      userId: authProvider.currentUser!.id,
                                      targetId: product.id,
                                      targetType: 'product',
                                      createdAt: DateTime.now(),
                                    );
                                    await likeProvider.toggleLike(like);
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Rating & Price Badge
                      Row(
                        children: [
                          Icon(
                            hasRatings ? Icons.star : Icons.new_releases_outlined,
                            color: hasRatings ? AppColors.star : theme.primaryColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ratingDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${price.toStringAsFixed(2)} $currency",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description truncated to 2 lines max (التفاصيل خطين)
            Text(
              description.isNotEmpty ? description : "---",
              style: AppTextStyles.bodyText(context).copyWith(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Visit Product Button (زر زيادة/عرض المنتج)
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ButtonApp(
                label: 'زيارة المنتج',
                icon: Icons.arrow_forward_rounded,
                fontSize: 12,
                onPressed: () => _visitProduct(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
