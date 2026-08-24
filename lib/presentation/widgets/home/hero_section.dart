import 'package:z_ecommerce/presentation/pages/customer/business_entry.dart';
import 'package:z_ecommerce/presentation/widgets/common/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/follower_provider.dart';
import 'package:z_ecommerce/data/providers/review_provider.dart';
import 'package:z_ecommerce/data/providers/like_provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/order_provider.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/models/store/business_visit_model.dart';
import 'package:z_ecommerce/data/models/shared/follower_model.dart';
import 'package:z_ecommerce/data/models/shared/like_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
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
      final selectedBusiness = context
          .read<BusinessProvider>()
          .selectedBusiness;
      if (selectedBusiness.id.isNotEmpty) {
        context.read<FollowerProvider>().listenToStoreFollowers(
          selectedBusiness.id,
        );
        context.read<ReviewProvider>().listenToBusinessReviews(
          selectedBusiness.id,
        );
        context.read<LikeProvider>().listenToTargetLikesCount(
          selectedBusiness.id,
        );
        context.read<OrderProvider>().listenToBusinessOrders(
          selectedBusiness.id,
        );
        final auth = context.read<AuthProvider>();
        if (auth.isAuthenticated) {
          context.read<LikeProvider>().listenToUserLikes(auth.currentUser!.id);
        }

        // Record a visit
        final visit = BusinessVisitModel(
          id: '',
          businessId: selectedBusiness.id,
          userId: auth.currentUser?.id,
          visitDate: DateTime.now(),
        );
        context.read<BusinessProvider>().addVisit(selectedBusiness.id, visit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;

    final storeName = selectedBusiness.localization.name.get(context);
    final storeSlogan = selectedBusiness.localization.slogan.get(context);
    final storeDesc = selectedBusiness.localization.description.get(context);
    final logoUrl = selectedBusiness.theme.logoUrl;
    final primaryColor = Theme.of(context).primaryColor;

    final langCode = Localizations.localeOf(context).languageCode;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// 1. Top Cover / Hero Header Banner
          Container(
            height: isMobile ? 50 : 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.25),
                  primaryColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                Spacer(),
                ChipApp(
                  icon: selectedBusiness.businessType.icon,
                  lable: selectedBusiness.businessType.ar,
                  color: primaryColor,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                width: isMobile ? 35 : 75,
                height: isMobile ? 35 : 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.scaffoldBackgroundColor,
                  border: Border.all(color: theme.cardColor, width: 3),
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
                      ? CustomNetworkImage(
                          imageUrl: logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              _buildFallbackLogo(context, primaryColor),
                        )
                      : _buildFallbackLogo(context, primaryColor),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName.isNotEmpty ? storeName : 'اسم البزنس غير محدد',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 21,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.displayLarge?.color,
                      ),
                    ),

                    /// الفروع والعناوين
                    if (selectedBusiness.addAddress.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: theme.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              selectedBusiness.addAddress.first
                                  .getFormattedAddress(langCode: langCode),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (selectedBusiness.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.blueAccent,
                  size: 24,
                ),
              ],
            ],
          ),
          if (storeSlogan.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              storeSlogan,
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],

          if (storeDesc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              storeDesc,
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(child: _HeroMetricsBar(business: selectedBusiness)),
                const SizedBox(width: 16),
                _HeroActions(business: selectedBusiness),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackLogo(BuildContext context, Color primaryColor) {
    return Container(
      color: primaryColor.withOpacity(0.12),
      child: Center(
        child: Icon(Icons.storefront_rounded, size: 50, color: primaryColor),
      ),
    );
  }
}

