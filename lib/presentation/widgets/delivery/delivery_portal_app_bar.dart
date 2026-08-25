import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';
import 'package:z_ecommerce/presentation/global/settings_provider.dart';
import 'package:z_ecommerce/presentation/pages/auth/login_page.dart';

class DeliveryPortalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final bool isMobile;

  const DeliveryPortalAppBar({
    super.key,
    this.onMenuPressed,
    this.isMobile = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final deliveryProvider = context.watch<DeliveryProvider>();
    final isAr = localeProvider.locale.languageCode == 'ar';

    final delivery = deliveryProvider.currentDelivery;
    final isCompany = delivery.type == DeliveryEntityType.company;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: isAr ? 'القائمة' : 'Menu',
              onPressed: onMenuPressed,
            ),
            const SizedBox(width: 6),
          ],

          // App/Entity Logo and Branding
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  isCompany ? Icons.local_shipping_rounded : Icons.two_wheeler_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.name.isNotEmpty
                        ? delivery.name
                        : (isAr ? 'بوابة التوصيل والشحن' : 'Delivery & Logistics Portal'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    isCompany
                        ? (isAr ? 'شركة شحن وتوصيل معتمدة' : 'Certified Delivery Partner')
                        : (isAr ? 'كابتن توصيل مستقل' : 'Independent Courier Captain'),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Online / Offline Status Switcher Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: delivery.isOnline
                  ? Colors.green.withOpacity(0.12)
                  : Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: delivery.isOnline
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: delivery.isOnline ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                if (!isMobile) ...[
                  Text(
                    delivery.isOnline
                        ? (isAr ? 'متاح أونلاين' : 'Online')
                        : (isAr ? 'غير متاح (أوفلاين)' : 'Offline'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: delivery.isOnline ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: delivery.isOnline,
                    activeColor: Colors.green,
                    onChanged: (_) => deliveryProvider.toggleOnlineStatus(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Language Switcher Button (عربي / EN)
          IconButton(
            tooltip: isAr ? 'Switch to English' : 'التحويل للعربية',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    isAr ? 'EN' : 'عربي',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () => localeProvider.toggleLanguage(),
          ),

          // Theme Switcher Button (Dark / Light)
          IconButton(
            tooltip: isAr ? 'تبديل المظهر' : 'Toggle Theme',
            icon: Icon(
              settingsProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: theme.textTheme.bodyMedium?.color,
              size: 20,
            ),
            onPressed: () => settingsProvider.toggleTheme(),
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
            tooltip: isAr ? 'تسجيل الخروج' : 'Logout',
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
