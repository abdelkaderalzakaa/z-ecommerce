import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/product_filter_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/categories_page.dart';
import '../common/product_card.dart';

class DiscountedProductsSection extends StatelessWidget {
  const DiscountedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Consumer2<ProductProvider, BusinessProvider>(
      builder: (context, productProvider, businessProvider, child) {
        final business = businessProvider.selectedBusiness;
        if (!business.allowOffers) return const SizedBox.shrink();

        final businessId = business.id;
        final validProducts = productProvider.getCustomerProductsForStore(businessId);

        final discountedProducts = validProducts.where((p) {
          return p.activeDiscount != null ||
              p.offers.isNotEmpty ||
              (p.discountPercent != null && p.discountPercent! > 0);
        }).toList();

        final products = discountedProducts.take(4).toList();
        if (products.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: isMobile
                ? AppSpacing.sectionVerticalMobile
                : AppSpacing.sectionVertical,
          ),
          child: Column(
            children: [
              SectionHeader(
                title: TranslationKeys.discountedProducts
                    .tr(context)
                    .toUpperCase(),
              ),
              const SizedBox(height: 40),
              isMobile
                  ? _MobileProductGrid(products: products)
                  : _DesktopProductGrid(products: products),
              if (discountedProducts.length > 4)
                Column(
                  children: [
                    const SizedBox(height: 36),
                    ViewAllButton(
                      onTap: () {
                        changeScreen(
                          context,
                          const CategoriesPage(
                            initialQuickFilter: QuickFilter.onSale,
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
