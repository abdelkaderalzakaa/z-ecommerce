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

class PrivacyPolicyPage extends StatelessWidget {
  final bool useAdminTheme;
  const PrivacyPolicyPage({super.key, this.useAdminTheme = true});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final theme = Theme.of(context);

    final businessProvider = Provider.of<BusinessProvider>(context);
    final business = businessProvider.selectedBusiness;
    final isGlobal = business.id.isEmpty;
    final superAdminProvider = context.watch<SuperAdminProvider>();
    final superAdmin = superAdminProvider.currentSuperAdmin;

    String privacyText = '';
    if (isGlobal) {
      final saPrivacy = superAdmin?.platformSettings.privacyContent.get(context);
      final saAdminPrivacy = superAdmin?.localizationAdmin.privacyPolicy.get(context);
      privacyText = (saPrivacy != null && saPrivacy.trim().isNotEmpty)
          ? saPrivacy
          : ((saAdminPrivacy != null && saAdminPrivacy.trim().isNotEmpty) ? saAdminPrivacy : '');
    } else {
      privacyText = business.localization.privacyPolicy.get(context);
    }

    final hasCustomPrivacy = privacyText.trim().isNotEmpty;

    final defaultGlobalPrivacySections = [
      {
        'title': '1. جمع المعلومات والبيانات',
        'content':
            'نجمع المعلومات اللازمة فقط لإتمام طلباتك وإدارة حسابك مثل الاسم، البريد الإلكتروني، رقم الهاتف، وعنوان التوصيل.',
        'icon': Icons.data_usage_rounded,
        'color': Colors.blue,
      },
      {
        'title': '2. استخدام المعلومات',
        'content':
            'تُستخدم المعلومات لتحسين تجربتك في التسوق، معالجة الطلبات، تقديم الدعم الفني، وإرسال التنبيهات الخاصة بطلباتك.',
        'icon': Icons.privacy_tip_outlined,
        'color': AppColors.green,
      },
      {
        'title': '3. حماية وأمان البيانات',
        'content':
            'نطبق أعلى معايير الأمان والتشفير لحماية بياناتك الشخصية والمالية ومنع أي وصول غير مصرح به.',
        'icon': Icons.lock_outline_rounded,
        'color': Colors.indigo,
      },
      {
        'title': '4. ملفات تعريف الارتباط (Cookies)',
        'content':
            'نستخدم الكوكيز لحفظ تفضيلاتك وتسهيل عملية تسجيل الدخول وتحسين أداء المنصة أثناء التصفح.',
        'icon': Icons.cookie_outlined,
        'color': Colors.amber.shade900,
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.privacyPolicy.tr(context),
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.privacyPolicy.tr(context),
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
                    // Subtitle Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.green.withOpacity(0.15),
                            radius: 26,
                            child: const Icon(Icons.security, color: AppColors.green, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  TranslationKeys.privacyPolicy.tr(context),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  TranslationKeys.privacySubtitle.tr(context),
                                  style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (!hasCustomPrivacy && !isGlobal) ...[
                      // Empty state for store with no privacy policy
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
                            Icon(Icons.privacy_tip_outlined, size: 48, color: theme.primaryColor.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              "لم يتم إضافة سياسة خصوصية خاصة بهذا المتجر بعد",
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
                      // Custom Privacy Content
                      if (hasCustomPrivacy) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            privacyText,
                            style: AppTextStyles.bodyText(context).copyWith(fontSize: 14, height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Standard Structured Privacy Cards (Only in Global Mode if no custom text)
                      if (isGlobal && !hasCustomPrivacy) ...[
                        ...defaultGlobalPrivacySections.map((sec) {
                          final color = sec['color'] as Color;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: color.withOpacity(0.35)),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      sec['icon'] as IconData,
                                      color: color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sec['title'] as String,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          sec['content'] as String,
                                          style: AppTextStyles.bodyText(context).copyWith(
                                            fontSize: 13,
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
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
