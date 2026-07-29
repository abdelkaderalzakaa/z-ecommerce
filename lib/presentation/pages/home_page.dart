import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/company_provider.dart';
import '../widgets/common/headers/header_home.dart';
import '../widgets/home/hero_section.dart';
import '../widgets/home/brands_section.dart';
import '../widgets/home/new_arrivals_section.dart';
import '../widgets/home/top_selling_section.dart';
import '../widgets/home/browse_categories_section.dart';
import '../widgets/home/browse_brands_section.dart';
import '../widgets/home/discounted_products_section.dart';
import '../widgets/home/offers_section.dart';
import '../widgets/home/newsletter_section.dart';
import '../widgets/common/footer_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _newArrivalsKey = GlobalKey();
  final GlobalKey _topSellingKey = GlobalKey();
  final GlobalKey _browseCategoriesKey = GlobalKey();
  final GlobalKey _newsletterKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String section) {
    final GlobalKey? key = switch (section) {
      'hero' => _heroKey,
      'newArrivals' => _newArrivalsKey,
      'topSelling' => _topSellingKey,
      'browseCategories' => _browseCategoriesKey,
      'newsletter' => _newsletterKey,
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
    final companyProvider = Provider.of<CompanyProvider>(context);
    final storeTheme = companyProvider.companySettings?.theme;

    final primaryColor = storeTheme?.primaryColorValue ?? Theme.of(context).primaryColor;
    final secondaryColor = storeTheme?.secondaryColorValue ?? const Color(0xFF10B981);
    final bgColor = storeTheme?.backgroundColorValue ?? Theme.of(context).scaffoldBackgroundColor;
    final fontFamily = storeTheme?.fontFamily ?? 'Cairo';

    final dynamicTheme = Theme.of(context).copyWith(
      primaryColor: primaryColor,
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
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
                  const OffersSection(sectionType: 'bundles'),
                  const SizedBox(height: 72),
                  NewArrivalsSection(key: _newArrivalsKey),
                  const SizedBox(height: 72),
                  const BrowseBrandsSection(),
                  Divider(color: Theme.of(innerContext).dividerColor, height: 1),
                  const OffersSection(sectionType: 'coupons'),
                  const SizedBox(height: 72),
                  TopSellingSection(key: _topSellingKey),
                  const SizedBox(height: 72),
                  const DiscountedProductsSection(),
                  const SizedBox(height: 72),
                  BrowseCategoriesSection(key: _browseCategoriesKey),
                  const SizedBox(height: 72),
                  const OffersSection(sectionType: 'deals'),
                  const SizedBox(height: 72),
                  NewsletterSection(key: _newsletterKey),
                  const FooterSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
