import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../widgets/common/headers/header_details.dart';
import '../../widgets/common/footer_section.dart';
import '../../widgets/common/headers/widgets/top_title.dart';
import 'package:z_ecommerce/presentation/pages/static/terms_page.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final companyData = context.watch<CompanyProvider>().companySettings;

    return Scaffold(
      appBar: HeaderDetails(title: TranslationKeys.termsConditions.tr(context),
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
                    companyData?.termsAndConditions.get(
                          context,
                        ) ??
                        '1. Acceptance of Terms\nBy accessing and using this website, you accept and agree to be bound by the terms and provision of this agreement.\n\n2. User Account\nYou are responsible for maintaining the confidentiality of your account and password and for restricting access to your computer.\n\n3. Privacy\nYour use of this website is subject to our Privacy Policy.\n\n4. Product Descriptions\nWe attempt to be as accurate as possible. However, we do not warrant that product descriptions or other content of this site is accurate, complete, reliable, current, or error-free.\n\n5. Modifications\nWe reserve the right to modify these terms at any time without prior notice.',
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
  }
}
