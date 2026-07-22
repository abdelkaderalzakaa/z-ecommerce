import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/providers/auth_provider.dart';
import '../../../../../../data/providers/company_provider.dart';
import 'buttons.dart';
import '../../../../global/core/constants/app_constants.dart';
import '../../../../global/translate/app_localizations.dart';
import '../../../../global/translate/translation_keys.dart';
import '../../../../global/router/app_routes.dart';
import '../../../../global/core/responsive/responsive_layout.dart';

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
            context.go(AppRoutes.toProfile());
          } else {
            context.go(AppRoutes.toLogin());
          }
        }

        if (isMobile) {
          return IconButton(
            onPressed: handlePress,
            icon: Icon(
              isAuthenticated ? Icons.person : Icons.person_outline,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          );
        }

        return ElevatedButton.icon(
          onPressed: handlePress,
          icon: Icon(isAuthenticated ? Icons.person : Icons.person_outline),
          label: Text(
            isAuthenticated
                ? user?.name.split(' ').first ??
                      TranslationKeys.profile.tr(context)
                : TranslationKeys.logIn.tr(context),
          ),
        );
      },
    );
  }
}
