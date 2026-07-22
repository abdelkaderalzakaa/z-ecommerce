import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/company_provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../common/product_card.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import '../../global/router/app_routes.dart';
import '../../../data/models/product_model.dart';

class DiscountedProductsSection extends StatelessWidget {
  const DiscountedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final products = provider.discountedProducts.take(4).toList();
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
              const SizedBox(height: 36),
              ViewAllButton(
                onTap: () {
                  final cid =
                      context.read<CompanyProvider>().companySettings?.id ??
                      'cmp_001';
                  context.go(
                    AppRoutes.toShop(cid, onSale: true),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopProductGrid extends StatelessWidget {
  final List<Product> products;
  const _DesktopProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: products
          .map(
            (p) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: products.last == p ? 0 : 20, // spacing between cards
                ),
                child: ProductCard(product: p),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MobileProductGrid extends StatelessWidget {
  final List<Product> products;
  const _MobileProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ProductCard(
                product: products.isNotEmpty ? products[0] : products.first,
              ),
            ),
            const SizedBox(width: 16),
            if (products.length > 1)
              Expanded(child: ProductCard(product: products[1]))
            else
              const Expanded(child: SizedBox()),
          ],
        ),
        if (products.length > 2) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: ProductCard(product: products[2])),
              const SizedBox(width: 16),
              if (products.length > 3)
                Expanded(child: ProductCard(product: products[3]))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }
}
