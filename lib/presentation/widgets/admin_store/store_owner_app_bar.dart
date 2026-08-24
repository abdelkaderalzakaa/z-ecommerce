import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/pages/business/profile/store_owner_profile_page.dart';
import '../../global/locale_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import '../../../data/providers/business_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../global/settings_provider.dart';
import '../../global/navigation.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

import 'package:z_ecommerce/presentation/widgets/common/custom_network_image.dart';

class StoreOwnerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;
  final VoidCallback? onMenuPressed;

  const StoreOwnerAppBar({
    super.key,
    this.isMobile = false,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final businessProvider = context.watch<BusinessProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final storeTheme = businessProvider.selectedBusiness.theme;
    final primaryColor = storeTheme.primaryColorValue;
    final fontFamily = storeTheme.fontFamily;
    final nameObj = businessProvider.selectedBusiness.localization.name;
    final storeName = (isArabic ? nameObj.ar : nameObj.en);
    final logoUrl = storeTheme.logoUrl;
    final userName = authProvider.currentUser?.name ?? storeName;

    return AppBar(
      elevation: 0,
      backgroundColor: theme.cardColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      leading: isMobile
          ? ButtonApp(
              format: FormatButtonApp.icon,
              icon: Icons.menu_rounded,
              color: primaryColor,
              label: 'القائمة',
              onPressed: onMenuPressed,
            )
          : null,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: storeTheme.cardBorderRadius,
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: logoUrl == null
                ? Icon(Icons.storefront_rounded, color: primaryColor, size: 20)
                : CustomNetworkImage(
                    imageUrl: logoUrl,
                    width: 38,
                    height: 38,
                    borderRadius: storeTheme.cardBorderRadius,
                  ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                storeName,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: storeTheme.textColorValue,
                ),
              ),
              Text(
                TranslationKeys.storeOwnerPortal.tr(context),
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 10,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Theme Mode Toggle Button (Light / Dark)
        Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            final isDark = settings.themeMode == ThemeMode.dark;
            return ButtonApp(
              format: FormatButtonApp.icon,
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? Colors.amber : theme.primaryColor,
              label: TranslationKeys.theme.tr(context),
              onPressed: () {
                settings.setThemeMode(
                  isDark ? ThemeMode.light : ThemeMode.dark,
                );
              },
            );
          },
        ),
        const SizedBox(width: 8),

        // Language Toggle Button (AR / EN)
        InkWell(
          onTap: () {
            final nextLocale = isArabic
                ? const Locale('en')
                : const Locale('ar');
            localeProvider.setLocale(nextLocale);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language_rounded,
                  size: 16,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isArabic ? 'English' : 'العربية',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Notifications Icon Button
        ButtonApp(
          format: FormatButtonApp.icon,
          icon: Icons.notifications_none_rounded,
          label: TranslationKeys.notifications.tr(context),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'لا توجد إشعارات جديدة حالياً'
                      : 'No new notifications currently',
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),

        // Store Avatar & Name (Interactive Profile Navigation)
        InkWell(
          onTap: () {
            changeScreen(context, const StoreOwnerProfilePage());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.primaryColor.withOpacity(0.15),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
