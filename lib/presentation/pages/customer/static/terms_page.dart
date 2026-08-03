import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import '../../../../data/providers/business_provider.dart';
import '../../../global/core/constants/app_constants.dart';
import '../../../global/core/responsive/responsive_layout.dart';
import '../../../widgets/common/headers/header_details.dart';
import '../../../widgets/common/footers/footer_section.dart';
import '../../../widgets/common/headers/widgets/top_title.dart';
import 'package:z_ecommerce/presentation/pages/customer/static/terms_page.dart';
import '../../../../data/providers/super_admin_provider.dart';
import '../../../global/theme/app_theme.dart';
import '../../../global/settings_provider.dart';

class TermsPage extends StatelessWidget {
  final bool useAdminTheme;
  const TermsPage({super.key, this.useAdminTheme = false});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    final businessProvider = Provider.of<BusinessProvider>(context);
    final business = businessProvider.selectedBusiness;
    final settings = context.watch<SettingsProvider>();
    final superAdminProvider = context.watch<SuperAdminProvider>();

    final bool isDark = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final themeAdmin = superAdminProvider.currentSuperAdmin?.themeAdmin;
    final dynamicTheme = useAdminTheme 
        ? AppTheme.getThemeFromAdmin(themeAdmin, isDark) 
        : null;

    Widget content = Scaffold(
      appBar: HeaderDetails(
        title: TranslationKeys.termsConditions.tr(context),
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.termsConditions.tr(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    business?.localization.termsAndConditions.get(context) ??
                        "لا يوجد بيانات",
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(fontSize: isMobile ? 14 : 16, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
            const FooterSection(),
          ],
        ),
      ),
    );

    if (dynamicTheme != null) {
      content = Theme(
        data: dynamicTheme,
        child: content,
      );
    }

    return content;
  }
}
