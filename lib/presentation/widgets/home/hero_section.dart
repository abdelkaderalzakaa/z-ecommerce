import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import '../../global/core/responsive/responsive_layout.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;

    if (selectedBusiness == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Area (Image & Details)
          if (isMobile) ...[
            _HeroCardsCarousel(business: selectedBusiness),
            const SizedBox(height: 24),
            _HeroDetails(business: selectedBusiness, isMobile: true),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _HeroCardsCarousel(business: selectedBusiness)),
                const SizedBox(width: 48),
                Expanded(flex: 7, child: _HeroDetails(business: selectedBusiness, isMobile: false)),
              ],
            ),
          ],
          const SizedBox(height: 48),
          
          // Bottom Area (Map & Branches)
          _HeroBottomSection(business: selectedBusiness, isMobile: isMobile),
        ],
      ),
    );
  }
}

class _HeroCardsCarousel extends StatefulWidget {
  final BusinessModel business;
  const _HeroCardsCarousel({required this.business});

  @override
  State<_HeroCardsCarousel> createState() => _HeroCardsCarouselState();
}

class _HeroCardsCarouselState extends State<_HeroCardsCarousel> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              widget.business.localization.name.get(context),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroDetails extends StatelessWidget {
  final BusinessModel business;
  final bool isMobile;
  
  const _HeroDetails({required this.business, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (business.likes > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  business.likes.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.favorite, color: Colors.red, size: 18),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Text(
          business.localization.slogan.get(context),
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.displayLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          business.localization.description.get(context),
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            height: 1.6,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _HeroBottomSection extends StatelessWidget {
  final BusinessModel business;
  final bool isMobile;
  
  const _HeroBottomSection({required this.business, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
