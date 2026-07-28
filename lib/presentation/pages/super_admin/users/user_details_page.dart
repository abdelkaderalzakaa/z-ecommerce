import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/fake_data/users.dart';
import 'package:z_ecommerce/data/models/user_model.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/details_template.dart';

import 'user_details_tab/overview_tab.dart';
import 'user_details_tab/addresses_tab.dart';
import 'user_details_tab/orders_tab.dart';
import 'user_details_tab/wishlist_tab.dart';
import 'user_details_tab/admin_permissions_tab.dart';
import 'user_details_tab/owner_store_tab.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId;

  const UserDetailsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final user = fakeUsers.firstWhere(
      (u) => u.id == userId,
      orElse: () => fakeUsers.first,
    );

    String roleText;
    switch (user.role) {
      case UserRole.superAdmin:
        roleText = TranslationKeys.superAdminRole.tr(context);
        break;
      case UserRole.companyOwner:
        roleText = TranslationKeys.storeOwnerRole.tr(context);
        break;
      case UserRole.customer:
        roleText = TranslationKeys.customerRole.tr(context);
        break;
    }

    // Role-based Dynamic Tabs & Tab Views Setup
    final List<Tab> tabs = [];
    final List<Widget> tabViews = [];

    // All roles get Overview Tab
    tabs.add(Tab(text: TranslationKeys.overviewTab.tr(context)));
    tabViews.add(UserOverviewTab(user: user));

    if (user.role == UserRole.superAdmin) {
      // Super Admin Tabs
      tabs.add(const Tab(text: 'الصلاحيات والسجلات'));
      tabViews.add(AdminPermissionsTab(user: user));
    } else if (user.role == UserRole.companyOwner) {
      // Company Owner Tabs
      tabs.add(const Tab(text: 'المتجر التابع'));
      tabViews.add(OwnerStoreTab(user: user));
    } else {
      // Customer Tabs
      tabs.add(Tab(text: TranslationKeys.addresses.tr(context)));
      tabViews.add(UserAddressesTab(user: user));

      tabs.add(Tab(text: TranslationKeys.orders.tr(context)));
      tabViews.add(UserOrdersTab(user: user));

      tabs.add(Tab(text: TranslationKeys.wishlist.tr(context)));
      tabViews.add(UserWishlistTab(user: user));
    }

    return DetailsTemplate(
      title: 'تفاصيل المستخدم',
      name: user.name,
      subtitle: '${user.email} • ID: ${user.id}',
      avatarUrl: user.avatarUrl,
      fallbackIcon: Icons.person_rounded,
      statusBadge: TableStatusBadge.fromStatus(roleText),
      headerMetrics: [
        Chip(
          avatar: const Icon(Icons.admin_panel_settings_rounded, size: 16, color: Colors.indigo),
          label: Text(roleText),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        if (user.phoneNumber != null)
          Chip(
            avatar: const Icon(Icons.phone, size: 16, color: Colors.green),
            label: Text(user.phoneNumber!),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
      onRefresh: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث بيانات المستخدم')),
        );
      },
      onEdit: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${TranslationKeys.editAddress.tr(context)} "${user.name}"')),
        );
      },
      onDelete: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${TranslationKeys.deleteSelected.tr(context)} "${user.name}"'),
            backgroundColor: Colors.red,
          ),
        );
      },
      tabs: tabs,
      tabViews: tabViews,
    );
  }
}
