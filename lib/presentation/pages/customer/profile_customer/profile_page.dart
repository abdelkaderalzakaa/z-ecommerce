import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import '../../../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/business_provider.dart';
import '../../../widgets/common/headers/header_details.dart';
import '../../../widgets/common/footer_section.dart';
import '../../../widgets/common/headers/widgets/top_title.dart';
import '../../../widgets/profile/profile_sidebar.dart';
import '../../../widgets/profile/profile_tabs_mobile.dart';
import 'account_info_tab.dart';
import 'orders_tab.dart';
import 'addresses_tab.dart';
import 'wishlist_tab.dart';
import 'settings_tab.dart';
import 'my_stores_tab.dart';
import '../../../global/translate/app_localizations.dart';
import '../../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/profile_customer/profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String? tabId;
  const ProfilePage({super.key, this.tabId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _tabIdToIndex(widget.tabId);
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabId != oldWidget.tabId) {
      setState(() {
        _selectedIndex = _tabIdToIndex(widget.tabId);
      });
    }
  }

  int _tabIdToIndex(String? tabId) {
    switch (tabId) {
      case 'account':
        return 0;
      case 'stores':
        return 1;
      case 'orders':
        return 2;
      case 'favorites':
        return 3;
      case 'addresses':
        return 4;
      case 'settings':
        return 5;
      default:
        return 0;
    }
  }

  String _indexToTabId(int index) {
    switch (index) {
      case 0:
        return 'account';
      case 1:
        return 'stores';
      case 2:
        return 'orders';
      case 3:
        return 'favorites';
      case 4:
        return 'addresses';
      case 5:
        return 'settings';
      default:
        return 'account';
    }
  }

  List<String> _buildTabs(BuildContext context) => [
    TranslationKeys.myAccount.tr(context),
    TranslationKeys.myStores.tr(context),
    TranslationKeys.orders.tr(context),
    TranslationKeys.wishlist.tr(context),
    TranslationKeys.addresses.tr(context),
    TranslationKeys.settings.tr(context),
  ];

  void _onSelectTab(int index) {
    if (index != _selectedIndex) {
      changeScreenReplacement(context, ProfilePage(tabId: _indexToTabId(index)));
    }
  }

  Widget _buildCurrentTab(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return const AccountInfoTab();
      case 1:
        return const MyStoresTab();
      case 2:
        return const OrdersTab();
      case 3:
        return const WishlistTab();
      case 4:
        return const AddressesTab();
      case 5:
        return const SettingsTab();
      default:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              TranslationKeys.sectionComingSoon.tr(context),
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final tabs = _buildTabs(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.profile.tr(context),
        paths: [TranslationKeys.profile.tr(context)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: isMobile ? 32 : 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isMobile
                      ? _buildMobileLayout(context, tabs)
                      : _buildDesktopLayout(context, tabs),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List<String> tabs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ProfileSidebar(
            selectedIndex: _selectedIndex,
            onSelectTab: _onSelectTab,
            tabs: tabs,
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: _buildCurrentTab(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<String> tabs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileTabsMobile(
          selectedIndex: _selectedIndex,
          onSelectTab: _onSelectTab,
          tabs: tabs,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: _buildCurrentTab(context),
        ),
      ],
    );
  }
}
