import 'package:flutter/material.dart';
import '../../widgets/admin_store/store_owner_app_bar.dart';
import '../../widgets/admin_store/store_owner_sidebar.dart';
import 'branding/store_branding_page.dart';
import 'dashboard/store_dashboard_overview_page.dart';
import 'products/store_products_management_page.dart';
import 'orders/store_orders_management_page.dart';
import 'offers/store_offers_management_page.dart';
import 'reviews/store_reviews_management_page.dart';
import 'settings/store_owner_settings_page.dart';

class AdminStore extends StatefulWidget {
  const AdminStore({super.key});

  @override
  State<AdminStore> createState() => _AdminStoreState();
}

class _AdminStoreState extends State<AdminStore> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = const [
    StoreDashboardOverviewPage(),
    StoreProductsManagementPage(),
    StoreOrdersManagementPage(),
    StoreOffersManagementPage(),
    StoreReviewsManagementPage(),
    StoreOwnerSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 900;

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
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
