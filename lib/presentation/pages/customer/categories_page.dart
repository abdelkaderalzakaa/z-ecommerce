import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/top_title.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../widgets/common/footers/footer_buisness.dart';
import '../../widgets/categories/categories_header.dart';
import '../../widgets/categories/filter_sidebar.dart';
import '../../widgets/categories/product_grid.dart';
import '../../widgets/categories/pagination.dart';
import '../../widgets/categories/filter_modal.dart';
import '../../../../data/providers/business_provider.dart';
import '../../../../data/providers/product_filter_provider.dart';
import '../../../../data/models/product/category_model.dart';
import '../../../../data/models/product/brand_model.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class CategoriesPage extends StatefulWidget {
  final CategoryModel? category;
  final BrandModel? brand;
  final bool onSale;
  final QuickFilter? initialQuickFilter;

  const CategoriesPage({
    super.key,
    this.category,
    this.brand,
    this.onSale = false,
    this.initialQuickFilter,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final filterProvider = context.read<ProductFilterProvider>();
        if (widget.category != null || widget.brand != null || widget.onSale || widget.initialQuickFilter != null) {
          filterProvider.initializeWithDefaults(
            categoryId: widget.category?.id,
            categoryLabel: widget.category?.label,
            brandId: widget.brand?.id,
            brandName: widget.brand?.name,
            onSale: widget.onSale,
            initialQuickFilter: widget.initialQuickFilter,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    String title = widget.category?.label ?? widget.brand?.name ?? '';
    if (title.isEmpty) {
      if (widget.initialQuickFilter == QuickFilter.bestSellers) {
        title = TranslationKeys.topSelling.tr(context);
      } else if (widget.initialQuickFilter == QuickFilter.newArrivals) {
        title = TranslationKeys.newArrivals.tr(context);
      } else if (widget.initialQuickFilter == QuickFilter.recommended) {
        title = TranslationKeys.recommended.tr(context);
      } else if (widget.initialQuickFilter == QuickFilter.featured) {
        title = Localizations.localeOf(context).languageCode == 'ar' ? 'المنتجات المميزة' : 'Featured Products';
      } else if (widget.initialQuickFilter == QuickFilter.mostLiked) {
        title = Localizations.localeOf(context).languageCode == 'ar' ? 'الأكثر إعجاباً' : 'Most Liked';
      } else if (widget.onSale || widget.initialQuickFilter == QuickFilter.onSale) {
        title = TranslationKeys.discountedProducts.tr(context);
      } else {
        title = TranslationKeys.allProducts.tr(context);
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(title: title),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopTitle(
              title: title,
              paths: [TranslationKeys.home.tr(context), title],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: hPad),
              child: Column(
                children: [
                  isMobile
                      ? Column(
                          children: [
                            CategoriesHeader(
                              isMobile: isMobile,
                              onFilterTap: () => showFilterModal(
                                context,
                                categoryLabel: widget.category?.label,
                                brandName: widget.brand?.name,
                              ),
                              title: title,
                              categoryLabel: widget.category?.label,
                              brandName: widget.brand?.name,
                              onSale: widget.onSale,
                            ),
                            const SizedBox(height: 16),
                            ProductGrid(
                              category: widget.category,
                              brand: widget.brand,
                              onSale: widget.onSale,
                            ),
                            const SizedBox(height: 24),
                            Pagination(
                              categoryLabel: widget.category?.label,
                              brandName: widget.brand?.name,
                              onSale: widget.onSale,
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: FilterSidebar(
                                categoryLabel: widget.category?.label,
                                brandName: widget.brand?.name,
                              ),
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
                                      categoryLabel: widget.category?.label,
                                      brandName: widget.brand?.name,
                                    ),
                                    title: title,
                                    categoryLabel: widget.category?.label,
                                    brandName: widget.brand?.name,
                                    onSale: widget.onSale,
                                  ),
                                  const SizedBox(height: 16),
                                  ProductGrid(
                                    category: widget.category,
                                    brand: widget.brand,
                                    onSale: widget.onSale,
                                  ),
                                  const SizedBox(height: 24),
                                  Pagination(
                                    categoryLabel: widget.category?.label,
                                    brandName: widget.brand?.name,
                                    onSale: widget.onSale,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            FooterBuisness(
              idBuisness:
                  widget.category?.businessId ??
                  widget.brand?.businessId ??
                  context.read<BusinessProvider>().selectedBusiness.id,
            ),
          ],
        ),
      ),
    );
  }
}
