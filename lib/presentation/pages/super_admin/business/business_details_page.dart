import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/excel_import_page.dart';

import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/data/providers/offer_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/business_details_tab/brand_tab.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/business_details_tab/category_tab.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/business_details_tab/followers_tab.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/business_details_tab/offers_tab.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/business_details_tab/overview_tab.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/business_details_tab/permissions_tab.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/business_details_tab/products_tab.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/business_details_tab/reviews_tab.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/business_details_tab/delivery_tab.dart';
import 'package:z_ecommerce/presentation/widgets/templates/details_template.dart';

import 'create_business_page.dart';

class BusinessDetailsPage extends StatelessWidget {
  final String storeId;

  const BusinessDetailsPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Consumer5<BusinessProvider, ProductProvider, OfferProvider, CategoryProvider, BrandProvider>(
      builder: (context, provider, productProvider, offerProvider, categoryProvider, brandProvider, child) {
        final store = provider.businesses.firstWhere(
          (s) => s.id == storeId,
          orElse: () => provider.businesses.first,
        );

        // Dynamic Counts per Tab
        final productsCount = productProvider.allProducts.where((p) => p.businessId == store.id).length;
        final offersCount = offerProvider.activeOffers.where((o) => o.businessId == store.id).length;
        final categoriesCount = categoryProvider.categories.where((c) => c.businessId == store.id).length;
        final brandsCount = brandProvider.brands.where((b) => b.businessId == store.id).length;
        final followersCount = store.followersUsers.length;
        final reviewsCount = store.ratings.length;

        // Calculate readiness based on filled fields
        int readinessScore = 0;
        if (store.hasOwner) readinessScore += 20;
        if (store.addAddress.isNotEmpty) readinessScore += 20;
        if (store.localization.name.ar.isNotEmpty) readinessScore += 20;
        if (store.socials.isNotEmpty) readinessScore += 20;
        if (store.paymentMethods.isNotEmpty) readinessScore += 20;

        final bool isBelowLaunchThreshold = readinessScore < 60;

        // Automatically update status if readiness is below threshold
        if (isBelowLaunchThreshold && store.isActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.updateStoreStatus(store.id, 'Inactive');
          });
        }

        return DetailsTemplate(
          title: TranslationKeys.storeDetailsTitle.tr(context),
          name: store.localization.name.get(context),
          subtitle:
              '${TranslationKeys.category.tr(context)}: ${store.businessType.name} • ${store.id}',
          avatarUrl: store.theme.logoUrl,
          fallbackIcon: Icons.storefront_rounded,
          statusBadge: TableStatusBadge.fromStatus(store.status ?? 'Active'),
          headerMetrics: [
            // Import / Export Button
            ButtonApp(
              onPressed: () {
                changeScreen(
                  context,
                  ExcelImportPage(
                    businessId: store.id,
                    businessName: store.localization.name.get(context),
                  ),
                );
              },
              icon: Icons.table_chart_rounded,
              label: isAr ? 'استيراد / تصدير' : 'Import / Export',
              color: Colors.indigo,
            ),
            const SizedBox(width: 8),
          ],
          onEdit: () {
            changeScreen(context, CreateBusinessPage(businessToEdit: store));
          },
          tabs: [
            Tab(text: isAr ? 'نظرة عامة' : 'Overview'),
            Tab(text: isAr ? 'صلاحيات التفاعل' : 'Permissions'),
            Tab(text: isAr ? 'المنتجات ($productsCount)' : 'Products ($productsCount)'),
            Tab(text: isAr ? 'العروض ($offersCount)' : 'Offers ($offersCount)'),
            Tab(text: isAr ? 'الفئات ($categoriesCount)' : 'Categories ($categoriesCount)'),
            Tab(text: isAr ? 'العلامات التجارية ($brandsCount)' : 'Brands ($brandsCount)'),
            Tab(text: isAr ? 'المتابعات ($followersCount)' : 'Followers ($followersCount)'),
            Tab(text: isAr ? 'التقييمات والآراء ($reviewsCount)' : 'Reviews ($reviewsCount)'),
            Tab(text: isAr ? 'التوصيل' : 'Delivery'),
          ],
          tabViews: [
            OverviewTab(store: store),
            PermissionsTab(store: store),
            ProductsTab(store: store),
            OffersTab(store: store),
            CategoryTab(store: store),
            BrandTab(store: store),
            FollowersTab(store: store),
            ReviewsTab(store: store),
            DeliveryTab(store: store),
          ],
        );
      },
    );
  }
}
