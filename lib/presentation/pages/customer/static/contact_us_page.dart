import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import '../../../../data/providers/business_provider.dart';
import '../../../global/core/constants/app_constants.dart';
import '../../../global/core/responsive/responsive_layout.dart';
import '../../../widgets/common/headers/header_details.dart';
import '../../../widgets/common/footer_section.dart';
import '../../../global/translate/app_localizations.dart';
import '../../../global/translate/translation_keys.dart';
import '../../../widgets/common/headers/widgets/top_title.dart';
import 'package:z_ecommerce/presentation/pages/customer/static/contact_us_page.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;

    String? getSocialLink(SocialPlatform type) {
      if (selectedBusiness?.socials == null) return null;
      for (final s in selectedBusiness!.socials) {
        if (s.platform == type) return s.url;
      }
      return null;
    }

    final contactEmail = getSocialLink(SocialPlatform.contactEmail) ?? "support@z-ecommerce.com";
    final contactPhone = getSocialLink(SocialPlatform.contactPhoneFirst) ?? "+1 800 123 4567";

    final businessProvider = Provider.of<BusinessProvider>(context);
    final business = businessProvider.selectedBusiness;
    return Scaffold(
      appBar: HeaderDetails(title: TranslationKeys.contactUs.tr(context),
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.contactUs.tr(context),
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
                    TranslationKeys.contactUsDescription.tr(context),
                    style: AppTextStyles.bodyText(
                      context,
                    ).copyWith(fontSize: isMobile ? 14 : 16, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  _ContactItem(
                    icon: Icons.email_outlined,
                    label: TranslationKeys.email.tr(context),
                    value: contactEmail,
                    onTap: () async {
                      final url = Uri.parse('mailto:$contactEmail');
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    },
                  ),
                  const SizedBox(height: 16),
                  _ContactItem(
                    icon: Icons.phone_outlined,
                    label: TranslationKeys.phone.tr(context),
                    value: contactPhone,
                    onTap: () async {
                      final url = Uri.parse('tel:$contactPhone');
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    },
                  ),
                  const SizedBox(height: 16),
                  _ContactItem(
                    icon: Icons.location_on_outlined,
                    label: TranslationKeys.addressFallback.tr(context),
                    value: business?.addresses?.firstOrNull?.address.get(context) ??
                        "123 Ecommerce St, City, Country",
                    onTap: () async {
                      final addr = business?.addresses?.firstOrNull;
                      if (addr != null) {
                        final url = Uri.parse(addr.linkMap);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    TranslationKeys.supportTeamAvailable.tr(context),
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

class _ContactItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  State<_ContactItem> createState() => _ContactItemState();
}

class _ContactItemState extends State<_ContactItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered
                ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: _hovered
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
