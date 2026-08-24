import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/pages/business/home/business_orders_management_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/store_brands_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/store_categories_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/store_dashboard_overview_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/store_followers_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/store_offers_management_page.dart';
import 'package:z_ecommerce/presentation/pages/business/settings/store_owner_settings_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/store_products_management_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/store_reviews_management_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/store_delivery_management_page.dart';
import 'package:z_ecommerce/presentation/widgets/admin_store/store_owner_app_bar.dart';
import 'package:z_ecommerce/presentation/widgets/admin_store/store_owner_sidebar.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';

class AdminStore extends StatefulWidget {
  const AdminStore({super.key});

  @override
  State<AdminStore> createState() => _AdminStoreState();
}

class _AdminStoreState extends State<AdminStore> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null && user.businessId != null) {
        context.read<BusinessProvider>().selectBusiness(user.businessId!);
      }
    });
  }

  List<Widget> _getPages(BusinessModel store) {
    return [
      StoreDashboardOverviewPage(businessId: store.id),
      const StoreProductsManagementPage(),
      if (store.allowOffers) StoreOffersManagementPage(businessId: store.id),
      BusinessOrdersManagementPage(businessId: store.id),
      const StoreCategoriesPage(),
      const StoreBrandsPage(),
      if (store.allowFollow) const StoreFollowersPage(),
      if (store.allowReviews || store.allowLikes) const StoreReviewsManagementPage(),
      StoreDeliveryManagementPage(businessId: store.id),
      const StoreOwnerSettingsPage(),
    ];
  }

  List<StoreOwnerSidebarItem> _getSidebarItems(BusinessModel store) {
    return [
      const StoreOwnerSidebarItem(
        titleKey: TranslationKeys.storeOverview,
        icon: Icons.dashboard_rounded,
      ),
      const StoreOwnerSidebarItem(
        titleKey: TranslationKeys.storeProductsTab,
        icon: Icons.inventory_2_rounded,
      ),
      if (store.allowOffers)
        const StoreOwnerSidebarItem(
          titleKey: TranslationKeys.storeOffersTab,
          icon: Icons.local_offer_rounded,
        ),
      const StoreOwnerSidebarItem(
        titleKey: TranslationKeys.storeOrdersTab,
        icon: Icons.shopping_cart_rounded,
      ),
      const StoreOwnerSidebarItem(
        titleKey: TranslationKeys.storeCategoriesTab,
        icon: Icons.category_rounded,
      ),
      const StoreOwnerSidebarItem(
        titleKey: TranslationKeys.storeBrandsTab,
        icon: Icons.branding_watermark_rounded,
      ),
      if (store.allowFollow)
        const StoreOwnerSidebarItem(
          titleKey: TranslationKeys.storeFollowersTab,
          icon: Icons.people_alt_rounded,
        ),
      if (store.allowReviews || store.allowLikes)
        const StoreOwnerSidebarItem(
          titleKey: TranslationKeys.storeReviewsAndLikesTab,
          icon: Icons.star_rounded,
        ),
      const StoreOwnerSidebarItem(
        titleKey: TranslationKeys.storeDeliveryTab,
        icon: Icons.local_shipping_rounded,
      ),
      const StoreOwnerSidebarItem(
        titleKey: TranslationKeys.storeSettingsTab,
        icon: Icons.settings_rounded,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 900;
    
    final businessProvider = context.watch<BusinessProvider>();
    final store = businessProvider.businessSettings;
    final pages = _getPages(store);
    
    if (_selectedIndex >= pages.length) {
      _selectedIndex = pages.length - 1;
    }
    
    if (store.isInactive) {
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 90, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'عذراً، هذا المتجر غير مفعل حالياً',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'لا يمكنك الوصول إلى لوحة تحكم المتجر لأن حالته غير نشطة. الرجاء التواصل مع الإدارة للتفعيل.',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      await context.read<AuthProvider>().signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: StoreOwnerAppBar(
        isMobile: isMobile,
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: isMobile
          ? Drawer(
              child: SafeArea(
                child: StoreOwnerSidebar(
                  items: _getSidebarItems(store),
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    Navigator.of(context).pop(); // Close drawer on selection
                  },
                ),
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar for Desktop & Large Screens
          if (!isMobile)
            StoreOwnerSidebar(
              items: _getSidebarItems(store),
              selectedIndex: _selectedIndex,
              isCollapsed: _isSidebarCollapsed,
              onToggleCollapse: () {
                setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                });
              },
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),

          // Main View Area
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _getPages(store),
            ),
          ),
        ],
      ),
    );
  }
}
