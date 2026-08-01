import 'dart:async';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../data/models/store/business_model.dart';
import '../../../data/models/product/offer_model.dart';
import '../../../data/models/product/product_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../../data/providers/offer_provider.dart';
import '../../../data/providers/product_provider.dart';
import '../../global/locale_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/home_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/profile_customer/profile_page.dart';
import 'package:z_ecommerce/presentation/pages/auth/login_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_page.dart';
import 'package:z_ecommerce/presentation/pages/auth/register_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/offer/offer_details_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/product_details_page.dart';

class BusinessEntryPage extends StatefulWidget {
  const BusinessEntryPage({super.key});

  @override
  State<BusinessEntryPage> createState() => _BusinessEntryPageState();
}

class _BusinessEntryPageState extends State<BusinessEntryPage> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoriesScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _heroTimer;
  int _currentHeroImageIndex = 0;

  final List<String> _heroImages = [
    'https://images.unsplash.com/photo-1472851294608-062f824d29cc?q=80&w=2070',
    'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=2070',
    'https://images.unsplash.com/photo-1542204165-65bf26472b9b?q=80&w=2070',
  ];

  bool _isScrolled = false;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });

    _heroTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentHeroImageIndex =
              (_currentHeroImageIndex + 1) % _heroImages.length;
        });
      }
    });

    // تهيئة البيانات الحقيقية من الـ Providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OfferProvider>().listenToActiveOffers();
      context.read<ProductProvider>().listenToAllProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _categoriesScrollController.dispose();
    _searchController.dispose();
    _heroTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = Provider.of<BusinessProvider>(context);
    final storeTheme = businessProvider.selectedBusiness?.theme;

    final primaryColor = storeTheme?.primaryColorValue ?? Colors.black;
    final secondaryColor =
        storeTheme?.secondaryColorValue ?? const Color(0xFF10B981);
    final bgColor = storeTheme?.backgroundColorValue ?? Colors.white;
    final fontFamily =
        storeTheme?.fontFamily != null && storeTheme!.fontFamily.isNotEmpty
        ? storeTheme.fontFamily
        : 'Cairo';

    final dynamicTheme = ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      fontFamily: fontFamily,
      scaffoldBackgroundColor: bgColor,
    );

    return Theme(
      data: dynamicTheme,
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _buildHeader(innerContext),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      _buildHeroSection(innerContext),
                      Positioned(
                        bottom: -60,
                        child: _buildCategoriesBar(innerContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  _buildRecommendedStoresSection(innerContext),
                  _buildStoresGrid(innerContext),
                  _buildOffersSection(innerContext),
                  _buildTrendingProducts(innerContext),
                  _buildFeaturesSection(innerContext),
                  _buildNewsletterSection(innerContext),
                  _buildHowItWorksSection(innerContext),
                  _buildFooter(innerContext),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.black87,
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    final primaryColor = Theme.of(context).primaryColor;

    return AppBar(
      backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
      elevation: _isScrolled ? 4 : 0,
      centerTitle: false,
      title: Row(
        children: [
          // Logo of the institution
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(4),
              child: Image.network(
                'https://ui-avatars.com/api/?name=Alzaka&background=ffffff&color=000000&bold=true&font-size=0.33',
                height: 36,
                width: 36,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.business,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isAr ? 'الزكاء للحلول الرقمية' : 'Alzaka Digital',
            style: TextStyle(
              color: _isScrolled ? Colors.black87 : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.language,
            color: _isScrolled ? Colors.black87 : Colors.white,
          ),
          onPressed: () => context.read<LocaleProvider>().toggleLanguage(),
        ),
        const SizedBox(width: 8),
        if (!auth.isAuthenticated) ...[
          TextButton(
            onPressed: () => changeScreen(context, const LoginPage()),
            style: TextButton.styleFrom(
              foregroundColor: _isScrolled ? Colors.black87 : Colors.white,
            ),
            child: Text(
              TranslationKeys.login.tr(context),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () => changeScreen(context, const RegisterPage()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isScrolled ? primaryColor : Colors.white,
                foregroundColor: _isScrolled ? Colors.white : primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                TranslationKeys.createAccount.tr(context),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ] else ...[
          IconButton(
            icon: Icon(
              Icons.person,
              color: _isScrolled ? Colors.black87 : Colors.white,
            ),
            onPressed: () => changeScreen(context, const ProfilePage()),
          ),
          const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: Container(
                key: ValueKey<int>(_currentHeroImageIndex),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_heroImages[_currentHeroImageIndex]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Align(
              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: isAr ? 24.0 : 60.0,
                  right: isAr ? 60.0 : 24.0,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 800;
                    final textContent = Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60), // Space for AppBar
                        SizedBox(
                          width: 600,
                          child: Text(
                            isAr
                                ? 'كل ما تحتاجه في مكان واحد'
                                : 'Everything you need in one place',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 600,
                          child: Text(
                            isAr
                                ? 'اكتشف أفضل المتاجر، العروض الحصرية، والمنتجات الرائعة.'
                                : 'Discover top stores, exclusive offers, and amazing products.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Search Bar
                        Container(
                          width: 600,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: isAr
                                        ? 'ابحث عن متاجر، منتجات، أو فئات...'
                                        : 'Search for stores, products, or categories...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _showSnackBar(
                                    isAr ? 'جاري البحث...' : 'Searching...',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 80,
                        ), // Space to prevent overlap with Categories Bar
                      ],
                    );

                    if (isDesktop) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (!isAr)
                            Expanded(child: textContent)
                          else
                            Expanded(
                              child: Center(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1556740714-a8395b3bf30f?q=80&w=2070', // Payment terminal / Side image
                                  height: 300,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          if (!isAr)
                            Expanded(
                              child: Center(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1556740714-a8395b3bf30f?q=80&w=2070',
                                  height: 300,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          else
                            Expanded(child: textContent),
                        ],
                      );
                    } else {
                      return textContent;
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesBar(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';

    final categories = [
      {
        'icon': Icons.restaurant,
        'en': 'Restaurants',
        'ar': 'مطاعم',
        'id': 'restaurant',
      },
      {
        'icon': Icons.devices,
        'en': 'Electronics',
        'ar': 'إلكترونيات',
        'id': 'electronics',
      },
      {
        'icon': Icons.home,
        'en': 'Home & Living',
        'ar': 'المنزل والديكور',
        'id': 'appliances',
      },
      {
        'icon': Icons.checkroom,
        'en': 'Fashion',
        'ar': 'أزياء',
        'id': 'fashion',
      },
      {
        'icon': Icons.face_retouching_natural,
        'en': 'Beauty',
        'ar': 'تجميل',
        'id': 'beauty',
      },
    ];

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      constraints: const BoxConstraints(maxWidth: 1000),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Arrow
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black54),
              onPressed: () {
                _categoriesScrollController.animateTo(
                  (_categoriesScrollController.offset - 120).clamp(
                    0,
                    _categoriesScrollController.position.maxScrollExtent,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
          // Categories
          Expanded(
            child: SizedBox(
              height: 130, // Increased height to prevent bottom overflow
              child: ListView.builder(
                controller: _categoriesScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final catId = cat['id'] as String;
                  final isSelected = _selectedCategory == catId;

                  return SizedBox(
                    width:
                        (MediaQuery.of(context).size.width * 0.8 - 100) /
                        min(
                          4,
                          categories.length,
                        ), // Calculate width so 4 items fit max
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedCategory == catId) {
                            _selectedCategory = null; // deselect
                          } else {
                            _selectedCategory = catId;
                          }
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[50],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200]!,
                              ),
                            ),
                            child: Icon(
                              cat['icon'] as IconData,
                              color: isSelected ? Colors.white : Colors.black87,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isAr ? cat['ar'] as String : cat['en'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Right Arrow
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.black54),
              onPressed: () {
                _categoriesScrollController.animateTo(
                  (_categoriesScrollController.offset + 120).clamp(
                    0,
                    _categoriesScrollController.position.maxScrollExtent,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              final cards = [
                _FeatureCard(
                  icon: Icons.local_shipping_outlined,
                  title: isAr
                      ? 'توصيل موثوق وسريع'
                      : 'Fast & Reliable Delivery',
                  description: isAr
                      ? 'نضمن لك وصول منتجاتك بسرعة وأمان أينما كنت، عبر شبكة واسعة من شركاء التوصيل المعتمدين.'
                      : 'We ensure your products arrive quickly and safely wherever you are, through our certified delivery partners.',
                  color: Theme.of(context).primaryColor,
                ),
                _FeatureCard(
                  icon: Icons.shield_outlined,
                  title: isAr ? 'تسوق بأمان تام' : 'Secure Shopping',
                  description: isAr
                      ? 'نوفر لك بوابات دفع إلكترونية مشفرة وآمنة 100% لضمان راحة بالك في كل عملية شراء.'
                      : 'We provide 100% encrypted and secure payment gateways to guarantee your peace of mind.',
                  color: Theme.of(context).primaryColor,
                ),
                _FeatureCard(
                  icon: Icons.storefront_outlined,
                  title: isAr ? 'متاجر معتمدة' : 'Verified Stores',
                  description: isAr
                      ? 'جميع المتاجر في منصتنا تخضع لعملية مراجعة دقيقة لضمان أعلى معايير الجودة والموثوقية.'
                      : 'All stores on our platform undergo a strict review process to ensure the highest standards.',
                  color: Theme.of(context).primaryColor,
                ),
              ];

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: cards
                      .map(
                        (c) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: c,
                          ),
                        ),
                      )
                      .toList(),
                );
              } else {
                return Column(
                  children: cards
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: c,
                        ),
                      )
                      .toList(),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNewsletterSection(BuildContext context) {
    return const _PremiumNewsletterSection();
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return const _PremiumHowItWorksSection();
  }

  Widget _buildRecommendedStoresSection(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    final businessProvider = Provider.of<BusinessProvider>(context);
    final displayStores = businessProvider.businesses.take(3).toList();

    if (displayStores.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'موصى به لك' : 'Recommended For You',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isAr
                    ? 'اكتشف أفضل المتاجر المختارة بعناية لك'
                    : 'Discover the best stores carefully selected for you',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 900;

                  if (isDesktop && displayStores.length >= 3) {
                    return SizedBox(
                      height: 500,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _PremiumRecommendedCard(
                              business: displayStores[0],
                              isAr: isAr,
                              isHero: true,
                              rank: 1,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _PremiumRecommendedCard(
                                    business: displayStores[1],
                                    isAr: isAr,
                                    isHero: false,
                                    rank: 2,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: _PremiumRecommendedCard(
                                    business: displayStores[2],
                                    isAr: isAr,
                                    isHero: false,
                                    rank: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Mobile/Tablet or less than 3 stores
                  return SizedBox(
                    height: 400,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: displayStores.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: constraints.maxWidth * 0.8,
                          child: _PremiumRecommendedCard(
                            business: displayStores[index],
                            isAr: isAr,
                            isHero: true,
                            rank: index + 1,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoresGrid(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr
                        ? 'تصفح أفضل المتاجر لدينا وتسوق بكل ثقة'
                        : 'Browse our top stores and shop with confidence',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () =>
                        changeScreenReplacement(context, const BusinessPage()),
                    child: Text(
                      isAr ? 'الجميع' : 'See All',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  final businessProvider = Provider.of<BusinessProvider>(
                    context,
                  );
                  final businesses = businessProvider.businesses;
                  final filteredStores = businesses.where((b) {
                    final nameAr = b.localization.name.ar.toLowerCase();
                    final nameEn = b.localization.name.en.toLowerCase();
                    final q = _searchQuery.toLowerCase();
                    return nameAr.contains(q) || nameEn.contains(q);
                  }).toList();

                  if (filteredStores.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isAr
                                  ? 'عذراً، لم يتم العثور على أي متجر يطابق بحثك.'
                                  : 'Sorry, no stores found matching your criteria.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
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
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 32,
                      mainAxisSpacing: 32,
                    ),
                    itemCount: filteredStores.length,
                    itemBuilder: (context, index) {
                      return _StoreCard(
                        business: filteredStores[index],
                        isAr: isAr,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOffersSection(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';

    return Consumer<OfferProvider>(
      builder: (context, offerProvider, child) {
        final List<OfferModel> displayOffers =
            offerProvider.activeOffers.take(6).toList();

        return Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? 'العروض المميزة' : 'Special Offers',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showSnackBar(
                          isAr
                              ? 'سيتم عرض جميع العروض قريباً'
                              : 'Will show all offers soon',
                        ),
                        child: Text(
                          isAr ? 'الجميع' : 'See All',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (offerProvider.isLoading)
                    const SizedBox(
                      height: 350,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (displayOffers.isEmpty)
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          isAr
                              ? 'لا توجد عروض متاحة حالياً'
                              : 'No offers available at the moment',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 350,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayOffers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 24),
                        itemBuilder: (context, index) {
                          final offer = displayOffers[index];
                          return _TrendingOfferCard(
                            offer: offer,
                            businessId: offer.businessId,
                            isAr: isAr,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendingProducts(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';

    return Consumer2<ProductProvider, BusinessProvider>(
      builder: (context, productProvider, businessProvider, child) {
        final productsList = productProvider.allProducts;
        final List<ProductModel> trending = List.from(productsList)
          ..shuffle(Random(42));
        final displayProducts = trending.take(6).toList();
        final businesses = businessProvider.businesses;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? 'المنتجات الشائعة' : 'Trending Products',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showSnackBar(
                          isAr
                              ? 'سيتم عرض جميع المنتجات قريباً'
                              : 'Will show all products soon',
                        ),
                        child: Text(
                          isAr ? 'الجميع' : 'See All',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (productProvider.isLoading)
                    const SizedBox(
                      height: 350,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (displayProducts.isEmpty)
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          isAr
                              ? 'لا توجد منتجات متاحة حالياً'
                              : 'No products available at the moment',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 350,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayProducts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 24),
                        itemBuilder: (context, index) {
                          final product = displayProducts[index];
                          // استخدام businesses الحقيقية من الـ Provider
                          final assignedBusinessId = businesses.isNotEmpty
                              ? businesses[index % businesses.length].id
                              : '';
                          return _TrendingProductCard(
                            product: product,
                            businessId: assignedBusinessId,
                            isAr: isAr,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Z-Hub
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.storefront,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isAr ? 'منصة المتاجر' : 'Z-Hub',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isAr
                              ? 'منصتك الموثوقة للتسوق من أفضل المتاجر المحلية والعالمية بكل سهولة وأمان.'
                              : 'Your trusted platform to shop from the best local and international stores easily and securely.',
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Developer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'الشركة المطورة' : 'Developed By',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isAr
                              ? 'مؤسسة الزكاء للحلول الرقمية'
                              : 'Alzaka Digital Solutions',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(
                              Icons.language,
                              color: Colors.white70,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'www.alzaka.com',
                                style: TextStyle(color: Colors.blueAccent),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.email, color: Colors.white70, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'info@alzaka.com',
                                style: TextStyle(color: Colors.blueAccent),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Links
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'روابط سريعة' : 'Quick Links',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isAr ? 'شروط الاستخدام' : 'Terms of Service',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAr ? 'اتصل بنا' : 'Contact Us',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Divider(color: Colors.white24),
              const SizedBox(height: 20),
              Text(
                isAr
                    ? '© 2026 جميع الحقوق محفوظة.'
                    : '© 2026 All rights reserved.',
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-Widgets
// ---------------------------------------------------------------------------

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 32,
            bottom: 32,
            left: 32,
            right: 32,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          right: isAr ? 24 : null,
          left: isAr ? null : 24,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _StoreCard extends StatefulWidget {
  final BusinessModel business;
  final bool isAr;

  const _StoreCard({required this.business, required this.isAr});

  @override
  State<_StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<_StoreCard> {
  bool _isHovered = false;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    // Generate a mock rating between 4.0 and 5.0
    final mockRating = (4.0 + (widget.business.owner.id.hashCode % 10) / 10)
        .toStringAsFixed(1);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -10 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 20 : 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () => changeScreen(context, const HomePage()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cover Image
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.store,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                      // Gradient Overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Like Button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[600],
                            ),
                            onPressed: () =>
                                setState(() => _isLiked = !_isLiked),
                          ),
                        ),
                      ),
                      // Rating Badge
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                mockRating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Logo
                      Positioned(
                        bottom: -1, // overlap prevention
                        left: widget.isAr ? null : 20,
                        right: widget.isAr ? 20 : null,
                        child: Transform.translate(
                          offset: const Offset(0, 20),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ClipOval(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Details
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          widget.isAr
                              ? widget.business.localization.name.ar
                              : widget.business.localization.name.en,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.business.addAddress.isNotEmpty
                                    ? widget.business.addAddress.first.street
                                    : '',
                                style: TextStyle(color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.store,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.business.businessType.name,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Hover Action Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _isHovered ? 48 : 0,
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: _isHovered ? 12 : 0,
                  ),
                  child: ElevatedButton(
                    onPressed: () => changeScreen(context, const HomePage()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.isAr ? 'زيارة المتجر' : 'Visit Store',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class _TrendingProductCard extends StatelessWidget {
  final ProductModel product;
  final String businessId;
  final bool isAr;

  const _TrendingProductCard({
    required this.product,
    required this.businessId,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
      color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Go directly to the product page inside its specific store
          changeScreen(context, ProductDetailsPage(product: product));
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: product.images.isNotEmpty
                    ? Image.network(
                        product.images.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    // Mock color placeholder if no image
                    : Container(color: Colors.grey[300]),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.basePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumNewsletterSection extends StatefulWidget {
  const _PremiumNewsletterSection();

  @override
  State<_PremiumNewsletterSection> createState() =>
      _PremiumNewsletterSectionState();
}

class _PremiumNewsletterSectionState extends State<_PremiumNewsletterSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatingAnimation;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;
  bool _initializedColors = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedColors) {
      final primaryColor = Theme.of(context).primaryColor;
      _colorAnimation1 = ColorTween(
        begin: primaryColor.withOpacity(0.05),
        end: primaryColor.withOpacity(0.2),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _colorAnimation2 = ColorTween(
        begin: primaryColor.withOpacity(0.15),
        end: primaryColor.withOpacity(0.02),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _initializedColors = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    final primaryColor = Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _colorAnimation1.value ?? Colors.white,
                _colorAnimation2.value ?? Colors.white,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 800;

                  final textContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.mark_email_read_rounded,
                              color: primaryColor,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Text(
                              isAr ? 'انضم إلى عائلتنا' : 'Join Our Family',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        isAr
                            ? 'اشترك في النشرة البريدية ليصلك كل جديد من المتاجر المميزة، العروض الحصرية، والمنتجات الرائعة مباشرة إلى بريدك الإلكتروني.'
                            : 'Subscribe to our newsletter to receive the latest updates, exclusive offers, and amazing products directly in your inbox.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87.withOpacity(0.7),
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );

                  final formContent = Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _floatingAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatingAnimation.value),
                              child: Icon(
                                Icons.mail_outline_rounded,
                                size: 64,
                                color: primaryColor.withOpacity(0.5),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                            ),
                            hintText: isAr
                                ? 'البريد الإلكتروني'
                                : 'Email Address',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _showSnackBar(
                            context,
                            isAr
                                ? 'تم الاشتراك بنجاح! شكراً لك.'
                                : 'Subscribed successfully! Thank you.',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: primaryColor.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isAr
                                    ? 'تسجيل الدخول / اشتراك'
                                    : 'Subscribe Now',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.send_rounded, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                  if (isDesktop) {
                    // Determine layout direction based on locale
                    // In the wireframe, form is on the left, text is on the right for Arabic?
                    // Actually if it's right-to-left, the right side is the start. Let's stick to the wireframe layout
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!isAr) ...[
                          Expanded(child: textContent),
                          const SizedBox(width: 80),
                          Expanded(child: formContent),
                        ] else ...[
                          Expanded(child: formContent),
                          const SizedBox(width: 80),
                          Expanded(child: textContent),
                        ],
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        textContent,
                        const SizedBox(height: 40),
                        formContent,
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PremiumHowItWorksSection extends StatefulWidget {
  const _PremiumHowItWorksSection();

  @override
  State<_PremiumHowItWorksSection> createState() =>
      _PremiumHowItWorksSectionState();
}

class _PremiumHowItWorksSectionState extends State<_PremiumHowItWorksSection>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _videoPulseController;

  final List<Map<String, dynamic>> _steps = [
    {
      'icon': Icons.search_rounded,
      'title_ar': 'تصفح الواجهة بسهولة',
      'title_en': 'Browse Easily',
      'desc_ar':
          'قمنا بتصميم المنصة لتكون بأعلى درجات السهولة والوضوح للبحث عن متاجرك المفضلة.',
      'desc_en':
          'We designed the platform for maximum clarity and ease when searching for your favorite stores.',
    },
    {
      'icon': Icons.shopping_cart_checkout_rounded,
      'title_ar': 'أضف للسلة',
      'title_en': 'Add to Cart',
      'desc_ar':
          'اختر منتجاتك من متاجر متعددة وأضفها لسلة تسوق واحدة متكاملة بضغطة زر.',
      'desc_en':
          'Choose products from multiple stores and add them to a single cart with one click.',
    },
    {
      'icon': Icons.payment_rounded,
      'title_ar': 'دفع آمن وسريع',
      'title_en': 'Fast & Secure Payment',
      'desc_ar':
          'وفرنا لك بوابات دفع إلكترونية مشفرة وآمنة 100% لضمان راحة بالك.',
      'desc_en':
          'We provide 100% secure and encrypted payment gateways for your peace of mind.',
    },
    {
      'icon': Icons.local_shipping_rounded,
      'title_ar': 'توصيل موثوق',
      'title_en': 'Reliable Delivery',
      'desc_ar':
          'نضمن لك وصول منتجاتك أينما كنت عبر شبكة واسعة من شركاء التوصيل.',
      'desc_en':
          'We guarantee delivery wherever you are via a wide network of delivery partners.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _videoPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _videoPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'كيف تتعامل مع المنصة' : 'How it works',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 60),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 900;

                  // Video Player Placeholder
                  final videoSection = Container(
                    height: isDesktop ? 500 : 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.black87,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned.fill(
                          child: Icon(
                            Icons.ondemand_video,
                            size: 100,
                            color: Colors.white24,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isAr
                                      ? 'سيتم تشغيل الفيديو قريباً'
                                      : 'Video will play soon',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  // Steps Details
                  final detailsSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey<int>(_currentStep),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr
                                    ? _steps[_currentStep]['title_ar']
                                    : _steps[_currentStep]['title_en'],
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isAr
                                    ? _steps[_currentStep]['desc_ar']
                                    : _steps[_currentStep]['desc_en'],
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                  height: 1.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_steps.length, (index) {
                          final isSelected = _currentStep == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _currentStep = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 80,
                                margin: EdgeInsets.only(
                                  right: isAr && index != _steps.length - 1
                                      ? 16
                                      : 0,
                                  left: !isAr && index != _steps.length - 1
                                      ? 16
                                      : 0,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Icon(
                                    _steps[index]['icon'],
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[400],
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ...List.generate(
                            _steps.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentStep == index ? 40 : 12,
                              decoration: BoxDecoration(
                                color: _currentStep == index
                                    ? primaryColor
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!isAr) ...[
                          Expanded(flex: 5, child: detailsSection),
                          const SizedBox(width: 80),
                          Expanded(flex: 6, child: videoSection),
                        ] else ...[
                          Expanded(flex: 6, child: videoSection),
                          const SizedBox(width: 80),
                          Expanded(flex: 5, child: detailsSection),
                        ],
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        videoSection,
                        const SizedBox(height: 40),
                        detailsSection,
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendingOfferCard extends StatelessWidget {
  final OfferModel offer;
  final String businessId;
  final bool isAr;

  const _TrendingOfferCard({
    required this.offer,
    required this.businessId,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          changeScreen(context, OfferDetailsPage(offerId: offer.id));
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: offer.imageUrl != null && offer.imageUrl!.isNotEmpty
                    ? Image.network(
                        offer.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(color: Colors.grey[300]),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      offer.name.get(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      offer.description?.get(context) ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumRecommendedCard extends StatefulWidget {
  final BusinessModel business;
  final bool isAr;
  final bool isHero;
  final int rank;

  const _PremiumRecommendedCard({
    required this.business,
    required this.isAr,
    required this.isHero,
    required this.rank,
  });

  @override
  State<_PremiumRecommendedCard> createState() =>
      _PremiumRecommendedCardState();
}

class _PremiumRecommendedCardState extends State<_PremiumRecommendedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Generate gradient based on owner id
    final colors = [
      [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
      [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
      [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      [const Color(0xFFF7971E), const Color(0xFFFFD200)],
    ];
    final colorIdx = widget.business.owner.id.hashCode % colors.length;
    final gradient = LinearGradient(
      colors: colors[colorIdx],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => changeScreen(context, const HomePage()),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors[colorIdx][0].withOpacity(_isHovered ? 0.4 : 0.2),
                blurRadius: _isHovered ? 30 : 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background
                Container(decoration: BoxDecoration(gradient: gradient)),
                // Pattern overlay or Icon
                Positioned(
                  right: widget.isAr ? -50 : null,
                  left: widget.isAr ? null : -50,
                  bottom: -50,
                  child: Icon(
                    Icons.storefront,
                    size: widget.isHero ? 300 : 150,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                // Dark Gradient overlay for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Badge
                      if (widget.rank == 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.isAr ? 'الأعلى تقييماً' : 'Top Rated',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.rank == 1) const SizedBox(height: 16),
                      // Store Name
                      Text(
                        widget.isAr
                            ? widget.business.localization.name.ar
                            : widget.business.localization.name.en,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.isHero ? 32 : 24,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Store Description or location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.business.addAddress.isNotEmpty
                                  ? widget.business.addAddress.first.street
                                  : (widget.isAr
                                        ? 'عنوان غير متوفر'
                                        : 'Address not available'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Hover Action (Visit Button)
                if (widget.isHero)
                  Positioned(
                    top: 24,
                    right: widget.isAr ? null : 24,
                    left: widget.isAr ? 24 : null,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Text(
                              widget.isAr ? 'زيارة المتجر' : 'Visit Store',
                              style: TextStyle(
                                color: colors[colorIdx][0],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: colors[colorIdx][0],
                              size: 16,
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
      ),
    );
  }
}
