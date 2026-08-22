import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../data/models/common/social_media.dart';
import '../../../../data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';

import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/logo.dart';
import '../../../global/core/responsive/responsive_layout.dart';
import '../../../global/translate/app_localizations.dart';
import '../../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/static/about_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/static/contact_us_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/static/terms_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/static/privacy_policy_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/customer_addresses_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/social_media_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/payment_methods_page.dart';

class FooterSection extends StatelessWidget {
  final bool useAdminTheme;
  const FooterSection({super.key, this.useAdminTheme = false});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: isMobile ? 40 : 64,
            ),
            child: isMobile
                ? _MobileFooter(useAdminTheme: useAdminTheme)
                : _DesktopFooter(useAdminTheme: useAdminTheme),
          ),
          const Copyright(isPlatform: true),
        ],
      ),
    );
  }
}

class _DesktopFooter extends StatelessWidget {
  final bool useAdminTheme;
  const _DesktopFooter({this.useAdminTheme = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _BrandColumn()),
        const SizedBox(width: 40),

        Expanded(
          flex: 2,
          child: _FooterLinkColumn(
            title: TranslationKeys.help.tr(context),
            links: [
              (
                label: TranslationKeys.about.tr(context),
                onTap: () => changeScreen(
                  context,
                  AboutPage(useAdminTheme: useAdminTheme),
                ),
              ),
              (
                label: TranslationKeys.contactUs.tr(context),
                onTap: () => changeScreen(
                  context,
                  ContactUsPage(useAdminTheme: useAdminTheme),
                ),
              ),
              (
                label: Localizations.localeOf(context).languageCode == 'ar' ? 'وسائل التواصل الاجتماعي' : 'Social Media',
                onTap: () => changeScreen(
                  context,
                  const SocialMediaPage(),
                ),
              ),
              (
                label: Localizations.localeOf(context).languageCode == 'ar' ? 'طرق الدفع المتاحة' : 'Payment Methods',
                onTap: () => changeScreen(
                  context,
                  const PaymentMethodsPage(),
                ),
              ),
              (
                label: Localizations.localeOf(context).languageCode == 'ar' ? 'عناوين التوصيل' : 'Delivery Addresses',
                onTap: () => changeScreen(
                  context,
                  const CustomerAddressesPage(),
                ),
              ),
              (
                label: TranslationKeys.termsConditions.tr(context),
                onTap: () => changeScreen(
                  context,
                  TermsPage(useAdminTheme: useAdminTheme),
                ),
              ),
              (
                label: TranslationKeys.privacyPolicy.tr(context),
                onTap: () => changeScreen(
                  context,
                  PrivacyPolicyPage(useAdminTheme: useAdminTheme),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileFooter extends StatelessWidget {
  final bool useAdminTheme;
  const _MobileFooter({this.useAdminTheme = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BrandColumn(),
        const SizedBox(height: 32),
        _FooterLinkColumn(
          title: TranslationKeys.help.tr(context),
          links: [
            (
              label: TranslationKeys.about.tr(context),
              onTap: () => changeScreen(
                context,
                AboutPage(useAdminTheme: useAdminTheme),
              ),
            ),
            (
              label: TranslationKeys.contactUs.tr(context),
              onTap: () => changeScreen(
                context,
                ContactUsPage(useAdminTheme: useAdminTheme),
              ),
            ),
            (
              label: Localizations.localeOf(context).languageCode == 'ar' ? 'وسائل التواصل الاجتماعي' : 'Social Media',
              onTap: () => changeScreen(
                context,
                const SocialMediaPage(),
              ),
            ),
            (
              label: Localizations.localeOf(context).languageCode == 'ar' ? 'طرق الدفع المتاحة' : 'Payment Methods',
              onTap: () => changeScreen(
                context,
                const PaymentMethodsPage(),
              ),
            ),
            (
              label: Localizations.localeOf(context).languageCode == 'ar' ? 'عناوين التوصيل' : 'Delivery Addresses',
              onTap: () => changeScreen(
                context,
                const CustomerAddressesPage(),
              ),
            ),
            (
              label: TranslationKeys.termsConditions.tr(context),
              onTap: () => changeScreen(
                context,
                TermsPage(useAdminTheme: useAdminTheme),
              ),
            ),
            (
              label: TranslationKeys.privacyPolicy.tr(context),
              onTap: () => changeScreen(
                context,
                PrivacyPolicyPage(useAdminTheme: useAdminTheme),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final superAdmin = context.watch<SuperAdminProvider>().currentSuperAdmin;
    final platformName =
        superAdmin?.localizationAdmin.name.get(context) ?? 'z-matajer';
    final platformDescription =
        superAdmin?.localizationAdmin.footerDescription.get(context) ??
        'منصة متقدمة للتجارة الإلكترونية.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          platformName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          platformDescription,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovered
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 18,
              color: _hovered
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterLinkColumn extends StatelessWidget {
  final String title;
  final List<({String label, VoidCallback onTap})> links;

  const _FooterLinkColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        ...links.map(
          (link) => _FooterLink(label: link.label, onTap: link.onTap),
        ),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 14,
              color: _hovered
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: _hovered ? FontWeight.w500 : FontWeight.w400,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
