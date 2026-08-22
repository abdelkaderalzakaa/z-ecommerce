import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/shared/follower_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/follower_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/global/theme/app_text_styles.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/auth/register_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_buisness.dart';

/// ============================================================================
/// 🏛️ BusinessPage (StatelessWidget)
/// واجهة استكشاف الأنشطة التجارية الشاملة المصممة بأسلوب عالي الإنتاجية والنظافة
/// ============================================================================
class BusinessPage extends StatelessWidget {
  final bool useAdminTheme;
  const BusinessPage({super.key, this.useAdminTheme = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchQueryNotifier = ValueNotifier<String>('');
    final selectedCategoryNotifier = ValueNotifier<String?>(null);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const HeaderBuisness(),
      body: Consumer<BusinessProvider>(
        builder: (context, businessProvider, child) {
          final activeBusinesses = businessProvider.activeBusinesses;

          if (businessProvider.isLoading && activeBusinesses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (businessProvider.errorMessage != null && activeBusinesses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.accent),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ أثناء تحميل بيانات الأنشطة التجارية',
                    style: TextStyle(fontSize: 16, color: theme.textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 12),
                  ButtonApp(
                    onPressed: () => businessProvider.fetchBusinesses(),
                    icon: Icons.refresh,
                    label: 'إعادة المحاولة',
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                /// 1. Hero Banner Section
                _SectionHeroBusinessPage(activeCount: activeBusinesses.length),

                /// 2. Search and Category Filter Section
                _SectionSearchAndFilter(
                  searchQueryNotifier: searchQueryNotifier,
                  selectedCategoryNotifier: selectedCategoryNotifier,
                ),

                /// 3. Business Catalog Grid Section
                ValueListenableBuilder<String>(
                  valueListenable: searchQueryNotifier,
                  builder: (context, searchQuery, _) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: selectedCategoryNotifier,
                      builder: (context, selectedCategory, _) {
                        final filteredBusinesses = activeBusinesses.where((b) {
                          final nameAr = b.localization.name.ar.toLowerCase();
                          final nameEn = b.localization.name.en.toLowerCase();
                          final q = searchQuery.toLowerCase();
                          final matchesSearch = nameAr.contains(q) || nameEn.contains(q);
                          final matchesCategory =
                              selectedCategory == null || b.businessType.name == selectedCategory;
                          return matchesSearch && matchesCategory;
                        }).toList();

                        return _SectionBusinessGrid(
                          businesses: filteredBusinesses,
                          searchQuery: searchQuery,
                          selectedCategory: selectedCategory,
                        );
                      },
                    );
                  },
                ),

                /// 4. Platform Quality KPI Features Section
                const _SectionKpiBusiness(),

                /// 5. Join Merchant Callout Banner
                const _SectionJoinMerchantBanner(),

                const SizedBox(height: 40),

                /// 6. Footer Section
                const FooterSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ============================================================================
/// 🌟 Section 1: Hero Banner Section (StatelessWidget)
/// ============================================================================
class _SectionHeroBusinessPage extends StatelessWidget {
  final int activeCount;
  const _SectionHeroBusinessPage({required this.activeCount});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  theme.primaryColor.withOpacity(0.25),
                  theme.scaffoldBackgroundColor,
                  theme.scaffoldBackgroundColor,
                ]
              : [
                  theme.primaryColor.withOpacity(0.9),
                  theme.primaryColor.withOpacity(0.7),
                  theme.scaffoldBackgroundColor,
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.horizontalPadding(context),
        vertical: 36,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              // Back Button Row
              Align(
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          changeScreenReplacement(context, const BusinessEntry());
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'العودة للمدخل الرئيسي' : 'Back to Entry',
                              style: TextStyle(
                                color: isDark ? theme.textTheme.bodyLarge?.color : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? theme.primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_outlined, color: AppColors.star, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      TranslationKeys.businessPlatformBadge.tr(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                TranslationKeys.businessHeroTitle.tr(context),
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontSize: isMobile ? 24 : 34,
                  fontWeight: FontWeight.bold,
                  color: isDark ? theme.primaryColor : Colors.white,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                TranslationKeys.businessHeroSubtitle.tr(context),
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  color: isDark ? theme.textTheme.bodyMedium?.color : Colors.white.withOpacity(0.95),
                  fontSize: isMobile ? 14 : 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Active Count Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront, color: theme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "$activeCount ${TranslationKeys.activeStoresNow.tr(context)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// 🔎 Section 2: Search & Filter Section (StatelessWidget)
/// ============================================================================
class _SectionSearchAndFilter extends StatelessWidget {
  final ValueNotifier<String> searchQueryNotifier;
  final ValueNotifier<String?> selectedCategoryNotifier;

  const _SectionSearchAndFilter({
    required this.searchQueryNotifier,
    required this.selectedCategoryNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input Bar
          ValueListenableBuilder<String>(
            valueListenable: searchQueryNotifier,
            builder: (context, query, _) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) => searchQueryNotifier.value = val.trim(),
                  style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: TranslationKeys.searchBusinessHint.tr(context),
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => searchQueryNotifier.value = '',
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // BusinessType Choice Chips Bar
          SizedBox(
            height: 44,
            child: ValueListenableBuilder<String?>(
              valueListenable: selectedCategoryNotifier,
              builder: (context, selectedCategory, _) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: BusinessType.values.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isAllSelected = selectedCategory == null;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6, right: 6),
                        child: ChoiceChip(
                          label: Text(TranslationKeys.allCategories.tr(context)),
                          selected: isAllSelected,
                          selectedColor: theme.primaryColor,
                          backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: isAllSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                            fontWeight: isAllSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isAllSelected ? theme.primaryColor : AppColors.cardBorder,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) selectedCategoryNotifier.value = null;
                          },
                        ),
                      );
                    }

                    final type = BusinessType.values[index - 1];
                    final isSelected = selectedCategory == type.name;

                    return Padding(
                      padding: const EdgeInsets.only(left: 6, right: 6),
                      child: ChoiceChip(
                        avatar: Icon(
                          type.icon,
                          size: 16,
                          color: isSelected ? Colors.white : theme.primaryColor,
                        ),
                        label: Text(
                          Localizations.localeOf(context).languageCode == 'ar' ? type.ar : type.en,
                        ),
                        selected: isSelected,
                        selectedColor: theme.primaryColor,
                        backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? theme.primaryColor : AppColors.cardBorder,
                          ),
                        ),
                        onSelected: (selected) {
                          selectedCategoryNotifier.value = selected ? type.name : null;
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 📦 Section 3: Business Grid Section (StatelessWidget)
/// ============================================================================
class _SectionBusinessGrid extends StatelessWidget {
  final List<BusinessModel> businesses;
  final String searchQuery;
  final String? selectedCategory;

  const _SectionBusinessGrid({
    required this.businesses,
    required this.searchQuery,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title and Result Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                searchQuery.isNotEmpty
                    ? "${TranslationKeys.searchResultsFor.tr(context)} '$searchQuery'"
                    : TranslationKeys.viewAllBusinesses.tr(context),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${businesses.length}",
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Business Grid or Empty State
          if (businesses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
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
                    "عذراً، لم يتم العثور على نشاط تجاري يطابق بحثك",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "جرّب البحث باسم آخر أو تغيير تصفية القطاعات.",
                    style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;
                if (constraints.maxWidth > 900) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.88,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    return _BusinessCardItem(business: businesses[index]);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 💳 Business Card Component (StatelessWidget)
/// ============================================================================
class _BusinessCardItem extends StatelessWidget {
  final BusinessModel business;

  const _BusinessCardItem({
    required this.business,
  });

  void _navigateToBusiness(BuildContext context) async {
    final businessProvider = context.read<BusinessProvider>();
    await businessProvider.selectBusiness(business.id);
    if (context.mounted) {
      changeScreen(context, const HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final name = business.localization.name.get(context);
    final addressText = business.addAddress.firstOrNull?.street ?? '';
    final logoUrl = business.theme.logoUrl;

    final hasRatings = business.ratings.isNotEmpty;
    final double avgRating = hasRatings
        ? (business.ratings.map((r) => r.rating).reduce((a, b) => a + b) /
            business.ratings.length)
        : 0.0;
    final String ratingDisplay = hasRatings ? avgRating.toStringAsFixed(1) : (isAr ? 'جديد' : 'New');

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
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
          onTap: () => _navigateToBusiness(context),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Cover Banner Stack
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Center(
                        child: Icon(
                          business.businessType.icon,
                          size: 52,
                          color: theme.primaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),

                    // Heart / Follow Button
                    Positioned(
                      top: 12,
                      right: isAr ? 12 : null,
                      left: isAr ? null : 12,
                      child: Consumer2<AuthProvider, FollowerProvider>(
                        builder: (context, authProvider, followerProvider, child) {
                          final isFollowing = followerProvider.isFollowing(business.id);

                          return Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black54 : Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isFollowing ? Icons.favorite : Icons.favorite_border,
                                color: isFollowing ? Colors.red : AppColors.textMuted,
                                size: 20,
                              ),
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
                                    SnackBar(
                                      content: Text(
                                        TranslationKeys.pleaseLoginToSaveItems.tr(context),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Rating Badge
                    Positioned(
                      top: 12,
                      left: isAr ? 12 : null,
                      right: isAr ? null : 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black54 : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasRatings ? Icons.star : Icons.new_releases_outlined,
                              color: hasRatings ? AppColors.star : theme.primaryColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ratingDisplay,
                              style: TextStyle(
                                color: isDark ? Colors.white : theme.textTheme.bodyLarge?.color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Verified Badge
                    if (business.isVerified)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.verified, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "معتمد",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Floating Logo Avatar
                    Positioned(
                      bottom: 0,
                      left: isAr ? null : 16,
                      right: isAr ? 16 : null,
                      child: Transform.translate(
                        offset: const Offset(0, 18),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: theme.primaryColor.withOpacity(0.12),
                            child: (logoUrl != null && logoUrl.isNotEmpty)
                                ? ClipOval(
                                    child: Image.network(
                                      logoUrl,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        business.businessType.icon,
                                        color: theme.primaryColor,
                                        size: 26,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    business.businessType.icon,
                                    color: theme.primaryColor,
                                    size: 26,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Card Content Body
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.storefront_outlined, size: 15, color: theme.primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                isAr ? business.businessType.ar : business.businessType.en,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          if (addressText.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    addressText,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // Visit Business Button
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ButtonApp(
                          label: TranslationKeys.enterStore.tr(context),
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () => _navigateToBusiness(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// 🔰 Section 4: KPI Features Section (StatelessWidget)
/// ============================================================================
class _SectionKpiBusiness extends StatelessWidget {
  const _SectionKpiBusiness();

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.whyOurPlatform.tr(context),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                flex: isMobile ? 0 : 1,
                child: _KpiCardItem(
                  title: TranslationKeys.verifiedStoresTitle.tr(context),
                  description: "جميع الأنشطة التجارية المعروضة تخضع لمعايير الفحص والتوثيق المباشر.",
                  icon: Icons.verified_user_outlined,
                  color: AppColors.green,
                ),
              ),
              SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: _KpiCardItem(
                  title: TranslationKeys.growingCommunityTitle.tr(context),
                  description: TranslationKeys.growingCommunityDesc.tr(context),
                  icon: Icons.people_outline,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: _KpiCardItem(
                  title: TranslationKeys.topRatingsTitle.tr(context),
                  description: TranslationKeys.topRatingsDesc.tr(context),
                  icon: Icons.star_outline,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCardItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _KpiCardItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 🚀 Section 5: Join Merchant Callout Banner (StatelessWidget)
/// ============================================================================
class _SectionJoinMerchantBanner extends StatelessWidget {
  const _SectionJoinMerchantBanner();

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [theme.primaryColor.withOpacity(0.3), theme.cardColor, theme.cardColor]
              : [theme.primaryColor, theme.cardColor, theme.cardColor],
        ),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: isMobile ? 0 : 7,
            child: Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationKeys.joinMerchantTitle.tr(context),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  TranslationKeys.joinMerchantDesc.tr(context),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: AppTextStyles.bodyText(context).copyWith(fontSize: 14),
                ),
                const SizedBox(height: 20),
                ButtonApp(
                  label: TranslationKeys.registerStoreNow.tr(context),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    changeScreen(context, const RegisterPage());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward compatibility typedef
typedef StoreCard = _BusinessCardItem;
