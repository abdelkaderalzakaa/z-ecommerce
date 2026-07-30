import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
import '../global/core/constants/app_constants.dart';
import '../global/core/responsive/responsive_layout.dart';
import '../widgets/common/footer_section.dart';
import '../widgets/common/headers/widgets/top_title.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/company_provider.dart';
import '../widgets/product_details/product_gallery.dart';
import '../widgets/product_details/product_info.dart';
import '../global/translate/app_localizations.dart';
import '../global/translate/translation_keys.dart';

import '../widgets/product_details/related_products.dart';
import '../../../data/models/product/product_model.dart';
import 'package:z_ecommerce/presentation/pages/product_details_page.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.productDetails.tr(context),

        fallbackRoute: 'shop',
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.shop.tr(context),
          product.category,
          product.name,
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Gallery and Info
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 20 : 24,
                horizontal: hPad,
              ),
              child: isMobile
                  ? Column(
                      children: [
                        ProductGallery(
                          images: product.images.isEmpty
                              ? ['p1', 'p2', 'p3']
                              : product.images,
                        ),
                        const SizedBox(height: 24),
                        ProductInfo(product: product),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductGallery(
                                images: product.images.isEmpty
                                    ? ['p1', 'p2', 'p3']
                                    : product.images,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(flex: 1, child: ProductInfo(product: product)),
                      ],
                    ),
            ),

            const SizedBox(height: 50),

            const RelatedProducts(),

            const SizedBox(height: 64),

            const FooterSection(),
          ],
        ),
      ),
    );
  }
}
