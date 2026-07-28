import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/locale_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

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
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return AppBar(
      elevation: 0,
      backgroundColor: theme.cardColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      leading: isMobile
          ? IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: onMenuPressed,
            )
          : null,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: theme.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'لوحة تحكم المتجر',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Store Owner Portal',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
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
              const SnackBar(content: Text('لا توجد إشعارات جديدة حالياً')),
            );
          },
        ),
        const SizedBox(width: 8),

        // Store Avatar & Name
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.primaryColor.withOpacity(0.15),
              child: Text(
                'S',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              const Text(
                'متجري التجاري',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
