import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import '../../../../../../data/providers/auth_provider.dart';
import '../../../../../data/providers/business_provider.dart';
import 'buttons.dart';
import '../../../../global/core/constants/app_constants.dart';
import '../../../../global/translate/app_localizations.dart';
import '../../../../global/translate/translation_keys.dart';
import '../../../../global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/pages/customer/profile_customer/profile_page.dart';
import 'package:z_ecommerce/presentation/pages/auth/login_page.dart';

import 'package:z_ecommerce/presentation/pages/delivery/delivery_home.dart';
import 'package:z_ecommerce/presentation/pages/business/home/admin_business_home.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/super_admin_home.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class AccountHeaderIcon extends StatelessWidget {
  const AccountHeaderIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isAuthenticated = authProvider.isAuthenticated;
        final user = authProvider.currentUser;

        void handlePress() {
          if (isAuthenticated) {
            if (user?.role == UserRole.delivery) {
              changeScreen(context, const DeliveryPortalHome());
            } else if (user?.role == UserRole.businessOwner) {
              changeScreen(context, const AdminStore());
            } else if (user?.role == UserRole.superAdmin) {
              changeScreen(context, const SuperAdminHome());
            } else {
              changeScreen(context, const ProfilePage());
            }
          } else {
            changeScreen(context, const LoginPage());
          }
        }

        if (isMobile) {
          return ButtonApp(
            format: FormatButtonApp.icon,
            onPressed: handlePress,
            icon: isAuthenticated ? Icons.person : Icons.person_outline,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            label: TranslationKeys.myAccount.tr(context),
          );
        }

        return ButtonApp(
          onPressed: handlePress,
          icon: isAuthenticated ? Icons.person : Icons.person_outline,
          label: isAuthenticated
              ? user?.name.split(' ').first ??
                    TranslationKeys.profile.tr(context)
              : TranslationKeys.logIn.tr(context),
        );
      },
    );
  }
}
