import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
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

  const CategoriesPage({
    super.key,
    this.category,
    this.brand,
    this.onSale = false,
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
        if (widget.category != null || widget.brand != null || widget.onSale) {
          filterProvider.initializeWithDefaults(
            categoryId: widget.category?.id,
            categoryLabel: widget.category?.label,
            brandId: widget.brand?.id,
            brandName: widget.brand?.name,
            onSale: widget.onSale,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    final title = widget.category?.label ??
        widget.brand?.name ??
        TranslationKeys.allProducts.tr(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: title,
        paths: [
          TranslationKeys.home.tr(context),
          title,
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 36, horizontal: hPad),
              child: isMobile
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
            ),
            const SizedBox(height: 60),
            FooterBuisness(
              idBuisness: widget.category?.businessId ??
                  widget.brand?.businessId ??
                  context.read<BusinessProvider>().selectedBusiness.id,
            ),
          ],
        ),
      ),
    );
  }
}
