import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/setup/platform_setup_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/settings/platform_info_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/settings/platform_branding_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/settings/platform_socials_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/settings/platform_policies_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/settings/platform_features_page.dart';

class PlatformSettingsPage extends StatelessWidget {
  const PlatformSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final platformName = context.watch<SuperAdminProvider>().platformLocalization.name.get(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(0.12),
                      theme.cardColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.settings_suggest_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الإعدادات العامة لمنصة ${platformName.isNotEmpty ? platformName : 'زد للمتاجر'}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تحكم كامل في هوية المنصة، الثيم، وسائل التواصل، السياسات، والميزات التفاعلية.',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Settings Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
                  if (constraints.maxWidth > 1100) crossAxisCount = 3;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 1.15,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSettingsCard(
                        context: context,
                        title: 'معلومات ونصوص المنصة',
                        subtitle: 'تعديل اسم المنصة الرسمي، الشعار اللفظي، والوصف العام',
                        icon: Icons.storefront_rounded,
                        color: Colors.blue,
                        onTap: () => changeScreen(context, const PlatformInfoPage()),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: 'تخصيص الهوية والثيم',
                        subtitle: 'التحكم بالألوان الرئيسية، اللوجو، الخطوط، وانحناءات الحواف',
                        icon: Icons.palette_rounded,
                        color: Colors.purple,
                        onTap: () => changeScreen(context, const PlatformBrandingPage()),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: 'وسائل التواصل والدعم',
                        subtitle: 'إدارة أرقام وقنوات الدعم الفني وروابط التواصل الرسمي',
                        icon: Icons.connect_without_contact_rounded,
                        color: Colors.pink,
                        onTap: () => changeScreen(context, const PlatformSocialsPage()),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: 'الشروط والسياسات وصفحة من نحن',
                        subtitle: 'إدارة نصوص الشروط والأحكام، سياسة الخصوصية، ومعلومات المنصة',
                        icon: Icons.gavel_rounded,
                        color: Colors.teal,
                        onTap: () => changeScreen(context, const PlatformPoliciesPage()),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: 'التحكم بالسكاشن والميزات',
                        subtitle: 'تفعيل الميزات التفاعلية وظهور سكاشن الصفحة الرئيسية',
                        icon: Icons.tune_rounded,
                        color: Colors.orange,
                        onTap: () => changeScreen(context, const PlatformFeaturesPage()),
                      ),
                      _buildSettingsCard(
                        context: context,
                        title: 'معالج التأسيس الشامل',
                        subtitle: 'إعادة فتح معالج التأسيس والتهيئة السريعة للمنصة بالكامل',
                        icon: Icons.rocket_launch_rounded,
                        color: Colors.indigo,
                        onTap: () => changeScreen(context, const PlatformSetupPage()),
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
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
      ),
      color: theme.cardColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
