import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/shared/follower_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/follower_provider.dart';
import 'package:z_ecommerce/data/services/geo_proximity_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/global/theme/app_text_styles.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';
import 'package:z_ecommerce/presentation/widgets/common/custom_network_image.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_buisness.dart';
import 'package:z_ecommerce/presentation/widgets/home/customer_location_bar.dart';

/// ============================================================================
/// 🏛️ BusinessPage (StatelessWidget)
/// واجهة استكشاف الأنشطة التجارية الشاملة المدعومة بمحرك القرب الجغرافي ونطاق التوصيل
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
                  const Icon(Icons.error_outline, size: 64, color: AppColors.accent),
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

                /// 2. Customer Location Bar (شريط موقع التوصيل)
                Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: const CustomerLocationBar(),
                ),

                /// 3. Search and Category Filter Section
                _SectionSearchAndFilter(
                  searchQueryNotifier: searchQueryNotifier,
                  selectedCategoryNotifier: selectedCategoryNotifier,
                ),

                /// 4. Business Catalog Grid Section
                ValueListenableBuilder<String>(
                  valueListenable: searchQueryNotifier,
                  builder: (context, searchQuery, _) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: selectedCategoryNotifier,
                      builder: (context, selectedCategory, _) {
                        final analyzedList = businessProvider.getGeoSortedBusinesses(
                          searchQuery: searchQuery,
                          categoryId: selectedCategory,
                          isAr: Localizations.localeOf(context).languageCode == 'ar',
                        );

                        return _SectionBusinessGrid(
                          analyzedList: analyzedList,
                          searchQuery: searchQuery,
                          selectedCategory: selectedCategory,
                        );
                      },
                    );
                  },
                ),

                /// 5. Platform Quality KPI Features Section
                const _SectionKpiBusiness(),

                /// 6. Join Merchant Callout Banner
                const _SectionJoinMerchantBanner(),

                const SizedBox(height: 40),

                /// 7. Footer Section
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
                  theme.primaryColor,
                  theme.scaffoldBackgroundColor,
                  theme.scaffoldBackgroundColor,
                ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 36,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              // Return to Home Link
              Align(
                alignment: isMobile ? Alignment.center : Alignment.centerRight,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.cardBorder : Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 16,
                            color: isDark ? theme.textTheme.bodyLarge?.color : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isAr ? 'العودة للمدخل الرئيسي' : 'Back to main',
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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final businessProvider = context.watch<BusinessProvider>();
    final activeLocation = businessProvider.activeCustomerLocation;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Input Bar
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
          const SizedBox(height: 14),

          // 2. Geographic Proximity & Delivery Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Filter: All Regions
                _buildGeoChip(
                  context: context,
                  label: isAr ? 'كافة المناطق' : 'All Regions',
                  icon: Icons.public_rounded,
                  isSelected: businessProvider.selectedProximityFilter == null && !businessProvider.onlyDeliverableFilter,
                  onSelected: () {
                    businessProvider.setProximityFilter(null);
                    businessProvider.toggleDeliverableFilter(false);
                  },
                ),

                // Filter: Same Town (إذا تم تحديد موقع)
                if (activeLocation != null && activeLocation.town.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildGeoChip(
                    context: context,
                    label: isAr ? '📍 في ${activeLocation.town.get(context)}' : '📍 In ${activeLocation.town.get(context)}',
                    count: businessProvider.countBusinessesInTier(GeoProximityTier.sameTown, isAr: isAr),
                    isSelected: businessProvider.selectedProximityFilter == GeoProximityTier.sameTown,
                    color: const Color(0xFF10B981),
                    onSelected: () {
                      businessProvider.setProximityFilter(
                        businessProvider.selectedProximityFilter == GeoProximityTier.sameTown
                            ? null
                            : GeoProximityTier.sameTown,
                      );
                    },
                  ),
                ],

                // Filter: Same District
                if (activeLocation != null && activeLocation.district.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildGeoChip(
                    context: context,
                    label: isAr ? '🏢 في قضاء ${activeLocation.district.get(context)}' : '🏢 In ${activeLocation.district.get(context)} district',
                    count: businessProvider.countBusinessesInTier(GeoProximityTier.sameDistrict, isAr: isAr),
                    isSelected: businessProvider.selectedProximityFilter == GeoProximityTier.sameDistrict,
                    color: const Color(0xFF0284C7),
                    onSelected: () {
                      businessProvider.setProximityFilter(
                        businessProvider.selectedProximityFilter == GeoProximityTier.sameDistrict
                            ? null
                            : GeoProximityTier.sameDistrict,
                      );
                    },
                  ),
                ],

                // Filter: Same Governorate
                if (activeLocation != null && activeLocation.governorate.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildGeoChip(
                    context: context,
                    label: isAr ? '🗺️ في محافظة ${activeLocation.governorate.get(context)}' : '🗺️ In ${activeLocation.governorate.get(context)}',
                    count: businessProvider.countBusinessesInTier(GeoProximityTier.sameGovernorate, isAr: isAr),
                    isSelected: businessProvider.selectedProximityFilter == GeoProximityTier.sameGovernorate,
                    color: const Color(0xFF6366F1),
                    onSelected: () {
                      businessProvider.setProximityFilter(
                        businessProvider.selectedProximityFilter == GeoProximityTier.sameGovernorate
                            ? null
                            : GeoProximityTier.sameGovernorate,
                      );
                    },
                  ),
                ],

                // Filter: Deliverable only (يوصل إليك)
                const SizedBox(width: 8),
                _buildGeoChip(
                  context: context,
                  label: isAr ? '🛵 يوصل لموقعك' : '🛵 Delivers to you',
                  count: businessProvider.countDeliverableBusinesses(isAr: isAr),
                  isSelected: businessProvider.onlyDeliverableFilter,
                  color: Colors.amber.shade800,
                  onSelected: () {
                    businessProvider.toggleDeliverableFilter(null);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. BusinessType Choice Chips Bar
          SizedBox(
            height: 40,
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
                        padding: const EdgeInsets.only(left: 4, right: 4),
                        child: ChoiceChip(
                          label: Text(TranslationKeys.allCategories.tr(context)),
                          selected: isAllSelected,
                          selectedColor: theme.primaryColor,
                          backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: isAllSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                            fontWeight: isAllSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12.5,
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
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: ChoiceChip(
                        avatar: Icon(
                          type.icon,
                          size: 15,
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
                          fontSize: 12.5,
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

  Widget _buildGeoChip({
    required BuildContext context,
    required String label,
    IconData? icon,
    int? count,
    required bool isSelected,
    Color? color,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.primaryColor;

    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: icon != null
          ? Icon(icon, size: 16, color: isSelected ? Colors.white : activeColor)
          : null,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.25) : activeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : activeColor,
                ),
              ),
            ),
          ],
        ],
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
      ),
      backgroundColor: theme.cardColor,
      selectedColor: activeColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? activeColor : AppColors.cardBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

/// ============================================================================
/// 📦 Section 3: Business Grid Section (StatelessWidget)
/// ============================================================================
class _SectionBusinessGrid extends StatelessWidget {
  final List<BusinessGeoAnalysis> analyzedList;
  final String searchQuery;
  final String? selectedCategory;

  const _SectionBusinessGrid({
    required this.analyzedList,
    required this.searchQuery,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

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
                    : (isAr ? 'الأنشطة التجارية المتاحة' : 'Available Businesses'),
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
                  "${analyzedList.length}",
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
          if (analyzedList.isEmpty)
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
                    isAr ? "عذراً، لم يتم العثور على نشاط تجاري يطابق معاييرك" : "No businesses matching your criteria",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr
                        ? "جرّب تغيير المنطقة أو تصفية القطاعات أو إزالة فلتر التوصيل."
                        : "Try changing your area or expanding the category filters.",
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
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: analyzedList.length,
                  itemBuilder: (context, index) {
                    return _BusinessCardItem(analysis: analyzedList[index]);
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
/// 💳 Business Card Component (StatelessWidget with Smart Proximity Badges)
/// ============================================================================
class _BusinessCardItem extends StatelessWidget {
  final BusinessGeoAnalysis analysis;

  const _BusinessCardItem({
    required this.analysis,
  });

  void _navigateToBusiness(BuildContext context) async {
    final businessProvider = context.read<BusinessProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    await businessProvider.selectBusiness(analysis.business.id);
    
    if (context.mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      changeScreen(context, const HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = analysis.business;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final name = business.localization.name.get(context);
    final sloganText = business.localization.slogan.get(context);
    final logoUrl = business.theme.logoUrl;

    final hasRatings = business.ratings.isNotEmpty;
    final double avgRating = business.averageRating;
    final String ratingDisplay = hasRatings ? avgRating.toStringAsFixed(1) : (isAr ? 'جديد' : 'New');

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: analysis.proximityTier == GeoProximityTier.sameTown
              ? const Color(0xFF10B981).withOpacity(0.4)
              : AppColors.cardBorder,
          width: analysis.proximityTier == GeoProximityTier.sameTown ? 1.5 : 1,
        ),
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
                                size: 18,
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

                    // Rating & Proximity Badges Row (Top Left/Right)
                    Positioned(
                      top: 12,
                      left: isAr ? 12 : null,
                      right: isAr ? null : 12,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Rating Badge
                          Container(
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
                        ],
                      ),
                    ),

                    // Verified Badge
                    if (business.isVerified)
                      Positioned(
                        top: 44,
                        left: isAr ? 12 : null,
                        right: isAr ? null : 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.verified, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                "معتمد",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
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
                                    child: CustomNetworkImage(
                                      imageUrl: logoUrl,
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
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Smart Geo Location Snippet & Tier Tag
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Proximity Badge
                              if (analysis.proximityTier != GeoProximityTier.allLebanon)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: analysis.proximityTier.badgeColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: analysis.proximityTier.badgeColor.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(analysis.proximityTier.icon, size: 12, color: analysis.proximityTier.badgeColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        isAr
                                            ? analysis.proximityTier.labelAr()
                                            : analysis.proximityTier.labelEn(),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: analysis.proximityTier.badgeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Delivery Reach Tag
                              if (analysis.canDeliver)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade800.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delivery_dining, size: 13, color: Colors.amber.shade800),
                                      const SizedBox(width: 3),
                                      Text(
                                        isAr ? 'يوصل إليك' : 'Delivers',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          // Address text snippet
                          if (analysis.locationSnippet.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.place_outlined, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    analysis.locationSnippet,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                          if (sloganText.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              sloganText,
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),

                      // Visit Business Button
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ButtonApp(
                          label: TranslationKeys.enterStore.tr(context),
                          icon: Icons.arrow_forward_rounded,
                          fontSize: 12.5,
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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
      child: Column(
        children: [
          Text(
            TranslationKeys.whyOurPlatform.tr(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildKpiCard(
                context,
                icon: Icons.verified_user_outlined,
                title: isAr ? 'متاجر معتمدة وموثقة' : 'Verified Stores Only',
                desc: isAr ? 'نضمن لك التعامل مع متاجر موثقة ومعتمدة رسمياً.' : 'Deal with officially verified businesses.',
                width: isMobile ? double.infinity : 260,
              ),
              _buildKpiCard(
                context,
                icon: Icons.delivery_dining_outlined,
                title: isAr ? 'توصيل سريع وموثوق' : 'Fast & Reliable Delivery',
                desc: isAr ? 'توصيل مباشر إلى بلدتك وقضائك بأفضل الأسعار.' : 'Direct delivery to your town and district.',
                width: isMobile ? double.infinity : 260,
              ),
              _buildKpiCard(
                context,
                icon: Icons.storefront_outlined,
                title: isAr ? 'تنوع في الأنشطة والخدمات' : 'Diversity & Variety',
                desc: isAr ? 'متاجر تجزئة، مطاعم، مقاهي، وخدمات في مكان واحد.' : 'Retail, restaurants, cafes & services in one place.',
                width: isMobile ? double.infinity : 260,
              ),
              _buildKpiCard(
                context,
                icon: Icons.support_agent_outlined,
                title: isAr ? 'دعم فني وتواصل دائم' : '24/7 Support & Care',
                desc: isAr ? 'فريق جاهز لخدمتك والإجابة على استفساراتك دائماً.' : 'Dedicated team ready to assist you anytime.',
                width: isMobile ? double.infinity : 260,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required double width,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: theme.primaryColor),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.store_mall_directory_outlined, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              isAr ? 'هل تمتلك نشاطاً تجارياً أو متجراً؟' : 'Do you own a business or store?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAr
                  ? 'انضم إلى منصتنا الرقمية الآن ووسّع نطاق عملائك وتوصيلك في كافة المناطق اللبنانية.'
                  : 'Join our digital platform now and expand your reach across Lebanon.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_business_outlined),
              label: Text(
                isAr ? 'سجّل متجرك مجاناً' : 'Register Your Business',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BusinessPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
