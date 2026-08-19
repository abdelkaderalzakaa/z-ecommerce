import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/pages/customer/offer/offers_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import '../../../data/models/product/offer_model.dart';
import '../../../data/providers/offer_provider.dart';
import '../../../data/providers/business_provider.dart';
import '../offers/offer_card.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class OffersSection extends StatelessWidget {
  final String? sectionType; // 'bundles', 'coupons', 'deals'

  const OffersSection({super.key, this.sectionType});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfferProvider>(
      builder: (context, provider, child) {
        final businessId = context
            .watch<BusinessProvider>()
            .selectedBusiness
            .id;
        var activeOffers = provider.activeOffers;
        activeOffers = activeOffers
            .where((o) => o.businessId == businessId)
            .toList();
              if (activeOffers.isEmpty) return const SizedBox.shrink();

        final bundles = activeOffers.where((o) => o.type == 'bundle').toList();
        final discounts = activeOffers
            .where(
              (o) => [
                'coupon',
                'percentage_discount',
                'fixed_discount',
                'clearance',
              ].contains(o.type),
            )
            .toList();
        final deals = activeOffers
            .where(
              (o) => [
                'product_gift',
                'buy_x_get_y',
                'loyalty_points',
              ].contains(o.type),
            )
            .toList();

        final showBundles =
            (sectionType == null || sectionType == 'bundles') &&
            bundles.isNotEmpty;
        final showCoupons =
            (sectionType == null || sectionType == 'coupons') &&
            discounts.isNotEmpty;
        final showDeals =
            (sectionType == null || sectionType == 'deals') && deals.isNotEmpty;

        if (!showBundles && !showCoupons && !showDeals) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBundles)
              _buildOfferRow(
                context,
                TranslationKeys.topBundles.tr(context),
                bundles,
                'bundle',
              ),
            if (showCoupons)
              _buildOfferRow(
                context,
                TranslationKeys.couponsAndDiscounts.tr(context),
                discounts,
                'coupon',
              ),
            if (showDeals)
              _buildOfferRow(
                context,
                TranslationKeys.specialDeals.tr(context),
                deals,
                'product_gift',
              ),
          ],
        );
      },
    );
  }

  Widget _buildOfferRow(
    BuildContext context,
    String title,
    List<OfferModel> offers,
    String type,
  ) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ButtonApp(
                  format: FormatButtonApp.text,
                  onPressed: () {
                    changeScreen(context, const OffersPage());
                  },
                  label:  TranslationKeys.viewAll.tr(context) ,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 250,
            child: offers.length == 1
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: OfferCard(offer: offers[0], fullWidth: true),
                  )
                : offers.length == 2 && !ResponsiveLayout.isMobile(context)
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OfferCard(offer: offers[0], fullWidth: true),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OfferCard(offer: offers[1], fullWidth: true),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      return OfferCard(offer: offers[index]);
                    },
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
