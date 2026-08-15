import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import '../../../widgets/admin_store/store_owner_app_bar.dart';
import '../../../widgets/admin_store/store_owner_sidebar.dart';
import '../branding/business_branding_page.dart';
import 'store_dashboard_overview_page.dart';
import 'store_products_management_page.dart';
import 'store_categories_page.dart';
import 'store_brands_page.dart';
import 'business_orders_management_page.dart';
import 'store_offers_management_page.dart';
import 'store_reviews_management_page.dart';
import 'store_owner_settings_page.dart';
import 'store_followers_page.dart';

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

  List<Widget> _getPages(String businessId) => [
    StoreDashboardOverviewPage(businessId: businessId),
    const StoreProductsManagementPage(),
    StoreOffersManagementPage(businessId: businessId),
    BusinessOrdersManagementPage(businessId: businessId),
    const StoreCategoriesPage(),
    const StoreBrandsPage(),
    const StoreFollowersPage(),
    const StoreReviewsManagementPage(),
    const StoreOwnerSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 900;
    
    final businessProvider = context.watch<BusinessProvider>();
    final store = businessProvider.businessSettings;
    
    if (store != null && store.isInactive) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 100, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'عذراً، هذا المتجر غير مفعل حالياً',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'لا يمكنك الوصول إلى لوحة تحكم المتجر لأن حالته غير نشطة.\nالرجاء التواصل مع الإدارة للتفعيل.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
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
              children: _getPages(
                context.watch<BusinessProvider>().businessSettings?.id ?? '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
