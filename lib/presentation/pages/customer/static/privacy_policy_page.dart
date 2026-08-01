import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import '../../../../data/providers/business_provider.dart';
import '../../../global/core/constants/app_constants.dart';
import '../../../global/core/responsive/responsive_layout.dart';
import '../../../widgets/common/headers/header_details.dart';
import '../../../widgets/common/footer_section.dart';
import '../../../widgets/common/headers/widgets/top_title.dart';
import 'package:z_ecommerce/presentation/pages/customer/static/privacy_policy_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: HeaderDetails(
        title: TranslationKeys.privacyPolicy.tr(context),
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.privacyPolicy.tr(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Your privacy is critically important to us.\n\n1. Information Collection\nWe collect information from you when you register on our site, place an order, or subscribe to our newsletter.\n\n2. Use of Information\nAny of the information we collect from you may be used to personalize your experience, improve our website, or process transactions.\n\n3. Data Protection\nWe implement a variety of security measures to maintain the safety of your personal information when you place an order or enter, submit, or access your personal information.\n\n4. Cookies\nWe use cookies to understand and save your preferences for future visits and compile aggregate data about site traffic and site interaction.\n\n5. Contacting Us\nIf there are any questions regarding this privacy policy, you may contact us using the information on our Contact Us page.',
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
