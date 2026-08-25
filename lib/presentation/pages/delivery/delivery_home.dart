import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/pages/delivery/delivery_dashboard_overview_page.dart';
import 'package:z_ecommerce/presentation/pages/delivery/delivery_earnings_page.dart';
import 'package:z_ecommerce/presentation/pages/delivery/delivery_fleet_page.dart';
import 'package:z_ecommerce/presentation/pages/delivery/delivery_orders_page.dart';
import 'package:z_ecommerce/presentation/pages/delivery/delivery_settings_page.dart';
import 'package:z_ecommerce/presentation/widgets/delivery/delivery_portal_app_bar.dart';
import 'package:z_ecommerce/presentation/widgets/delivery/delivery_portal_sidebar.dart';

class DeliveryPortalHome extends StatefulWidget {
  const DeliveryPortalHome({super.key});

  @override
  State<DeliveryPortalHome> createState() => _DeliveryPortalHomeState();
}

class _DeliveryPortalHomeState extends State<DeliveryPortalHome> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<DeliveryProvider>().loadDeliveryForUser(
              user.id,
              userName: user.name,
              userPhone: user.phoneNumber,
            );
      }
    });
  }

  List<Widget> _getPages(bool isCompany) {
    return [
      DeliveryDashboardOverviewPage(
        onNavigateToOrders: () => setState(() => _selectedIndex = 1),
      ),
      const DeliveryOrdersPage(),
      if (isCompany) const DeliveryFleetPage(),
      const DeliveryEarningsPage(),
      const DeliverySettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 900;

    final deliveryProvider = context.watch<DeliveryProvider>();
    final delivery = deliveryProvider.currentDelivery;
    final isCompany = delivery.type == DeliveryEntityType.company;

    final pages = _getPages(isCompany);
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: DeliveryPortalAppBar(
        isMobile: isMobile,
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: isMobile
          ? Drawer(
              child: SafeArea(
                child: DeliveryPortalSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() => _selectedIndex = index);
                    Navigator.of(context).pop(); // Close drawer on selection
                  },
                ),
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sleek Sidebar for Desktop & Tablets (Matching Super Admin & Store Owner)
          if (!isMobile)
            DeliveryPortalSidebar(
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
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}
