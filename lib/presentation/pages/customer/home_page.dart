import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_buisness.dart';
import '../../../data/providers/business_provider.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/providers/brand_provider.dart';
import '../../../data/providers/offer_provider.dart';
import '../../widgets/common/headers/header_home.dart';
import '../../widgets/home/hero_section.dart';
import '../../widgets/home/brands_section.dart';
import '../../widgets/home/new_arrivals_section.dart';
import '../../widgets/home/top_selling_section.dart';
import '../../widgets/home/browse_categories_section.dart';
import '../../widgets/home/browse_brands_section.dart';
import '../../widgets/home/discounted_products_section.dart';
import '../../widgets/home/offers_section.dart';
import '../../widgets/home/top_reviews_section.dart';
import '../../widgets/home/recommended_section.dart';
import '../../widgets/home/featured_section.dart';
import '../../widgets/home/most_liked_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _newArrivalsKey = GlobalKey();
  final GlobalKey _browseCategoriesKey = GlobalKey();
  final GlobalKey _topSellingKey = GlobalKey();
  final GlobalKey _offersKey = GlobalKey();
  final GlobalKey _browseBrandsKey = GlobalKey();
  final GlobalKey _reviewsKey = GlobalKey();

  final GlobalKey _recommendedKey = GlobalKey();
  final GlobalKey _featuredKey = GlobalKey();
  final GlobalKey _discountedKey = GlobalKey();
  final GlobalKey _mostLikedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().listenToAllProducts();
      context.read<CategoryProvider>().listenToAllCategories();
      context.read<BrandProvider>().listenToAllBrands();
      context.read<OfferProvider>().listenToActiveOffers();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String section) {
    final GlobalKey? key = switch (section) {
      'hero' => _heroKey,
      'newArrivals' => _newArrivalsKey,
      'browseCategories' => _browseCategoriesKey,
      'topSelling' => _topSellingKey,
      'offers' => _offersKey,
      'browseBrands' => _browseBrandsKey,
      'reviews' => _reviewsKey,
      'recommended' => _recommendedKey,
      'featured' => _featuredKey,
      'discounted' => _discountedKey,
      'mostLiked' => _mostLikedKey,
      _ => null,
    };

    if (key == null) return;

    final context = key.currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      alignment: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = Provider.of<BusinessProvider>(context);
    final selectedBusiness = businessProvider.selectedBusiness;
    final storeTheme = selectedBusiness.theme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark && storeTheme.darkPrimaryColor.isNotEmpty
        ? storeTheme.darkPrimaryColorValue
        : storeTheme.primaryColorValue;
    final secondaryColor = isDark && storeTheme.darkSecondaryColor.isNotEmpty
        ? storeTheme.darkSecondaryColorValue
        : storeTheme.secondaryColorValue;
    final bgColor = isDark
        ? storeTheme.darkBackgroundColorValue
        : storeTheme.backgroundColorValue;
    final surfaceColor = isDark
        ? storeTheme.darkSurfaceColorValue
        : storeTheme.surfaceColorValue;
    final fontFamily = storeTheme.fontFamily.isNotEmpty
        ? storeTheme.fontFamily
        : 'Cairo';

    final btnRadius = storeTheme.buttonRadius > 0 ? storeTheme.buttonRadius : 12.0;
    final cardRadius = storeTheme.cardRadius > 0 ? storeTheme.cardRadius : 16.0;
    final inputRadius = storeTheme.inputRadius > 0 ? storeTheme.inputRadius : 10.0;
    final fontScale = storeTheme.fontScale > 0 ? storeTheme.fontScale : 1.0;

    final dynamicTheme = Theme.of(context).copyWith(
      primaryColor: primaryColor,
      cardColor: surfaceColor,
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: bgColor,
      textTheme: Theme.of(context).textTheme.apply(
        fontFamily: fontFamily,
        fontSizeFactor: fontScale,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(btnRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(btnRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
        ),
      ),
    );

    return Theme(
      data: dynamicTheme,
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            backgroundColor: bgColor,
            appBar: HeaderHome(onNavTap: _scrollToSection),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeroSection(key: _heroKey),
                  const BrandsSection(),
                  const SizedBox(height: 72),
                  if (selectedBusiness.isRecommended) ...[
                    RecommendedSection(key: _recommendedKey),
                    const SizedBox(height: 72),
                  ],
                  FeaturedSection(key: _featuredKey),
                  const SizedBox(height: 72),
                  DiscountedProductsSection(key: _discountedKey),
                  const SizedBox(height: 72),
                  NewArrivalsSection(key: _newArrivalsKey),
                  const SizedBox(height: 72),
                  BrowseCategoriesSection(key: _browseCategoriesKey),
                  const SizedBox(height: 72),
                  TopSellingSection(key: _topSellingKey),
                  const SizedBox(height: 72),
                  if (selectedBusiness.allowOffers) ...[
                    OffersSection(key: _offersKey),
                    const SizedBox(height: 72),
                  ],
                  if (selectedBusiness.allowLikes) ...[
                    MostLikedSection(key: _mostLikedKey),
                    const SizedBox(height: 72),
                  ],
                  BrowseBrandsSection(key: _browseBrandsKey),
                  const SizedBox(height: 72),
                  if (selectedBusiness.allowReviews) ...[
                    TopReviewsSection(key: _reviewsKey),
                    const SizedBox(height: 72),
                  ],
                  FooterBuisness(
                    idBuisness: selectedBusiness.id,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
