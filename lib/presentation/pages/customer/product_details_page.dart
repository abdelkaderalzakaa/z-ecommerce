import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_buisness.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/top_title.dart';
import 'package:z_ecommerce/presentation/widgets/product_details/product_gallery.dart';
import 'package:z_ecommerce/presentation/widgets/product_details/product_info.dart';
import 'package:z_ecommerce/presentation/widgets/product_details/product_offers_section.dart';
import 'package:z_ecommerce/presentation/widgets/product_details/product_reviews_section.dart';
import 'package:z_ecommerce/presentation/widgets/product_details/related_products.dart';

class ProductDetailsPage extends StatelessWidget {
  final ProductModel product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    // If product is inactive or zero-dollar / free, display clear unavailable screen
    if (!product.isValidForCustomer) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: HeaderDetails(title: TranslationKeys.productDetails.tr(context)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  isAr ? 'عذراً، هذا المنتج غير متاح حالياً' : 'Sorry, this product is currently unavailable',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isAr
                      ? 'المنتج غير نشط أو قيد التحديث من قبل إدارة المتجر'
                      : 'This product is currently inactive or undergoing maintenance',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(isAr ? 'العودة للمتجر' : 'Back to Store'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(title: TranslationKeys.productDetails.tr(context)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Title
            TopTitle(
              title: TranslationKeys.productDetails.tr(context),
              fallbackRoute: 'shop',
              paths: [
                TranslationKeys.home.tr(context),
                TranslationKeys.shop.tr(context),
                product.category,
                product.name,
              ],
            ),
            // Product Gallery and Info
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: hPad),
              child: isMobile
                  ? Column(
                      children: [
                        ProductGallery(images: product.images),
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
                            children: [ProductGallery(images: product.images)],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(flex: 1, child: ProductInfo(product: product)),
                      ],
                    ),
            ),

            const SizedBox(height: 50),

            const RelatedProducts(),

            const SizedBox(height: 24),
            if (context.watch<BusinessProvider>().selectedBusiness.allowOffers)
              ProductOffersSection(product: product),

            if (context
                .watch<BusinessProvider>()
                .selectedBusiness
                .allowReviews) ...[
              const SizedBox(height: 24),
              ProductReviewsSection(product: product),
            ],

            const SizedBox(height: 64),
            FooterBuisness(idBuisness: product.businessId),
          ],
        ),
      ),
    );
  }
}
