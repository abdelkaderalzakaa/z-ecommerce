import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/brand_model.dart';
import 'package:z_ecommerce/data/models/product/category_model.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/models/shared/follower_model.dart';
import 'package:z_ecommerce/data/models/shared/like_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/data/providers/follower_provider.dart';
import 'package:z_ecommerce/data/providers/like_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/global/theme/app_text_styles.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/pages/auth/register_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/categories_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_buisness.dart';

class BusinessEntry extends StatefulWidget {
  const BusinessEntry({super.key});

  @override
  State<BusinessEntry> createState() => _BusinessEntryState();
}

class _BusinessEntryState extends State<BusinessEntry> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isScrolled = false;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProvider>().fetchBusinesses();
      context.read<CategoryProvider>().fetchCategories();
      context.read<ProductProvider>().fetchAllProducts();
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollCategories(bool forward) {
    if (!_categoryScrollController.hasClients) return;
    final double target = forward
        ? _categoryScrollController.offset + 200
        : _categoryScrollController.offset - 200;
    _categoryScrollController.animateTo(
      target.clamp(0.0, _categoryScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 750;
    final theme = Theme.of(context);

    final businessProvider = context.watch<BusinessProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductProvider>();
    final brandProvider = context.watch<BrandProvider>();

    final activeBusinesses = businessProvider.activeBusinesses;
    final recommendedBusinesses = activeBusinesses
        .where((b) => b.isRecommended)
        .toList();
    final categories = categoryProvider.categories;
    final recommendedCategories = categories
        .where((c) => c.isRecommended)
        .toList();
    final brands = brandProvider.brands;
    final recommendedBrands = brands
        .where((b) => b.isRecommended)
        .toList();
    final allProducts = productProvider.allProducts;
    final recommendedProducts = allProducts
        .where((p) => p.isRecommended)
        .toList();
    final freeProducts = allProducts.where((p) => p.isFreeProduct).toList();

    final filteredStores = activeBusinesses.where((b) {
      final nameAr = b.localization.name.ar.toLowerCase();
      final nameEn = b.localization.name.en.toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchesSearch = nameAr.contains(q) || nameEn.contains(q);
      final matchesCategory =
          _selectedCategory == null || b.businessType.name == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderBuisness(isTransparent: !_isScrolled, isPlatform: true),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            /// Section 1: Hero Banner Section
            SectionHero(activeStoresCount: activeBusinesses.length),

            /// Section 2: Search and Category Filter Section
            SectionSearchAndCategory(
              searchController: _searchController,
              categoryScrollController: _categoryScrollController,
              searchQuery: _searchQuery,
              selectedCategory: _selectedCategory,
              onSearchChanged: (query) => setState(() => _searchQuery = query),
              onCategorySelected: (catId) =>
                  setState(() => _selectedCategory = catId),
              onScrollCategories: _scrollCategories,
            ),

            /// Search Results Section (if filtering active)
            if (_searchQuery.isNotEmpty || _selectedCategory != null) ...[
              TopSection(
                title: _searchQuery.isNotEmpty
                    ? "${TranslationKeys.searchResultsFor.tr(context)}'$_searchQuery'"
                    : TranslationKeys.selectedCategoryResults.tr(context),
              ),
              SectionTopBusiness(
                screenWidth: width * 0.75,
                businesses: filteredStores,
              ),
            ],

            /// Section 3: Top Businesses Section
            TopSection(
              title: TranslationKeys.topBusinesses.tr(context),
              buttonLabel: TranslationKeys.viewAllBusinesses.tr(context),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BusinessPage()),
                );
              },
            ),
            SectionTopBusiness(
              screenWidth: width * 0.75,
              businesses: recommendedBusinesses,
            ),

            /// Section 4: Recommended Products Section
            if (recommendedProducts.isNotEmpty) ...[
              TopSection(
                title: TranslationKeys.recommendedProducts.tr(context),
                buttonLabel: TranslationKeys.viewAllProducts.tr(context),
                onTap: () {},
              ),
              SectionTopProducts(
                screenWidth: width * 0.75,
                products: recommendedProducts,
              ),
            ],

            /// Section 4.5: Free Products Section
            if (freeProducts.isNotEmpty) ...[
              TopSection(
                title: TranslationKeys.freeProducts.tr(context),
                buttonLabel: TranslationKeys.viewAllProducts.tr(context),
                onTap: () {},
              ),
              SectionTopProducts(
                screenWidth: width * 0.75,
                products: freeProducts,
              ),
            ],

            /// Section 5: Top Categories Section
            TopSection(
              title: TranslationKeys.topCategories.tr(context),
              buttonLabel: TranslationKeys.viewAllCategories.tr(context),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesPage(),
                  ),
                );
              },
            ),
            SectionCategory(categories: recommendedCategories),

            /// Section 5.5: Top Brands Section
            if (recommendedBrands.isNotEmpty) ...[
              TopSection(
                title: TranslationKeys.topBrands.tr(context),
                buttonLabel: TranslationKeys.viewAllProducts.tr(context), // placeholder link
                onTap: () {},
              ),
              SectionBrands(
                screenWidth: width * 0.75,
                brands: recommendedBrands,
              ),
            ],

            /// Section 6: Statistics / KPI Section
            TopSection(title: TranslationKeys.whyOurPlatform.tr(context)),
            const SectionKpi(),

            /// Section 7: Join Merchant Section
            TopSection(title: TranslationKeys.ownABusiness.tr(context)),
            SectionJoin(
              isMobile: isMobile,
              activeStoresCount: activeBusinesses.length,
            ),

            const SizedBox(height: 40),

            /// Footer Section
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Section Widgets (Modular UI Construction & Full Localization Applied)
/// ---------------------------------------------------------------------------

