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
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/top_title.dart';

class TermsPage extends StatelessWidget {
  final bool useAdminTheme;
  const TermsPage({super.key, this.useAdminTheme = true});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final theme = Theme.of(context);

    final businessProvider = Provider.of<BusinessProvider>(context);
    final business = businessProvider.selectedBusiness;
    final isGlobal = business.id.isEmpty;
    final superAdminProvider = context.watch<SuperAdminProvider>();

    String termsText = '';
    if (isGlobal) {
      final saTerms = superAdminProvider.platformSettings.termsContent.get(context);
      final saAdminTerms = superAdminProvider.platformLocalization.termsAndConditions.get(
        context,
      );
      termsText = (saTerms.trim().isNotEmpty)
          ? saTerms
          : ((saAdminTerms.trim().isNotEmpty)
                ? saAdminTerms
                : '');
    } else {
      termsText = business.localization.termsAndConditions.get(context);
    }

    final hasCustomTerms = termsText.trim().isNotEmpty;

    final defaultGlobalSections = [
      {
        'number': '01',
        'title': 'القبول والموافقة على الشروط',
        'content':
            'باستخدامك لمنصتنا وتصفح المتاجر، فإنك توافق على الالتزام بجميع شروط الاستخدام والسياسات المعلنة دون أي استثناء.',
        'icon': Icons.gavel_rounded,
      },
      {
        'number': '02',
        'title': 'إنشاء الحسابات وحماية البيانات',
        'content':
            'يتعهد المستخدم بتقديم معلومات دقيقة وصحيحة عند التسجيل، وتحمل مسؤولية الحفاظ على سرية كلمة المرور وبيانات الدخول.',
        'icon': Icons.admin_panel_settings_outlined,
      },
      {
        'number': '03',
        'title': 'الطلبات والدفع الإلكتروني',
        'content':
            'جميع أسعار المنتجات الموضحة تشمل الرسوم المعمول بها. يتم تأكيد الطلبات فور إتمام عملية الدفع بنجاح عبر وسائل الدفع المعتمدة.',
        'icon': Icons.payments_outlined,
      },
      {
        'number': '04',
        'title': 'الاسترجاع والاستبدال',
        'content':
            'يحق للعميل تقديم طلب استرجاع المنتجات وفقاً لسياسة الاسترجاع الخاصة بكل متجر معتمد خلال المدة المحددة بالنظام.',
        'icon': Icons.published_with_changes_rounded,
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderDetails(title: TranslationKeys.termsConditions.tr(context)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopTitle(
              title: TranslationKeys.termsConditions.tr(context),
              paths: [
                TranslationKeys.home.tr(context),
                TranslationKeys.termsConditions.tr(context),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: hPad),
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
                            backgroundColor: theme.primaryColor.withOpacity(
                              0.12,
                            ),
                            radius: 26,
                            child: Icon(
                              Icons.rule_folder_outlined,
                              color: theme.primaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  TranslationKeys.termsConditions.tr(context),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  TranslationKeys.termsSubtitle.tr(context),
                                  style: AppTextStyles.bodyText(
                                    context,
                                  ).copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (!hasCustomTerms && !isGlobal) ...[
                      // Empty state for store with no terms
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
                            Icon(
                              Icons.gavel_outlined,
                              size: 48,
                              color: theme.primaryColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "لم يتم إضافة شروط وأحكام خاصة بهذا المتجر بعد",
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
                      // Custom Terms Content
                      if (hasCustomTerms) ...[
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
                            termsText,
                            style: AppTextStyles.bodyText(
                              context,
                            ).copyWith(fontSize: 14, height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Standard Structured Policy Cards (Only in Global Mode if no custom text)
                      if (isGlobal && !hasCustomTerms) ...[
                        ...defaultGlobalSections.map((sec) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(
                                        0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      sec['icon'] as IconData,
                                      color: theme.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              sec['number'] as String,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                sec['title'] as String,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          sec['content'] as String,
                                          style: AppTextStyles.bodyText(
                                            context,
                                          ).copyWith(fontSize: 13, height: 1.6),
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
