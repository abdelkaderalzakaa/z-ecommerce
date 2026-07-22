import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/providers/offer_provider.dart';
import '../../../data/providers/company_provider.dart';
import '../offers/offer_card.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import '../../global/router/app_routes.dart';

class OffersSection extends StatelessWidget {
  final String? sectionType; // 'bundles', 'coupons', 'deals'

  const OffersSection({super.key, this.sectionType});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfferProvider>(
      builder: (context, provider, child) {
        final companyId =
            context.watch<CompanyProvider>().companySettings?.id ?? 'cmp_001';
        final activeOffers = provider.getActiveOffers(companyId);
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
                TextButton(
                  onPressed: () {
                    final cid =
                        context.read<CompanyProvider>().companySettings?.id ??
                        'cmp_001';
                    context.go(AppRoutes.toOffers(cid, type: type));
                  },
                  child: Text(TranslationKeys.viewAll.tr(context)),
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
