import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/business/products/pages_create_edit_product/info_product.dart';
import 'package:z_ecommerce/presentation/pages/customer/product_details_page.dart'
    as customer;
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/widgets/templates/details_template.dart';

import 'product_details_tab/overview_tab.dart';
import 'product_details_tab/pricing_tab.dart';
import 'product_details_tab/discounts_tab.dart';
import 'product_details_tab/offers_tab.dart';
import 'product_details_tab/reviews_tab.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().listenToAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final productIndex = provider.allProducts.indexWhere(
          (p) => p.id == widget.productId,
        );
        if (productIndex == -1) {
          return Scaffold(
            appBar: AppBar(
              title: Text(TranslationKeys.productDetails.tr(context)),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final product = provider.allProducts[productIndex];

        return DetailsTemplate(
          title: TranslationKeys.productDetails.tr(context),
          name: product.name,
          subtitle:
              '${TranslationKeys.category.tr(context)}: ${product.category} • ${product.id}',
          avatarUrl: product.images.isNotEmpty ? product.images.first : null,
          fallbackIcon: Icons.inventory_2_rounded,
          statusBadge: TableStatusBadge.fromStatus(
            product.isActive
                ? TranslationKeys.statusActive.tr(context)
                : TranslationKeys.statusInactive.tr(context),
          ),
          onEdit: () {
            changeScreen(context, InfoProductPage(product: product));
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Customer preview button (Eye icon)
              ButtonApp(
                format: FormatButtonApp.icon,
                icon: Icons.visibility_outlined,
                label: 'عرض تفاصيل المنتج للعميل',
                onPressed: () {
                  changeScreen(
                    context,
                    customer.ProductDetailsPage(product: product),
                  );
                },
              ),
            ],
          ),
          tabs: [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'التسعير'),
            Tab(text: 'الخصومات'),
            if (context.watch<BusinessProvider>().selectedBusiness.allowOffers)
              Tab(text: 'العروض والاوفرات'),
            if (context.watch<BusinessProvider>().selectedBusiness.allowReviews)
              Tab(text: 'التقييمات والمراجعات'),
          ],
          tabViews: [
            ProductOverviewTab(product: product),
            ProductPricingTab(product: product),
            ProductDiscountsTab(product: product),
            if (context.watch<BusinessProvider>().selectedBusiness.allowOffers)
              ProductOffersTab(product: product),
            if (context.watch<BusinessProvider>().selectedBusiness.allowReviews)
              ProductReviewsTab(product: product),
          ],
        );
      },
    );
  }
}
