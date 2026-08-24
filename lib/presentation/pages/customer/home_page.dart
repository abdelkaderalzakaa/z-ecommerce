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
import '../../widgets/common/footers/footer_section.dart';

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
    // بدء البث المباشر الموحد لبيانات الصفحة الرئيسية
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
    final storeTheme = businessProvider.selectedBusiness.theme;

    final primaryColor = storeTheme.primaryColorValue;
    final secondaryColor = storeTheme.secondaryColorValue;
    final bgColor = storeTheme.backgroundColorValue;
    final fontFamily = storeTheme.fontFamily.isNotEmpty
        ? storeTheme.fontFamily
        : 'Cairo';

    final dynamicTheme = Theme.of(context).copyWith(
      primaryColor: primaryColor,
      colorScheme: Theme.of(
        context,
      ).colorScheme.copyWith(primary: primaryColor, secondary: secondaryColor),
      scaffoldBackgroundColor: bgColor,
      textTheme: Theme.of(context).textTheme.apply(fontFamily: fontFamily),
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
                  RecommendedSection(key: _recommendedKey),
                  const SizedBox(height: 72),
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
                  OffersSection(key: _offersKey),
                  const SizedBox(height: 72),
                  MostLikedSection(key: _mostLikedKey),
                  const SizedBox(height: 72),
                  BrowseBrandsSection(key: _browseBrandsKey),
                  const SizedBox(height: 72),
                  if (businessProvider.selectedBusiness.allowReviews) ...[
                    TopReviewsSection(key: _reviewsKey),
                    const SizedBox(height: 72),
                  ],
                  FooterBuisness(
                    idBuisness: context
                        .read<BusinessProvider>()
                        .selectedBusiness
                        .id,
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
