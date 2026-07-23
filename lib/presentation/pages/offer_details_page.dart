import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../data/models/offer_model.dart';
import '../../../data/providers/offer_provider.dart';
import '../../../data/providers/product_provider.dart';
import '../global/core/responsive/responsive_layout.dart';
import '../global/translate/app_localizations.dart';
import '../global/translate/translation_keys.dart';
import '../widgets/common/product_card.dart';
import '../widgets/common/footer_section.dart';
import '../widgets/common/headers/header_details.dart';
import '../../../data/providers/company_provider.dart';

class OfferDetailsPage extends StatefulWidget {
  final String offerId;

  const OfferDetailsPage({super.key, required this.offerId});

  @override
  State<OfferDetailsPage> createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final companyId =
          context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001';
      final offer = context.read<OfferProvider>().getOfferById(
        companyId,
        widget.offerId,
      );
      if (offer != null) {
        final now = DateTime.now();
        if (offer.endDate.isAfter(now)) {
          setState(() {
            _timeLeft = offer.endDate.difference(now);
          });
        } else {
          setState(() {
            _timeLeft = Duration.zero;
          });
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyId =
        context.watch<CompanyProvider>().companySettings?.id ?? 'cmp_001';
    final offer = context.watch<OfferProvider>().getOfferById(
      companyId,
      widget.offerId,
    );

    if (offer == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Offer not found or expired.')),
      );
    }

    final products = context.watch<ProductProvider>().allProducts;
    var offerProducts = products.where((p) {
      if (offer.productIds != null && offer.productIds!.isNotEmpty) {
        return offer.productIds!.contains(p.id);
      } else if (offer.productId != null) {
        return p.id == offer.productId;
      }
      return false;
    }).toList();

    // Fallback: If no products specified, show all products as "Store-wide" offer.
    if (offerProducts.isEmpty) {
      offerProducts = products.take(12).toList();
    }

    final hPad = ResponsiveLayout.horizontalPadding(context);
    return Scaffold(
      appBar: HeaderDetails(
        title: offer.name.get(context),
        fallbackRoute: 'offers',
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.specialOffers.tr(context),
          offer.name.get(context),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: CustomScrollView(
          slivers: [
            _buildHeroHeader(context, offer),
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
                      TranslationKeys.specialOffers.tr(context),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Products included in this offer',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: 40.0,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveLayout.isMobile(context)
                      ? 2
                      : ResponsiveLayout.isTablet(context)
                      ? 3
                      : 4,
                  childAspectRatio: ResponsiveLayout.isMobile(context)
                      ? 0.75
                      : 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return ProductCard(product: offerProducts[index]);
                }, childCount: offerProducts.length),
              ),
            ),
            if (!ResponsiveLayout.isMobile(context))
              const SliverToBoxAdapter(child: FooterSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, OfferModel offer) {
    return SliverToBoxAdapter(
      child: Container(
        constraints: const BoxConstraints(minHeight: 250),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          image: offer.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(offer.imageUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                )
              : null,
          gradient: offer.imageUrl == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColorDark,
                  ],
                )
              : null,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTagText(offer.type),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  offer.name.get(context),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                if (offer.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    offer.description!.get(context),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 24),

                // Timer & Coupon Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildTimerWidget(),
                    const Spacer(),
                    if (offer.type == 'coupon' && offer.couponCode != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: offer.couponCode!),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Coupon code copied!'),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.copy,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: Text(
                          'Copy: ${offer.couponCode}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerWidget() {
    final hours = _timeLeft.inHours.toString().padLeft(2, '0');
    final minutes = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ends in:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTimeUnit(hours, 'Hours'),
                  _buildTimeSeparator(),
                  _buildTimeUnit(minutes, 'Minutes'),
                  _buildTimeSeparator(),
                  _buildTimeUnit(seconds, 'Seconds'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 8,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getTagText(String type) {
    switch (type) {
      case 'discount':
      case 'percentage_discount':
      case 'fixed_discount':
        return 'Discount';
      case 'coupon':
        return 'Coupon Code';
      case 'clearance':
        return 'Clearance';
      case 'bundle':
        return 'Bundle Deal';
      case 'product_gift':
      case 'buy_x_get_y':
        return 'Free Gift';
      default:
        return 'Special Offer';
    }
  }
}