/// Section 1: Hero Banner Section Widget
class SectionHero extends StatelessWidget {
  final int activeStoresCount;

  const SectionHero({super.key, this.activeStoresCount = 0});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 750;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
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
        horizontal: isMobile ? 20 : 60,
        vertical: 36,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: isMobile ? 0 : 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: isMobile
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: AppColors.star,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            TranslationKeys.businessPlatformBadge.tr(context),
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
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
                        fontSize: isMobile ? 24 : 36,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      TranslationKeys.businessHeroSubtitle.tr(context),
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: AppTextStyles.bodyText(context).copyWith(
                        color: isDark
                            ? theme.textTheme.bodyMedium?.color
                            : theme.primaryColor.withOpacity(0.9),
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: isMobile
                          ? WrapAlignment.center
                          : WrapAlignment.start,
                      children: [
                        ButtonApp(
                          label: TranslationKeys.exploreStores.tr(context),
                          icon: Icons.storefront,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BusinessPage(),
                              ),
                            );
                          },
                        ),
                        ButtonApp(
                          format: FormatButtonApp.outline,
                          label: TranslationKeys.joinAsMerchant.tr(context),
                          icon: Icons.add_business,
                          onPressed: () {
                            changeScreen(context, const RegisterPage());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isMobile) const SizedBox(width: 40),
              Expanded(
                flex: isMobile ? 0 : 5,
                child: Padding(
                  padding: EdgeInsets.only(top: isMobile ? 24 : 0),
                  child: Container(
                    height: isMobile ? 180 : 240,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: theme.primaryColor.withOpacity(0.05),
                              child: Center(
                                child: Icon(
                                  Icons.store_mall_directory_outlined,
                                  size: isMobile ? 70 : 100,
                                  color: theme.primaryColor.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          right: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withOpacity(0.08),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: AppColors.green,
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        TranslationKeys.verifiedStoresTitle.tr(
                                          context,
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color:
                                              theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      Text(
                                        "$activeStoresCount ${TranslationKeys.activeStoresNow.tr(context)}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color ??
                                              AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section 2: Search and Category Section Widget
class SectionSearchAndCategory extends StatelessWidget {
  final TextEditingController searchController;
  final ScrollController categoryScrollController;
  final String searchQuery;
  final String? selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategorySelected;
  final ValueChanged<bool> onScrollCategories;

  const SectionSearchAndCategory({
    super.key,
    required this.searchController,
    required this.categoryScrollController,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onScrollCategories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.cardColor,
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surface
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (val) => onSearchChanged(val.trim()),
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: TranslationKeys.searchBusinessHint.tr(context),
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category Scroll Bar with Navigation Buttons
            SizedBox(
              height: 90,
              child: Row(
                children: [
                  ButtonApp(
                    format: FormatButtonApp.icon,
                    label: "",
                    icon: Icons.arrow_back_ios_outlined,
                    onPressed: () => onScrollCategories(false),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Center(
                      child: ListView.builder(
                        controller: categoryScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: BusinessType.values.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            final isSelected = selectedCategory == null;
                            return GestureDetector(
                              onTap: () => onCategorySelected(null),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 55,
                                    width: 80,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.primaryColor
                                          : (isDark
                                                ? theme.colorScheme.surface
                                                : Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.primaryColor
                                            : AppColors.cardBorder,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.grid_view_rounded,
                                      color: isSelected
                                          ? Colors.white
                                          : theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    TranslationKeys.allCategories.tr(context),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? theme.primaryColor
                                          : theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final type = BusinessType.values[index - 1];
                          final isSelected = selectedCategory == type.name;
                          final color = theme.primaryColor;
                          final isAr =
                              Localizations.localeOf(context).languageCode ==
                              'ar';

                          return GestureDetector(
                            onTap: () => onCategorySelected(
                              isSelected ? null : type.name,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 55,
                                  width: 85,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color
                                        : color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? color
                                          : color.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Icon(
                                    type.icon,
                                    color: isSelected ? Colors.white : color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAr ? type.ar : type.en,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? color
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  ButtonApp(
                    format: FormatButtonApp.icon,
                    label: "",
                    icon: Icons.arrow_forward_ios_outlined,
                    onPressed: () => onScrollCategories(true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section 3: Top Businesses Horizontal List Widget
class SectionTopBusiness extends StatelessWidget {
  final double screenWidth;
  final List<BusinessModel> businesses;

  const SectionTopBusiness({
    super.key,
    required this.screenWidth,
    this.businesses = const [],
  });

  double _getCardWidth(double width) {
    if (width > 1200) return width * 0.22;
    if (width > 800) return width * 0.32;
    if (width > 500) return width * 0.45;
    return width * 0.75;
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = _getCardWidth(screenWidth);

    if (businesses.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            TranslationKeys.noStoresAvailable.tr(context),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    return SizedBox(
      height: 310,
      width: double.infinity,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: businesses.length,
        itemBuilder: (context, index) {
          final b = businesses[index];
          return SizedBox(
            width: cardWidth,
            child: CardBusiness(business: b, index: index),
          );
        },
      ),
    );
  }
}

/// Section 4: Top Products Horizontal List Widget
class SectionTopProducts extends StatelessWidget {
  final double screenWidth;
  final List<ProductModel> products;

  const SectionTopProducts({
    super.key,
    required this.screenWidth,
    this.products = const [],
  });

  double _getCardWidth(double width) {
    if (width > 1200) return width * 0.22;
    if (width > 800) return width * 0.32;
    if (width > 500) return width * 0.45;
    return width * 0.75;
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = _getCardWidth(screenWidth);

    if (products.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            TranslationKeys.noProductsAvailable.tr(context),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    return SizedBox(
      height: 310,
      width: double.infinity,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return SizedBox(
            width: cardWidth,
            child: CardProduct(product: p, index: index),
          );
        },
      ),
    );
  }
}

/// Section 5: Top Categories Section Widget
class SectionCategory extends StatelessWidget {
  final List<CategoryModel> categories;

  const SectionCategory({super.key, this.categories = const []});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    void navigateToCategory(CategoryModel? category) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoriesPage(category: category),
        ),
      );
    }

    if (categories.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            TranslationKeys.noCategoriesAvailable.tr(context),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;
          if (isNarrow) {
            return Column(
              children: categories.take(4).map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CardCategory(
                    width: constraints.maxWidth,
                    height: 90,
                    onTap: () => navigateToCategory(cat),
                    category: cat,
                  ),
                );
              }).toList(),
            );
          }

          final cat0 = categories[0];
          final cat1 = categories.length > 1 ? categories[1] : cat0;
          final cat2 = categories.length > 2 ? categories[2] : cat0;
          final cat3 = categories.length > 3 ? categories[3] : cat0;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: CardCategory(
                      width: width * 0.5,
                      height: 100,
                      onTap: () => navigateToCategory(cat0),
                      category: cat0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: CardCategory(
                      width: width * 0.25,
                      height: 100,
                      onTap: () => navigateToCategory(cat1),
                      category: cat1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: CardCategory(
                      width: width * 0.25,
                      height: 100,
                      onTap: () => navigateToCategory(cat2),
                      category: cat2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: CardCategory(
                      width: width * 0.5,
                      height: 100,
                      onTap: () => navigateToCategory(cat3),
                      category: cat3,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Section 6: KPI Statistics Section Widget
class SectionKpi extends StatelessWidget {
  const SectionKpi({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 750;
          if (isNarrow) {
            return Column(
              children: [
                CardKpi(
                  title: TranslationKeys.fastDeliveryTitle.tr(context),
                  description: TranslationKeys.fastDeliveryDesc.tr(context),
                  color: Colors.blue,
                  icon: Icons.local_shipping_outlined,
                ),
                const SizedBox(height: 24),
                CardKpi(
                  title: TranslationKeys.growingCommunityTitle.tr(context),
                  description: TranslationKeys.growingCommunityDesc.tr(context),
                  color: AppColors.green,
                  icon: Icons.people_outline,
                ),
                const SizedBox(height: 24),
                CardKpi(
                  title: TranslationKeys.topRatingsTitle.tr(context),
                  description: TranslationKeys.topRatingsDesc.tr(context),
                  color: AppColors.accent,
                  icon: Icons.star_outline,
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CardKpi(
                  title: TranslationKeys.fastDeliveryTitle.tr(context),
                  description: TranslationKeys.fastDeliveryDesc.tr(context),
                  color: Colors.blue,
                  icon: Icons.local_shipping_outlined,
                ),
              ),
              Expanded(
                child: CardKpi(
                  title: TranslationKeys.growingCommunityTitle.tr(context),
                  description: TranslationKeys.growingCommunityDesc.tr(context),
                  color: AppColors.green,
                  icon: Icons.people_outline,
                ),
              ),
              Expanded(
                child: CardKpi(
                  title: TranslationKeys.topRatingsTitle.tr(context),
                  description: TranslationKeys.topRatingsDesc.tr(context),
                  color: AppColors.accent,
                  icon: Icons.star_outline,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Section 7: Join Merchant Section Widget
class SectionJoin extends StatelessWidget {
  final bool isMobile;
  final int activeStoresCount;

  const SectionJoin({
    super.key,
    this.isMobile = false,
    this.activeStoresCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.all(10),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  theme.primaryColor.withOpacity(0.3),
                  theme.cardColor,
                  theme.cardColor,
                ]
              : [theme.primaryColor, theme.cardColor, theme.cardColor],
        ),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 10,
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
              crossAxisAlignment: isMobile
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationKeys.joinMerchantTitle.tr(context),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  TranslationKeys.joinMerchantDesc.tr(context),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: isDark
                        ? theme.textTheme.bodyMedium?.color
                        : theme.primaryColor.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: isMobile
                      ? WrapAlignment.center
                      : WrapAlignment.start,
                  children: [
                    ChipApp(
                      lable: TranslationKeys.easyOrderManagement.tr(context),
                      icon: Icons.done,
                      color: AppColors.green,
                    ),
                    ChipApp(
                      lable: TranslationKeys.fullAnalyticsDashboard.tr(context),
                      icon: Icons.done,
                      color: AppColors.green,
                    ),
                    ChipApp(
                      lable: TranslationKeys.technicalSupportShipping.tr(
                        context,
                      ),
                      icon: Icons.done,
                      color: AppColors.green,
                    ),
                  ],
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
          if (!isMobile) const SizedBox(width: 24),
          Expanded(
            flex: isMobile ? 0 : 4,
            child: Padding(
              padding: EdgeInsets.only(top: isMobile ? 20 : 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 56,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$activeStoresCount",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      TranslationKeys.activeStoresNow.tr(context),
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            theme.textTheme.bodyMedium?.color ??
                            AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Shared Component Widgets (Fully Localized)
/// ---------------------------------------------------------------------------

class TopSection extends StatelessWidget {
  final String title;
  final String? buttonLabel;
  final VoidCallback? onTap;

  const TopSection({
    super.key,
    required this.title,
    this.buttonLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 40, 10, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          if (buttonLabel != null && buttonLabel!.isNotEmpty && onTap != null)
            ButtonApp(
              format: FormatButtonApp.text,
              label: buttonLabel!,
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: onTap,
            ),
        ],
      ),
    );
  }
}

class ChipApp extends StatelessWidget {
  final IconData? icon;
  final String lable;
  final Color color;

  const ChipApp({
    super.key,
    this.icon,
    required this.lable,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            lable,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class CardBusiness extends StatelessWidget {
  final BusinessModel business;
  final int index;

  const CardBusiness({super.key, required this.business, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    final title = isAr
        ? (business.localization.name.ar.isNotEmpty
              ? business.localization.name.ar
              : business.localization.name.en)
        : (business.localization.name.en.isNotEmpty
              ? business.localization.name.en
              : business.localization.name.ar);

    final coverUrl = business.theme.coverBannerUrl;
    final hasRatings = business.ratings.isNotEmpty;
    final double avgRating = hasRatings
        ? (business.ratings.map((r) => r.rating).reduce((a, b) => a + b) /
              business.ratings.length)
        : 0.0;
    final String ratingDisplay = hasRatings
        ? avgRating.toStringAsFixed(1)
        : (isAr ? 'جديد' : 'New');

    void openStore() {
      context.read<BusinessProvider>().selectBusiness(business.id);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }

    return GestureDetector(
      onTap: openStore,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor.withOpacity(0.7),
                          theme.primaryColor,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      image: (coverUrl != null && coverUrl.isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage(coverUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (coverUrl == null || coverUrl.isEmpty)
                        ? Center(
                            child: Icon(
                              Icons.storefront,
                              size: 44,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    top: 6,
                    right: isAr ? 6 : null,
                    left: isAr ? null : 6,
                    child: ChipApp(
                      icon: hasRatings
                          ? Icons.star
                          : Icons.new_releases_outlined,
                      lable: ratingDisplay,
                      color: hasRatings ? AppColors.star : theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title.isNotEmpty ? title : "---",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonApp(
                      isFullWidth: true,
                      label: TranslationKeys.enterStore.tr(context),
                      fontSize: 12,
                      radius: 8,
                      onPressed: openStore,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Consumer2<AuthProvider, FollowerProvider>(
                    builder: (context, authProvider, followerProvider, child) {
                      final isFollowing = followerProvider.isFollowing(
                        business.id,
                      );
                      return ButtonApp(
                        format: FormatButtonApp.icon,
                        label: "",
                        icon: isFollowing
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isFollowing
                            ? Colors.red
                            : theme.textTheme.bodyMedium?.color,
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
                                  TranslationKeys.pleaseLoginToSaveItems.tr(
                                    context,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardProduct extends StatelessWidget {
  final ProductModel product;
  final int index;

  const CardProduct({super.key, required this.product, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = product.name;

    final bool isFree = product.isFreeProduct || product.basePrice == 0;
    final priceStr = isFree
        ? TranslationKeys.free.tr(context)
        : "\$${product.basePrice.toStringAsFixed(2)}";

    final ratingCount = product.ratings.length;
    final double avgRating = ratingCount > 0
        ? product.ratings.fold(0.0, (sum, r) => sum + r.rating) / ratingCount
        : 0.0;

    final imageUrl = product.displayImage;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor.withOpacity(0.6),
                        theme.primaryColor,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 44,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: ChipApp(
                    icon: Icons.star,
                    lable: avgRating.toStringAsFixed(1),
                    color: AppColors.star,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        priceStr,
                        style: AppTextStyles.priceStyle(
                          context,
                        ).copyWith(fontSize: 13, color: theme.primaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Consumer2<AuthProvider, LikeProvider>(
                  builder: (context, auth, likeProvider, _) {
                    final isFavorite = likeProvider.hasLiked(product.id);
                    return ButtonApp(
                      format: FormatButtonApp.icon,
                      label: "",
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      onPressed: () async {
                        if (auth.isAuthenticated) {
                          final like = LikeModel(
                            id: '',
                            userId: auth.currentUser!.id,
                            targetId: product.id,
                            targetType: 'product',
                            createdAt: DateTime.now(),
                          );
                          await likeProvider.toggleLike(like);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                TranslationKeys.pleaseLoginToSaveItems.tr(
                                  context,
                                ),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
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

class CardCategory extends StatelessWidget {
  final CategoryModel category;
  final double height;
  final double width;
  final VoidCallback onTap;

  const CardCategory({
    super.key,
    required this.category,
    required this.height,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Ensure the color is visible on the current theme
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.all(4),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: category.bgColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category.bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      category.icon ?? Icons.category,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionBrands extends StatelessWidget {
  final double screenWidth;
  final List<BrandModel> brands;

  const SectionBrands({
    super.key,
    required this.screenWidth,
    this.brands = const [],
  });

  double _getCardWidth(double width) {
    if (width > 1200) return width * 0.15;
    if (width > 800) return width * 0.20;
    if (width > 500) return width * 0.25;
    return width * 0.30;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = _getCardWidth(width);

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final b = brands[index];
          return SizedBox(
            width: cardWidth,
            child: CardBrand(brand: b),
          );
        },
      ),
    );
  }
}

class CardBrand extends StatelessWidget {
  final BrandModel brand;

  const CardBrand({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Can be routed to a brand page later
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      image: (brand.logoUrl != null && brand.logoUrl!.isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage(brand.logoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (brand.logoUrl == null || brand.logoUrl!.isEmpty)
                        ? Icon(
                            Icons.branding_watermark_rounded,
                            size: 32,
                            color: theme.primaryColor.withOpacity(0.5),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  brand.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardKpi extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const CardKpi({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          Positioned(
            top: -20,
            right: isAr ? 20 : null,
            left: isAr ? null : 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
