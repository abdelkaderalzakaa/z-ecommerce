import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/auth/login_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/admin_business_home.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry.dart';
import 'package:z_ecommerce/presentation/pages/customer/profile_customer/account_info_tab.dart';
import 'package:z_ecommerce/presentation/pages/customer/profile_customer/addresses_tab.dart';
import 'package:z_ecommerce/presentation/pages/customer/profile_customer/following_stores_tab.dart';
import 'package:z_ecommerce/presentation/pages/customer/profile_customer/my_stores_tab.dart';
import 'package:z_ecommerce/presentation/pages/customer/profile_customer/orders_tab.dart';
import 'package:z_ecommerce/presentation/pages/customer/profile_customer/settings_tab.dart';
import 'package:z_ecommerce/presentation/pages/customer/profile_customer/wishlist_tab.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/super_admin_home.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
import 'package:z_ecommerce/presentation/widgets/profile/profile_sidebar.dart';
import 'package:z_ecommerce/presentation/widgets/profile/profile_tabs_mobile.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/top_title.dart';

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
      case 'following':
        return 2;
      case 'orders':
        return 3;
      case 'favorites':
        return 4;
      case 'addresses':
        return 5;
      case 'settings':
        return 6;
      default:
        return 0;
    }
  }

  List<String> _buildTabs(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? '';

    final businessProvider = context.watch<BusinessProvider>();
    final myStoresCount = userId.isNotEmpty
        ? businessProvider.businesses.where((b) => b.ownerId == userId).length
        : 0;

    final customer = authProvider.currentCustomer;
    final followingCount = userId.isNotEmpty
        ? businessProvider.businesses
              .where((b) => b.followersUsers.any((f) => f.userId == userId))
              .length
        : 0;
    final wishlistCount = customer?.wishlist.length ?? 0;
    final addressesCount = customer?.addresses.length ?? 0;

    return [
      TranslationKeys.myAccount.tr(context),
      '${TranslationKeys.myStores.tr(context)} ($myStoresCount)',
      isAr
          ? 'المتاجر التي أتابعها ($followingCount)'
          : 'Following ($followingCount)',
      TranslationKeys.orders.tr(context),
      '${TranslationKeys.wishlist.tr(context)} ($wishlistCount)',
      '${TranslationKeys.addresses.tr(context)} ($addressesCount)',
      TranslationKeys.settings.tr(context),
    ];
  }

  // Smooth local tab selection without page reload or route replacement
  void _onSelectTab(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildCurrentTab(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return const AccountInfoTab();
      case 1:
        return const MyStoresTab();
      case 2:
        return const FollowingStoresTab();
      case 3:
        return const OrdersTab();
      case 4:
        return const WishlistTab();
      case 5:
        return const AddressesTab();
      case 6:
        return const SettingsTab();
      default:
        return const AccountInfoTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;
    final currentUser = authProvider.currentUser;

    // Strict Role Check: Customer Profile Page is strictly for UserRole.customer
    final isCustomer =
        isAuthenticated && currentUser?.role == UserRole.customer;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderDetails(title: TranslationKeys.profile.tr(context)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopTitle(
              title: TranslationKeys.profile.tr(context),
              paths: [TranslationKeys.profile.tr(context)],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: hPad),
              child: !isAuthenticated
                  ? _buildNotAuthenticatedCard(context, theme, isAr)
                  : !isCustomer
                  ? _buildAccessDeniedCard(context, currentUser, theme, isAr)
                  : (isMobile
                        ? _buildMobileLayout(context)
                        : _buildDesktopLayout(context)),
            ),
            const SizedBox(height: 20),
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  // 1. Access Restriction Card for Unauthenticated Visitors
  Widget _buildNotAuthenticatedCard(
    BuildContext context,
    ThemeData theme,
    bool isAr,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, size: 64, color: theme.primaryColor),
          const SizedBox(height: 16),
          Text(
            isAr ? 'يرجى تسجيل الدخول أولاً' : 'Please Sign In First',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAr
                ? 'يجب تسجيل الدخول بحساب زبون للوصول إلى تفاصيل وإعدادات الملف الشخصي.'
                : 'You must log in with a customer account to access profile settings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          ButtonApp(
            label: isAr ? 'تسجيل الدخول الآن' : 'Sign In Now',
            icon: Icons.login,
            onPressed: () => changeScreen(context, const LoginPage()),
          ),
        ],
      ),
    );
  }

  // 2. Access Restriction Card for Non-Customer Roles (BusinessAdmin / SuperAdmin)
  Widget _buildAccessDeniedCard(
    BuildContext context,
    UserModel? user,
    ThemeData theme,
    bool isAr,
  ) {
    String roleName = isAr ? 'إداري' : 'Admin';
    Widget navigateBtn = ButtonApp(
      label: isAr ? 'العودة للمدخل الرئيسي' : 'Back to Entry',
      icon: Icons.home_outlined,
      onPressed: () => changeScreenReplacement(context, const BusinessEntry()),
    );

    if (user?.role == UserRole.superAdmin) {
      roleName = isAr ? 'سوبر أدمن المنصة' : 'Platform Super Admin';
      navigateBtn = ButtonApp(
        label: isAr
            ? 'الانتقال إلى لوحة السوبر أدمن'
            : 'Go to Super Admin Dashboard',
        icon: Icons.dashboard_outlined,
        onPressed: () =>
            changeScreenReplacement(context, const SuperAdminHome()),
      );
    } else if (user?.role == UserRole.businessOwner) {
      roleName = isAr ? 'أدمن نشاط تجاري' : 'Business Owner';
      navigateBtn = ButtonApp(
        label: isAr
            ? 'الانتقال إلى لوحة التحكم التجارية'
            : 'Go to Business Dashboard',
        icon: Icons.storefront_outlined,
        onPressed: () => changeScreenReplacement(context, const AdminStore()),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 64,
            color: Colors.amber.shade800,
          ),
          const SizedBox(height: 16),
          Text(
            isAr
                ? 'عذراً! الواجهة خاصة بالزبائن فقط'
                : 'Access Restricted to Customers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAr
                ? 'حسابك الحالي لديه صلاحية ($roleName).\nواجهة البروفايل مخصصة حصرياً لحسابات الزبائن لمتابعة طلباتهم ومفضلاتهم.'
                : 'Your account is registered as ($roleName).\nCustomer profile is reserved for customer accounts.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          navigateBtn,
        ],
      ),
    );
  }

  // 3. Compact Desktop Layout
  Widget _buildDesktopLayout(BuildContext context) {
    final tabs = _buildTabs(context);
    final theme = Theme.of(context);

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
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(20), // Compact padding
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: _buildCurrentTab(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 4. Compact Mobile Layout
  Widget _buildMobileLayout(BuildContext context) {
    final tabs = _buildTabs(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileTabsMobile(
          selectedIndex: _selectedIndex,
          onSelectTab: _onSelectTab,
          tabs: tabs,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16), // Compact padding
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _buildCurrentTab(context),
            ),
          ),
        ),
      ],
    );
  }
}
