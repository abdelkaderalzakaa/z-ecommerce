import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import '../../global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/data/providers/follower_provider.dart';
import 'package:z_ecommerce/data/providers/review_provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/models/shared/follower_model.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final businessProvider = context.read<BusinessProvider>();
      final selectedBusiness = businessProvider.selectedBusiness;
      context.read<FollowerProvider>().listenToStoreFollowers(selectedBusiness.id);
      context.read<ReviewProvider>().listenToBusinessReviews(selectedBusiness.id);
        });
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
        Consumer3<AuthProvider, FollowerProvider, ReviewProvider>(
          builder: (context, authProvider, followerProvider, reviewProvider, child) {
            final isFollowing = followerProvider.isFollowing(business.id);
            final followersCount = followerProvider.storeFollowers.length;
            
            // Calculate rating
            final reviews = reviewProvider.businessReviews;
            double avgRating = 0;
            if (reviews.isNotEmpty) {
              avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Followers Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$followersCount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.people, color: Theme.of(context).primaryColor, size: 18),
                    ],
                  ),
                ),
                
                // Rating Badge
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
                        avgRating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '(${reviews.length})',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Follow Button
                ButtonApp(
                  format: FormatButtonApp.outline,
                  color: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
                  icon: isFollowing ? Icons.check : Icons.add,
                  label: isFollowing ? 'متابع' : 'متابعة المتجر',
                  onPressed: () async {
                    if (authProvider.isAuthenticated) {
                      final follower = FollowerModel(
                        id: '',
                        userId: authProvider.currentUser!.id,
                        userName: authProvider.currentUser!.name,
                        userAvatar: authProvider.currentUser!.avatarUrl,
                        businessId: business.id,
                        followedAt: DateTime.now(),
                      );
                      await followerProvider.toggleFollow(follower);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(TranslationKeys.pleaseLoginToSaveItems.tr(context))),
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
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
            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
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
