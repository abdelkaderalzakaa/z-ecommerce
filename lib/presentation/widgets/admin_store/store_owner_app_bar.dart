import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global/locale_provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/settings_provider.dart';
import '../../global/navigation.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import '../../pages/business/profile/store_owner_profile_page.dart';

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
    final businessProvider = Provider.of<BusinessProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final storeTheme = businessProvider.selectedBusiness?.theme;
    final primaryColor = storeTheme?.primaryColorValue ?? theme.primaryColor;
    final fontFamily = storeTheme?.fontFamily ?? 'Cairo';
    final nameObj = businessProvider.selectedBusiness?.localization.name;
    final storeName = nameObj != null
        ? (isArabic ? nameObj.ar : nameObj.en)
        : TranslationKeys.mainStore.tr(context);
    final logoUrl = storeTheme?.logoUrl;

    return AppBar(
      elevation: 0,
      backgroundColor: theme.cardColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      leading: isMobile
          ? IconButton(
              icon: Icon(Icons.menu_rounded, color: primaryColor),
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
              borderRadius: storeTheme?.cardBorderRadius ?? BorderRadius.circular(10),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
              image: logoUrl != null
                  ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: logoUrl == null
                ? Icon(
                    Icons.storefront_rounded,
                    color: primaryColor,
                    size: 20,
                  )
                : null,
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
                  color: storeTheme?.textColorValue,
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
            return IconButton(
              icon: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDark ? Colors.amber : theme.primaryColor,
                size: 22,
              ),
              onPressed: () {
                settings.setThemeMode(
                  isDark ? ThemeMode.light : ThemeMode.dark,
                );
              },
              tooltip: TranslationKeys.theme.tr(context),
            );
          },
        ),
        const SizedBox(width: 8),

        // Language Toggle Button (AR / EN)
        InkWell(
          onTap: () {
            final nextLocale = isArabic ? const Locale('en') : const Locale('ar');
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
                Icon(Icons.language_rounded, size: 16, color: theme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  isArabic ? 'English' : 'العربية',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Notifications Icon Button
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 22),
          tooltip: TranslationKeys.notifications.tr(context),
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
                  backgroundImage: logoUrl != null ? NetworkImage(logoUrl) : null,
                  child: logoUrl == null
                      ? Text(
                          'S',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  Text(
                    storeName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
