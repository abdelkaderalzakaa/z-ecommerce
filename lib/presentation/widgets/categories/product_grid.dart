import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../common/product_card.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/brand_model.dart';
import '../../../data/providers/product_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class ProductGrid extends StatelessWidget {
  final CategoryModel? category;
  final BrandModel? brand;
  final bool onSale;
  const ProductGrid({super.key, this.category, this.brand, this.onSale = false});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    // Grid column count based on breakpoint
    int crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 3);

    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final products = provider.getPaginatedProducts(category?.label, brand: brand?.name, onSale: onSale);

        if (products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                TranslationKeys.noProductsFound.tr(context),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
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
        childAspectRatio: isMobile ? 0.65 : 0.65, // Adjust based on card content height
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
