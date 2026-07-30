import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/company_provider.dart';
import '../../../data/providers/offer_provider.dart';
import '../global/core/constants/app_constants.dart';
import '../global/core/responsive/responsive_layout.dart';
import '../global/translate/app_localizations.dart';
import '../global/translate/translation_keys.dart';
import '../widgets/common/headers/header_details.dart';
import '../global/translate/localized_string.dart';
import '../widgets/common/footer_section.dart';
import '../widgets/offers/offer_card.dart';
import 'package:z_ecommerce/presentation/pages/offers_page.dart';

class OffersPage extends StatelessWidget {
  final String? offerType;

  const OffersPage({super.key, this.offerType});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    return Scaffold(
      appBar: HeaderDetails(
        title: offerType != null
            ? TranslationKeys.offers.tr(context)
            : TranslationKeys.offers.tr(context),
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.offers.tr(context),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: CustomScrollView(
          slivers: [
            // Hero Header for Specific Offer Type
            if (offerType != null) _buildHeroHeader(context, offerType!),

            // Title Section for General Offers
            if (offerType == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationKeys.offers.tr(context),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        TranslationKeys.specialOffers.tr(context),
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Offers Grid
            Consumer<OfferProvider>(
              builder: (context, provider, child) {
                final businessId =
                    context.watch<CompanyProvider>().companySettings?.id;
                var offers = provider.getActiveOffers(businessId);

                // Filter by offerType if provided
                if (offerType != null) {
                  if (offerType == 'coupon') {
                    offers = offers
                        .where(
                          (o) => [
                            'coupon',
                            'percentage_discount',
                            'fixed_discount',
                            'clearance',
                          ].contains(o.type),
                        )
                        .toList();
                  } else if (offerType == 'product_gift') {
                    offers = offers
                        .where(
                          (o) => [
                            'product_gift',
                            'buy_x_get_y',
                            'loyalty_points',
                          ].contains(o.type),
                        )
                        .toList();
                  } else {
                    offers = offers.where((o) => o.type == offerType).toList();
                  }
                }

                if (offers.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('No offers available right now.'),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    bottom: 40.0,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveLayout.isMobile(context)
                          ? 1
                          : ResponsiveLayout.isTablet(context)
                          ? 2
                          : 3,
                      childAspectRatio: ResponsiveLayout.isMobile(context)
                          ? 1.5
                          : 1.2,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return OfferCard(offer: offers[index]);
                    }, childCount: offers.length),
                  ),
                );
              },
            ),

            if (!ResponsiveLayout.isMobile(context))
              const SliverToBoxAdapter(child: FooterSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, String type) {
    String title = '';
    String description = '';
    String imageUrl = '';

    if (type == 'bundle') {
      title = TranslationKeys.topBundles.tr(context);
      description = const LocalizedString(
        ar: 'اكتشف باقاتنا المختارة للحصول على أقصى قيمة. كل ما تحتاجه في نقرة واحدة!',
        en: 'Discover our curated bundles for maximum value. Everything you need in one click!',
      ).get(context);
      imageUrl =
          'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=1770'; // Premium shopping bags/boxes
    } else if (type == 'coupon') {
      title = TranslationKeys.couponsAndDiscounts.tr(context);
      description = const LocalizedString(
        ar: 'وفر أكثر مع أكواد الخصم الحصرية وعناصر التصفية.',
        en: 'Save big with our exclusive discount codes and clearance items.',
      ).get(context);
      imageUrl =
          'https://images.unsplash.com/photo-1607082349566-187342175e2f?q=80&w=1770'; // Sale sign
    } else if (type == 'product_gift') {
      title = TranslationKeys.specialDeals.tr(context);
      description = const LocalizedString(
        ar: 'اشترِ أكثر، واحصل على المزيد! استمتع بهدايا مجانية وعروض اشترِ واحد واحصل على الثاني.',
        en: 'Buy more, get more! Enjoy free gifts and BOGO deals.',
      ).get(context);
      imageUrl =
          'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?q=80&w=1740'; // Gifts
    } else {
      title = TranslationKeys.offers.tr(context);
      description = const LocalizedString(
        ar: 'اطلع على جميع عروضنا وخصوماتنا النشطة.',
        en: 'Check out all our active offers and deals.',
      ).get(context);
      imageUrl =
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1770';
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 250,
        margin: const EdgeInsets.only(bottom: 24.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
