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
import 'package:z_ecommerce/presentation/pages/static/about_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final companyData = context.watch<CompanyProvider>().companySettings;

    return Scaffold(
      appBar: HeaderDetails(
        title: TranslationKeys.about.tr(context),
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.about.tr(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyData?.aboutUs.get(context) ??
                        'Welcome to Z-Ecommerce. We are dedicated to providing the best online shopping experience. Our mission is to offer high-quality products at competitive prices, all while ensuring exceptional customer service.\n\nFounded in 2023, we have quickly grown to become a trusted name in ecommerce. Whether you are looking for the latest fashion trends, electronics, or home essentials, we have something for everyone.\n\nThank you for choosing Z-Ecommerce!',
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
