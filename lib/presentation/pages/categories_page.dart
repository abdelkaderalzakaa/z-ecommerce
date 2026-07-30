import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
import '../global/core/constants/app_constants.dart';
import '../global/core/responsive/responsive_layout.dart';
import '../widgets/common/headers/header_home.dart';
import '../widgets/common/footer_section.dart';
import '../widgets/common/headers/widgets/breadcrumb.dart';

import '../widgets/categories/categories_header.dart';
import '../widgets/categories/filter_sidebar.dart';
import '../widgets/categories/product_grid.dart';
import '../widgets/categories/pagination.dart';
import '../widgets/categories/filter_modal.dart';
import '../../../data/models/product/category_model.dart';
import '../../../data/models/product/brand_model.dart';
import '../global/translate/app_localizations.dart';
import '../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/categories_page.dart';

class CategoriesPage extends StatelessWidget {
  final CategoryModel? category;
  final BrandModel? brand;
  final bool onSale;
  const CategoriesPage({super.key, this.category, this.brand, this.onSale = false});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: category?.label ?? brand?.name ?? TranslationKeys.allProducts.tr(context),
        paths: [
          TranslationKeys.home.tr(context),
          category?.label ?? brand?.name ?? TranslationKeys.allProducts.tr(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 50, horizontal: hPad),
              child: isMobile
                  ? Column(
                      children: [
                        CategoriesHeader(
                          isMobile: isMobile,
                            onFilterTap: () => showFilterModal(
                              context,
                              categoryLabel: category?.label,
                              brandName: brand?.name,
                            ),
                          title: category?.label ?? brand?.name ?? TranslationKeys.allProducts.tr(context),
                          categoryLabel: category?.label,
                          brandName: brand?.name,
                          onSale: onSale,
                        ),
                        const SizedBox(height: 16),
                        ProductGrid(category: category, brand: brand, onSale: onSale),
                        const SizedBox(height: 24),
                        Pagination(categoryLabel: category?.label, brandName: brand?.name, onSale: onSale),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: FilterSidebar(categoryLabel: category?.label, brandName: brand?.name),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CategoriesHeader(
                                isMobile: isMobile,
                                onFilterTap: () => showFilterModal(
                                  context,
                                  categoryLabel: category?.label,
                                  brandName: brand?.name,
                                ),
                                title: category?.label ?? brand?.name ?? TranslationKeys.allProducts.tr(context),
                                categoryLabel: category?.label,
                                brandName: brand?.name,
                                onSale: onSale,
                              ),
                              const SizedBox(height: 16),
                              ProductGrid(category: category, brand: brand, onSale: onSale),
                              const SizedBox(height: 24),
                              Pagination(categoryLabel: category?.label, brandName: brand?.name, onSale: onSale),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 80),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}
