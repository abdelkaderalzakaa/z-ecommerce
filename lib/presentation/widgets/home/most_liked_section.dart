import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/like_provider.dart';
import 'package:z_ecommerce/data/providers/product_filter_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/pages/customer/categories_page.dart';
import '../common/product_card.dart';

class MostLikedSection extends StatelessWidget {
  const MostLikedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Consumer3<ProductProvider, BusinessProvider, LikeProvider>(
      builder: (context, productProvider, businessProvider, likeProvider, child) {
        final business = businessProvider.selectedBusiness;
        if (!business.allowLikes) return const SizedBox.shrink();

        final businessId = business.id;
        final validProducts = productProvider.getCustomerProductsForStore(businessId);

        // Sort by likes
        final mostLikedProducts = List<ProductModel>.from(validProducts);
        mostLikedProducts.sort((a, b) {
          final aLikes = likeProvider.getLikesCount(a.id);
          final bLikes = likeProvider.getLikesCount(b.id);
          if (bLikes != aLikes) {
            return bLikes.compareTo(aLikes);
          }
          return b.ratings.length.compareTo(a.ratings.length);
        });

        final products = mostLikedProducts.take(4).toList();
        if (products.isEmpty) return const SizedBox.shrink();

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: isMobile
                ? AppSpacing.sectionVerticalMobile
                : AppSpacing.sectionVertical,
          ),
          child: Column(
            children: [
              SectionHeader(
                title: Localizations.localeOf(context).languageCode == 'ar'
                    ? 'الأكثر إعجاباً'
                    : 'MOST LIKED',
              ),
              const SizedBox(height: 40),
              isMobile
                  ? _MobileProductGrid(products: products)
                  : _DesktopProductGrid(products: products),
              if (mostLikedProducts.length > 4)
                Column(
                  children: [
                    const SizedBox(height: 36),
                    ViewAllButton(
                      onTap: () {
                        changeScreen(
                          context,
                          const CategoriesPage(
                            initialQuickFilter: QuickFilter.mostLiked,
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopProductGrid extends StatelessWidget {
  final List<ProductModel> products;

  const _DesktopProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 1100) crossAxisCount = 3;
        if (constraints.maxWidth < 750) crossAxisCount = 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.72,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) =>
              ProductCard(product: products[index]),
        );
      },
    );
  }
}

class _MobileProductGrid extends StatelessWidget {
  final List<ProductModel> products;

  const _MobileProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (ctx, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 170,
            child: ProductCard(product: products[index]),
          );
        },
      ),
    );
  }
}