class CardActionHero extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String countText;
  final String buttonLabel;
  final IconData buttonIcon;
  final FormatButtonApp format;
  final Color buttonColor;
  final VoidCallback onPressed;

  const CardActionHero({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.countText,
    required this.buttonLabel,
    required this.buttonIcon,
    this.format = FormatButtonApp.elevated,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: isDark ? theme.colorScheme.surface : theme.cardColor,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(2.5),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.12),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 6),
              Text(
                countText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ButtonApp(
            format: format,
            color: buttonColor,
            icon: buttonIcon,
            label: buttonLabel,
            onPressed: onPressed,
          ),
        ],
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

    final realLikes = likeProvider.getLikesCount(business.id);
    final likesCount = realLikes > 0 ? realLikes : business.likes;

    final followersCount = followerProvider.storeFollowers.isNotEmpty
        ? followerProvider.storeFollowers.length
        : business.followersUsers.length;

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        /// 1. بطاقة الإعجاب (Like Card)
        CardActionHero(
          icon: Icons.favorite,
          iconColor: Colors.redAccent,
          countText: isAr ? '$likesCount إعجاب' : '$likesCount Likes',
          buttonLabel: isLiked
              ? (isAr ? 'معجب' : 'Liked')
              : (isAr ? 'إعجاب' : 'Like'),
          buttonIcon: isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          format: isLiked ? FormatButtonApp.outline : FormatButtonApp.elevated,
          buttonColor: Colors.redAccent,
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
                  content: Text(
                    TranslationKeys.pleaseLoginToSaveItems.tr(context),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),

        /// 2. بطاقة المتابعة (Follow Card)
        CardActionHero(
          icon: Icons.people_alt_rounded,
          iconColor: primaryColor,
          countText: isAr
              ? '$followersCount متابع'
              : '$followersCount Followers',
          buttonLabel: isFollowing
              ? (isAr ? 'متابع' : 'Following')
              : (isAr ? 'متابعة البزنس' : 'Follow'),
          buttonIcon: isFollowing
              ? Icons.check_circle_outline_rounded
              : Icons.person_add_alt_1_rounded,
          format: isFollowing
              ? FormatButtonApp.outline
              : FormatButtonApp.elevated,
          buttonColor: isFollowing ? Colors.grey : primaryColor,
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
                  content: Text(
                    TranslationKeys.pleaseLoginToSaveItems.tr(context),
                  ),
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
/// 📊 Hero Metrics Bar (الزيارات، الطلبات، التقييم)
/// ============================================================================
class _HeroMetricsBar extends StatelessWidget {
  final BusinessModel business;

  const _HeroMetricsBar({required this.business});

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final reviews = reviewProvider.businessReviews;
    double avgRating = 0;
    int reviewsCount = 0;
    if (reviews.isNotEmpty) {
      reviewsCount = reviews.length;
      avgRating =
          reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    } else if (business.ratings.isNotEmpty) {
      reviewsCount = business.ratings.length;
      avgRating =
          business.ratings.map((r) => r.rating).reduce((a, b) => a + b) /
          business.ratings.length;
    }

    final visitsCount = business.visits.isNotEmpty ? business.visits.length : 1;
    final ordersCount = orderProvider.businessOrders.isNotEmpty
        ? orderProvider.businessOrders.length
        : business.orders;

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.scaffoldBackgroundColor
            : theme.scaffoldBackgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 16,
        spacing: 24,
        children: [
          /// 1. الزيارات
          _MetricTile(
            icon: Icons.visibility_rounded,
            color: Colors.purple,
            label: isAr ? 'الزيارات' : 'Visits',
            value: '$visitsCount',
          ),

          /// 2. الطلبات
          _MetricTile(
            icon: Icons.shopping_bag_rounded,
            color: Colors.orange,
            label: isAr ? 'إجمالي الطلبات' : 'Total Orders',
            value: '$ordersCount',
          ),

          /// 3. التقييم
          _MetricTile(
            icon: Icons.star_rounded,
            color: Colors.amber,
            label: isAr
                ? (reviewsCount > 0
                      ? 'التقييمات ($reviewsCount)'
                      : 'التقييم العام')
                : (reviewsCount > 0 ? 'Reviews ($reviewsCount)' : 'Rating'),
            value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '5.0',
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

