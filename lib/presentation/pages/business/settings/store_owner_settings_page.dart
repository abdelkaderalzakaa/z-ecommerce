import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

// Import all sub-pages
import 'package:z_ecommerce/presentation/pages/business/settings/store_business_info_page.dart';
import 'package:z_ecommerce/presentation/pages/business/settings/store_business_permissions_page.dart';
import 'package:z_ecommerce/presentation/pages/business/store_manage_socials_page.dart';
import 'package:z_ecommerce/presentation/pages/business/store_manage_addresses_page.dart';
import 'package:z_ecommerce/presentation/pages/business/store_manage_payment_methods_page.dart';
import 'package:z_ecommerce/presentation/pages/business/branding/business_branding_page.dart';
import 'package:z_ecommerce/presentation/pages/business/branding/restaurant_menu_branding_page.dart';

class StoreOwnerSettingsPage extends StatelessWidget {
  const StoreOwnerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final business = context.watch<BusinessProvider>().selectedBusiness;
    final isRestaurant = business.businessType == BusinessType.restaurant;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(TranslationKeys.storeSettingsTitle.tr(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TranslationKeys.storeSettingsSubtitle.tr(context),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                  if (constraints.maxWidth > 900) crossAxisCount = 4;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSettingsCard(
                        context: context,
                        title: 'معلومات البزنس',
                        subtitle: 'تعديل البيانات الأساسية والنصوص',
                        icon: Icons.storefront_rounded,
                        color: Colors.blue,
                        onTap: () => changeScreen(context, const StoreBusinessInfoPage()),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: 'صلاحيات البزنس',
                        subtitle: 'الصلاحيات المحددة من الإدارة العامة',
                        icon: Icons.admin_panel_settings_rounded,
                        color: Colors.orange,
                        onTap: () => changeScreen(context, const StoreBusinessPermissionsPage()),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: 'وسائل التواصل',
                        subtitle: 'إدارة الروابط وأرقام التواصل',
                        icon: Icons.connect_without_contact_rounded,
                        color: Colors.pink,
                        onTap: () => changeScreen(context, StoreManageSocialsPage(store: business)),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: 'العناوين والمواقع',
                        subtitle: 'تعديل عناوين الفروع والمواقع الجغرافية',
                        icon: Icons.location_on_rounded,
                        color: Colors.teal,
                        onTap: () => changeScreen(context, StoreManageAddressesPage(store: business)),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: 'طرق الدفع',
                        subtitle: 'إدارة وتفعيل طرق الدفع المتاحة',
                        icon: Icons.payments_rounded,
                        color: Colors.green,
                        onTap: () => changeScreen(context, StoreManagePaymentMethodsPage(store: business)),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: 'تخصيص الهوية',
                        subtitle: 'تخصيص ألوان المتجر والشعارات',
                        icon: Icons.palette_rounded,
                        color: Colors.purple,
                        onTap: () => changeScreen(context, const StoreBrandingPage()),
                      ),
                      if (isRestaurant)
                        _buildSettingsCard(
                          context: context,
                          title: 'تخصيص المنيو',
                          subtitle: 'إدارة تصميم وشكل المنيو الرقمي',
                          icon: Icons.restaurant_menu_rounded,
                          color: Colors.redAccent,
                          onTap: () => changeScreen(context, const RestaurantMenuBrandingPage()),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
      ),
      color: theme.cardColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
