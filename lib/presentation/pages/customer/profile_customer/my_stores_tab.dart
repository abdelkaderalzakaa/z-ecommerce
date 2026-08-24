import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/auth/register_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';

class MyStoresTab extends StatelessWidget {
  const MyStoresTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';
    final businessProvider = context.watch<BusinessProvider>();

    // Fetch stores owned by or assigned to current user
    final myBusinesses = businessProvider.businesses.where((b) {
      return b.ownerId == currentUserId && currentUserId.isNotEmpty;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationKeys.myStores.tr(context),
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAr
                      ? 'قائمة الأنشطة التجارية والمتاجر المسجلة باسمك'
                      : 'Businesses and stores registered under your account',
                  style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                ),
              ],
            ),
            ButtonApp(
              label: TranslationKeys.registerStoreNow.tr(context),
              icon: Icons.add_business,
              onPressed: () => changeScreen(context, const RegisterPage()),
            ),
          ],
        ),
        const SizedBox(height: 28),

        if (myBusinesses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 64,
                  color: theme.primaryColor.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  TranslationKeys.noStoresAvailable.tr(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr
                      ? 'يمكنك تسجيل نشاطك التجاري الآن وعرض خدماتك ومنتجاتك للعملاء.'
                      : 'You can register your business now to showcase products & services.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                ),
                const SizedBox(height: 20),
                ButtonApp(
                  label: TranslationKeys.registerStoreNow.tr(context),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => changeScreen(context, const RegisterPage()),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isMobile ? 1.05 : 1.1,
            ),
            itemCount: myBusinesses.length,
            itemBuilder: (context, index) {
              return _MyStoreCard(business: myBusinesses[index]);
            },
          ),
      ],
    );
  }
}

class _MyStoreCard extends StatelessWidget {
  final BusinessModel business;

  const _MyStoreCard({required this.business});

  void _visitStore(BuildContext context) async {
    final businessProvider = context.read<BusinessProvider>();
    await businessProvider.selectBusiness(business.id);
    if (context.mounted) {
      changeScreen(context, const HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final name = business.localization.name.get(context);
    final visitsCount = business.visits.length;
    final followersCount = business.followersUsers.length;
    final likesCount = business.likes;

    final hasRatings = business.ratings.isNotEmpty;
    final double avgRating = hasRatings
        ? (business.ratings.map((r) => r.rating).reduce((a, b) => a + b) /
            business.ratings.length)
        : 0.0;
    final String ratingDisplay = hasRatings ? avgRating.toStringAsFixed(1) : (isAr ? 'جديد' : 'New');

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _visitStore(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Header: Business Logo & Name & Type
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                      ),
                      child: Icon(
                        business.businessType.icon,
                        color: theme.primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAr ? business.businessType.ar : business.businessType.en,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 20),

                // Stats Grid: Visits, Followers, Likes, Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBadge(
                      icon: Icons.visibility_outlined,
                      label: isAr ? 'الزيارات' : 'Visits',
                      value: '$visitsCount',
                      color: Colors.blue,
                    ),
                    _StatBadge(
                      icon: Icons.people_outline,
                      label: isAr ? 'المتابعة' : 'Followers',
                      value: '$followersCount',
                      color: AppColors.green,
                    ),
                    _StatBadge(
                      icon: Icons.favorite_outline,
                      label: isAr ? 'الإعجاب' : 'Likes',
                      value: '$likesCount',
                      color: Colors.red,
                    ),
                    _StatBadge(
                      icon: Icons.star_outline,
                      label: isAr ? 'التقييم' : 'Rating',
                      value: ratingDisplay,
                      color: AppColors.star,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Visit Store Button
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ButtonApp(
                    label: TranslationKeys.enterStore.tr(context),
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => _visitStore(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
