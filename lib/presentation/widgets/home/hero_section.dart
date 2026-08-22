import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/follower_provider.dart';
import 'package:z_ecommerce/data/providers/review_provider.dart';
import 'package:z_ecommerce/data/providers/like_provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/models/shared/follower_model.dart';
import 'package:z_ecommerce/data/models/shared/like_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final selectedBusiness = context.read<BusinessProvider>().selectedBusiness;
      if (selectedBusiness.id.isNotEmpty) {
        context.read<FollowerProvider>().listenToStoreFollowers(selectedBusiness.id);
        context.read<ReviewProvider>().listenToBusinessReviews(selectedBusiness.id);
        context.read<LikeProvider>().listenToTargetLikesCount(selectedBusiness.id);
        final auth = context.read<AuthProvider>();
        if (auth.isAuthenticated) {
          context.read<LikeProvider>().listenToUserLikes(auth.currentUser!.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;

    final storeName = selectedBusiness.localization.name.get(context);
    final storeSlogan = selectedBusiness.localization.slogan.get(context);
    final storeDesc = selectedBusiness.localization.description.get(context);
    final logoUrl = selectedBusiness.theme.logoUrl;
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : theme.dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 1. Top Cover / Hero Header Banner
            Container(
              height: isMobile ? 140 : 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.85),
                    primaryColor.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    top: -40,
                    child: CircleAvatar(
                      radius: 120,
                      backgroundColor: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(selectedBusiness.businessType.icon, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            selectedBusiness.businessType.ar,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 2. Main Profile Content Section
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 36),
                child: Column(
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    /// Logo Avatar & Action Row
                    Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.end,
                      children: [
                        /// Store Logo with Glowing Border
                        Container(
                          width: isMobile ? 100 : 120,
                          height: isMobile ? 100 : 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.scaffoldBackgroundColor,
                            border: Border.all(color: theme.cardColor, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: logoUrl != null && logoUrl.isNotEmpty
                                ? Image.network(
                                    logoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => _buildFallbackLogo(context, primaryColor),
                                  )
                                : _buildFallbackLogo(context, primaryColor),
                          ),
                        ),
                        if (isMobile) const SizedBox(height: 16),

                        /// Follow & Contact Actions
                        _HeroActions(business: selectedBusiness),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Store Title & Verified Badge
                    Row(
                      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                            storeName.isNotEmpty ? storeName : 'اسم البزنس غير محدد',
                            style: TextStyle(
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.displayLarge?.color,
                            ),
                          ),
                        ),
                        if (selectedBusiness.isVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified_rounded,
                            color: Colors.blueAccent,
                            size: 26,
                          ),
                        ],
                      ],
                    ),

                    if (storeSlogan.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        storeSlogan,
                        textAlign: isMobile ? TextAlign.center : TextAlign.start,
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 18,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],

                    if (storeDesc.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        storeDesc,
                        textAlign: isMobile ? TextAlign.center : TextAlign.start,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    /// 3. Rich KPIs & Metrics Bar (المتابعين، الزيارات، الطلبات، التقييم، الإعجابات)
                    _HeroMetricsBar(business: selectedBusiness),

                    /// 4. Addresses & Contact Badges Section
                    if (selectedBusiness.addAddress.isNotEmpty || selectedBusiness.socials.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      _HeroDetailsFooter(business: selectedBusiness),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackLogo(BuildContext context, Color primaryColor) {
    return Container(
      color: primaryColor.withOpacity(0.12),
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          size: 50,
          color: primaryColor,
        ),
      ),
    );
  }
}

/// ============================================================================
/// 👥 Hero Actions Widget (Like & Follow Action Buttons)
/// ============================================================================
class _HeroActions extends StatelessWidget {
  final BusinessModel business;

  const _HeroActions({required this.business});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final followerProvider = context.watch<FollowerProvider>();
    final likeProvider = context.watch<LikeProvider>();

    final primaryColor = Theme.of(context).primaryColor;
    final isFollowing = followerProvider.isFollowing(business.id);
    final isLiked = likeProvider.hasLiked(business.id);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        /// 1. Like Button (إذا كان مسموحاً)
        if (business.allowLikes)
          ButtonApp(
            format: isLiked ? FormatButtonApp.outline : FormatButtonApp.elevated,
            color: isLiked ? Colors.redAccent : Colors.redAccent,
            icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: isLiked ? 'معجب' : 'إعجاب',
            onPressed: () async {
              if (authProvider.isAuthenticated) {
                final likeModel = LikeModel(
                  id: '',
                  userId: authProvider.currentUser!.id,
                  targetId: business.id,
                  targetType: 'store',
                  createdAt: DateTime.now(),
                );
                await likeProvider.toggleLike(likeModel);
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(TranslationKeys.pleaseLoginToSaveItems.tr(context)),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

        /// 2. Follow Button (إذا كان مسموحاً)
        if (business.allowFollow)
          ButtonApp(
            format: isFollowing ? FormatButtonApp.outline : FormatButtonApp.elevated,
            color: isFollowing ? Colors.grey : primaryColor,
            icon: isFollowing ? Icons.check_circle_outline_rounded : Icons.person_add_alt_1_rounded,
            label: isFollowing ? 'متابع' : 'متابعة البزنس',
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
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(TranslationKeys.pleaseLoginToSaveItems.tr(context)),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}

/// ============================================================================
/// 📊 Hero Metrics Bar (المتابعين، الزيارات، الطلبات، التقييم، الإعجابات)
/// ============================================================================
class _HeroMetricsBar extends StatelessWidget {
  final BusinessModel business;

  const _HeroMetricsBar({required this.business});

  @override
  Widget build(BuildContext context) {
    final followerProvider = context.watch<FollowerProvider>();
    final reviewProvider = context.watch<ReviewProvider>();
    final likeProvider = context.watch<LikeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final followersCount = followerProvider.storeFollowers.length;
    final reviews = reviewProvider.businessReviews;

    double avgRating = 0;
    if (reviews.isNotEmpty) {
      avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    } else if (business.ratings.isNotEmpty) {
      avgRating = business.ratings.map((r) => r.rating).reduce((a, b) => a + b) / business.ratings.length;
    }

    final visitsCount = business.visits.length;
    final ordersCount = business.orders;

    final realLikes = likeProvider.getLikesCount(business.id);
    final likesCount = realLikes > 0 ? realLikes : business.likes;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? theme.scaffoldBackgroundColor : theme.scaffoldBackgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 16,
        spacing: 24,
        children: [
          /// 1. المتابعين (إذا كان مسموحاً)
          if (business.allowFollow)
            _MetricTile(
              icon: Icons.people_alt_rounded,
              color: Colors.blue,
              label: 'المتابعين',
              value: '$followersCount',
            ),

          /// 2. الزيارات (دائماً متاحة)
          _MetricTile(
            icon: Icons.visibility_rounded,
            color: Colors.purple,
            label: 'الزيارات',
            value: '$visitsCount',
          ),

          /// 3. الطلبات (دائماً متاحة)
          _MetricTile(
            icon: Icons.shopping_bag_rounded,
            color: Colors.orange,
            label: 'إجمالي الطلبات',
            value: '$ordersCount',
          ),

          /// 4. التقييم (إذا كان مسموحاً)
          if (business.allowReviews)
            _MetricTile(
              icon: Icons.star_rounded,
              color: Colors.amber,
              label: 'التقييم العام',
              value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '5.0',
            ),

          /// 5. الإعجابات (إذا كان مسموحاً)
          if (business.allowLikes)
            _MetricTile(
              icon: Icons.favorite_rounded,
              color: Colors.redAccent,
              label: 'الإعجابات',
              value: '$likesCount',
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _MetricTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ============================================================================
/// 📍 Hero Details Footer (العناوين ووسائل التواصل)
/// ============================================================================
class _HeroDetailsFooter extends StatelessWidget {
  final BusinessModel business;

  const _HeroDetailsFooter({required this.business});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        /// الفروع والعناوين
        if (business.addAddress.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_rounded, color: theme.primaryColor, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  business.addAddress.first.getFormattedAddress(langCode: langCode),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),

        /// وسائل التواصل
        if (business.socials.isNotEmpty)
          Wrap(
            spacing: 8,
            children: business.socials
                .where((s) => s.isVisible)
                .map(
                  (social) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link_rounded, color: theme.primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          social.platform.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
