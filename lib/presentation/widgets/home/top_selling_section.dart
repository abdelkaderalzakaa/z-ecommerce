import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/company_provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../common/product_card.dart';
import '../../../data/models/product_model.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import '../../global/router/app_routes.dart';

class TopSellingSection extends StatelessWidget {
  const TopSellingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final products = provider.topSelling.take(4).toList();

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: isMobile ? AppSpacing.sectionVerticalMobile : AppSpacing.sectionVertical,
          ),
          child: Column(
            children: [
              SectionHeader(title: TranslationKeys.topSelling.tr(context).toUpperCase()),
              const SizedBox(height: 40),
              isMobile
                  ? _MobileProductGrid(products: products)
                  : _DesktopProductGrid(products: products),
          const SizedBox(height: 36),
          ViewAllButton(onTap: () {
            final cid = context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001';
            context.go(AppRoutes.toShop(cid));
          }),
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
  final List<Product> products;
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


