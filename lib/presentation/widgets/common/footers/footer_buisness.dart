import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../data/models/common/social_media.dart';
import '../../../../data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/logo.dart';
import '../../../global/core/responsive/responsive_layout.dart';
import '../../../global/translate/app_localizations.dart';
import '../../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/static/about_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/static/contact_us_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/static/terms_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/static/privacy_policy_page.dart';

class FooterBuisness extends StatelessWidget {
  final String idBuisness;
  const FooterBuisness({super.key, required this.idBuisness});

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
            child: isMobile ? const _MobileFooter() : const _DesktopFooter(),
          ),
          const Divider(height: 1),
          const Copyright(),
        ],
      ),
    );
  }
}

class _DesktopFooter extends StatelessWidget {
  const _DesktopFooter();

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
            title: TranslationKeys.home.tr(context),
            links: [
              (
                label: TranslationKeys.about.tr(context),
                onTap: () =>
                    changeScreen(context, const AboutPage(useAdminTheme: true)),
              ),
              (
                label: TranslationKeys.about.tr(context),
                onTap: () =>
                    changeScreen(context, const AboutPage(useAdminTheme: true)),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: _FooterLinkColumn(
            title: TranslationKeys.help.tr(context),
            links: [
              (
                label: TranslationKeys.contactUs.tr(context),
                onTap: () => changeScreen(
                  context,
                  const ContactUsPage(useAdminTheme: true),
                ),
              ),
              (
                label: TranslationKeys.termsConditions.tr(context),
                onTap: () =>
                    changeScreen(context, const TermsPage(useAdminTheme: true)),
              ),
              (
                label: TranslationKeys.privacyPolicy.tr(context),
                onTap: () => changeScreen(
                  context,
                  const PrivacyPolicyPage(useAdminTheme: true),
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
  const _MobileFooter();

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
              onTap: () =>
                  changeScreen(context, const AboutPage(useAdminTheme: true)),
            ),
            (
              label: TranslationKeys.contactUs.tr(context),
              onTap: () => changeScreen(
                context,
                const ContactUsPage(useAdminTheme: true),
              ),
            ),
            (
              label: TranslationKeys.termsConditions.tr(context),
              onTap: () =>
                  changeScreen(context, const TermsPage(useAdminTheme: true)),
            ),
            (
              label: TranslationKeys.privacyPolicy.tr(context),
              onTap: () => changeScreen(
                context,
                const PrivacyPolicyPage(useAdminTheme: true),
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
    final business = context.watch<BusinessProvider>().selectedBusiness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          business.localization.name.get(context),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          business.localization.footerDescription.get(context),
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
