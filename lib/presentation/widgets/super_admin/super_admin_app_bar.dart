import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/locale_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../../global/navigation.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/super_admin/profile/super_admin_profile_page.dart';

class SuperAdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final bool isMobile;

  const SuperAdminAppBar({
    super.key,
    this.onMenuPressed,
    this.isMobile = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
              tooltip: 'الرمز الرئيسي',
            ),
            const SizedBox(width: 8),
          ],

          // App Logo and Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Z-Ecommerce',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    TranslationKeys.superAdminControlPanel.tr(context),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Quick Search Box (hidden on narrow screens)
          if (!isMobile)
            Container(
              width: 260,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 18,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: TranslationKeys.searchPlaceholder.tr(context),
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (!isMobile) const SizedBox(width: 16),

          // Dark / Light Theme Switcher Button
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 22,
            ),
            tooltip: isDark
                ? (AppLocalizations.of(context)?.translate('light') ?? 'الوضع المضيء')
                : (AppLocalizations.of(context)?.translate('dark') ?? 'الوضع الداكن'),
            onPressed: () {
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
              settingsProvider.setThemeMode(newMode);
            },
          ),

          // Language Switcher
          IconButton(
            icon: const Icon(Icons.language_outlined, size: 22),
            tooltip: AppLocalizations.of(context)?.translate('localization') ?? 'تغيير اللغة',
            onPressed: () {
              final newLocale = localeProvider.locale.languageCode == 'ar'
                  ? const Locale('en')
                  : const Locale('ar');
              localeProvider.setLocale(newLocale);
            },
          ),

          // Notification Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, size: 22),
                tooltip: 'الإشعارات',
                onPressed: () {
                  _showNotificationsDialog(context);
                },
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Profile Dropdown Button
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Text(
                    (currentUser?.name.isNotEmpty == true)
                        ? currentUser!.name[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.name ?? 'Admin User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Text(
                        'Super Admin',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ],
            ),
            onSelected: (value) async {
              if (value == 'profile') {
                changeScreen(context, const SuperAdminProfilePage());
              } else if (value == 'logout') {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser?.name ?? 'Super Admin',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currentUser?.email ?? 'admin@system.com',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18),
                    SizedBox(width: 10),
                    Text('الملف الشخصي'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('الإعدادات'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active_outlined),
            SizedBox(width: 8),
            Text('تنبيهات المسؤول الأكبر'),
          ],
        ),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.store, color: Colors.white, size: 18),
                ),
                title: const Text('طلب متجر جديد', style: TextStyle(fontSize: 14)),
                subtitle: const Text('تم تقديم طلب إنشاء متجر جديد "Electronix"', style: TextStyle(fontSize: 12)),
                trailing: const Text('منذ 10د', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check_circle, color: Colors.white, size: 18),
                ),
                title: const Text('تحديث النظام', style: TextStyle(fontSize: 14)),
                subtitle: const Text('تم تحديث قاعدة البيانات بنجاح', style: TextStyle(fontSize: 12)),
                trailing: const Text('منذ 1س', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
