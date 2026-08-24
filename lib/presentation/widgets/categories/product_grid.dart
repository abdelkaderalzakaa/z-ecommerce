import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../common/product_card.dart';
import '../../../data/models/product/category_model.dart';
import '../../../data/models/product/brand_model.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/product_filter_provider.dart';
import '../../../data/providers/like_provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class ProductGrid extends StatelessWidget {
  final CategoryModel? category;
  final BrandModel? brand;
  final bool onSale;

  const ProductGrid({
    super.key,
    this.category,
    this.brand,
    this.onSale = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final theme = Theme.of(context);

    // Grid column count based on breakpoint
    int crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 3);

    return Consumer4<ProductProvider, ProductFilterProvider, LikeProvider, BusinessProvider>(
      builder: (context, productProvider, filterProvider, likeProvider, businessProvider, child) {
        final selectedBusinessId = businessProvider.selectedBusiness.id;
        
        final baseProducts = selectedBusinessId.isNotEmpty
            ? productProvider.customerAllProducts.where((p) => p.businessId == selectedBusinessId).toList()
            : productProvider.customerAllProducts;

        final products = filterProvider.getFilteredProducts(
          baseProducts,
          likeProvider: likeProvider,
        );

        if (products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.filter_alt_off_outlined,
                      size: 56,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    TranslationKeys.noMatchingProducts.tr(context),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    TranslationKeys.noMatchingProductsSubtitle.tr(context),
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
                          Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (filterProvider.hasActiveFilters) ...[
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => filterProvider.clearAllFilters(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(TranslationKeys.clearFilters.tr(context)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 24,
            crossAxisSpacing: isMobile ? 12 : 24,
            childAspectRatio: isMobile ? 0.62 : 0.65,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
            );
          },
        );
      },
    );
  }
}
