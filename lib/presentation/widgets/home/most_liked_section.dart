import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../common/product_card.dart';
import '../../../data/models/product/product_model.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/categories_page.dart';
import 'package:z_ecommerce/data/providers/product_filter_provider.dart';

import 'package:z_ecommerce/data/providers/like_provider.dart';

class MostLikedSection extends StatelessWidget {
  const MostLikedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Consumer3<ProductProvider, BusinessProvider, LikeProvider>(
      builder: (context, productProvider, businessProvider, likeProvider, child) {
        final businessId = businessProvider.selectedBusiness.id;
        final storeProducts = productProvider.allProducts
            .where((p) => p.businessId == businessId)
            .toList();
        
        // Sort by likes
        final mostLikedProducts = List<ProductModel>.from(storeProducts);
        mostLikedProducts.sort((a, b) {
          final aLikes = likeProvider.getLikesCount(a.id);
          final bLikes = likeProvider.getLikesCount(b.id);
          if (bLikes != aLikes) {
            return bLikes.compareTo(aLikes);
          }
          return b.ratings.length.compareTo(a.ratings.length);
        });

        // Only consider products that actually have likes or ratings if you want it strict,
        // but it's fine to just take the top ones.
        final products = mostLikedProducts.take(4).toList();
        if (products.isEmpty) return const SizedBox.shrink();

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: isMobile ? AppSpacing.sectionVerticalMobile : AppSpacing.sectionVertical,
          ),
          child: Column(
            children: [
              SectionHeader(title: Localizations.localeOf(context).languageCode == 'ar' ? 'الأكثر إعجاباً' : 'MOST LIKED'),
              const SizedBox(height: 40),
              isMobile
                  ? _MobileProductGrid(products: products)
                  : _DesktopProductGrid(products: products),
              if (storeProducts.length > 4)
                Column(
                  children: [
                    const SizedBox(height: 36),
                    ViewAllButton(onTap: () {
                      changeScreen(context, const CategoriesPage(initialQuickFilter: QuickFilter.mostLiked));
                    }),
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
    return Row(
      children: products
          .map(
            (p) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ProductCard(
                  product: p,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MobileProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  const _MobileProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => ProductCard(
        product: products[i],
      ),
    );
  }
}


