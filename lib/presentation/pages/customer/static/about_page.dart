import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/global/theme/app_text_styles.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';

class AboutPage extends StatelessWidget {
  final bool useAdminTheme;
  const AboutPage({super.key, this.useAdminTheme = true});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final businessProvider = Provider.of<BusinessProvider>(context);
    final business = businessProvider.selectedBusiness;
    final isGlobal = business.id.isEmpty;

    final superAdminProvider = context.watch<SuperAdminProvider>();
    final superAdmin = superAdminProvider.currentSuperAdmin;

    // Data Resolution:
    // Global context -> Super Admin data
    // Business context -> Business data (if empty, don't show fallback)
    String aboutText = '';
    String headerTitle = '';
    String headerSubtitle = '';

    if (isGlobal) {
      final saAbout = superAdmin?.platformSettings.aboutUsContent.get(context);
      final saDesc = superAdmin?.localizationAdmin.description.get(context);
      aboutText = (saAbout != null && saAbout.trim().isNotEmpty)
          ? saAbout
          : ((saDesc != null && saDesc.trim().isNotEmpty)
              ? saDesc
              : 'z-matajer هي المنصة الأولى لدعم المتاجر والعمل الحر في منطقتك. نوفر تجربة تسوق إلكترونية متكاملة تربط التجار والعملاء بمرونة، أمان، وسرعة فائقة.');
      headerTitle = superAdmin?.localizationAdmin.name.get(context) ?? 'منصة z-matajer';
      headerSubtitle = 'المنصة التجارية الشاملة للمتاجر والتسوق الإلكتروني الموثوق';
    } else {
      aboutText = business.localization.aboutUs.get(context);
      headerTitle = business.localization.name.get(context);
      headerSubtitle = business.localization.description.get(context);
    }

    final hasContent = aboutText.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.about.tr(context),
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.about.tr(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 36),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!hasContent) ...[
                      // Store has no about us content empty state
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 48, color: theme.primaryColor.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              "لم يتم إضافة معلومات من قبل هذا المتجر بعد",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Hero Story Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [theme.primaryColor.withOpacity(0.3), theme.cardColor, theme.cardColor]
                                : [theme.primaryColor, theme.cardColor, theme.cardColor],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Flex(
                          direction: isMobile ? Axis.vertical : Axis.horizontal,
                          children: [
                            Expanded(
                              flex: isMobile ? 0 : 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        headerTitle,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (headerSubtitle.trim().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      headerSubtitle,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppColors.textMuted : theme.primaryColor.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  Text(
                                    aboutText,
                                    style: AppTextStyles.bodyText(context).copyWith(
                                      fontSize: isMobile ? 14 : 16,
                                      height: 1.6,
                                      color: isDark ? theme.textTheme.bodyLarge?.color : theme.primaryColor.withOpacity(0.95),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isMobile) const SizedBox(width: 24),
                            Expanded(
                              flex: isMobile ? 0 : 4,
                              child: Padding(
                                padding: EdgeInsets.only(top: isMobile ? 20 : 0),
                                child: Container(
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: theme.primaryColor.withOpacity(0.25)),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      size: 80,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Values Section (Only in Global or if specified)
                      if (isGlobal) ...[
                        Text(
                          TranslationKeys.ourValues.tr(context),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Flex(
                          direction: isMobile ? Axis.vertical : Axis.horizontal,
                          children: [
                            Expanded(
                              flex: isMobile ? 0 : 1,
                              child: const _ValueCard(
                                icon: Icons.shield_outlined,
                                title: "أمان وثقة عالية",
                                subtitle: "حماية كاملة للبيانات والتحاملات المالية الموثوقة.",
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12, height: 12),
                            Expanded(
                              flex: isMobile ? 0 : 1,
                              child: const _ValueCard(
                                icon: Icons.bolt_outlined,
                                title: "سرعة الأداء",
                                subtitle: "تصفح فورياً للشراء والتسليم السريع للطلبات.",
                                color: AppColors.green,
                              ),
                            ),
                            const SizedBox(width: 12, height: 12),
                            Expanded(
                              flex: isMobile ? 0 : 1,
                              child: const _ValueCard(
                                icon: Icons.workspace_premium_outlined,
                                title: "جودة المنتجات",
                                subtitle: "منتجات مفحوصة ومتاجر معتمدة مرخصة بالكامل.",
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),

                        Text(
                          TranslationKeys.platformStats.tr(context),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Flex(
                          direction: isMobile ? Axis.vertical : Axis.horizontal,
                          children: const [
                            Expanded(
                              child: _StatCard(
                                number: "+1,200",
                                label: "متجر نشط بالمنصة",
                                color: Colors.indigo,
                              ),
                            ),
                            SizedBox(width: 12, height: 12),
                            Expanded(
                              child: _StatCard(
                                number: "+50,000",
                                label: "منتج متاح للتسوق",
                                color: Colors.teal,
                              ),
                            ),
                            SizedBox(width: 12, height: 12),
                            Expanded(
                              child: _StatCard(
                                number: "24/7",
                                label: "دعم فني متواصل",
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ValueCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _StatCard({
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
