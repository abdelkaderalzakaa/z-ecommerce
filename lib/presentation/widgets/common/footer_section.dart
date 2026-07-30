import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/models/company/company_settings_model.dart';
import '../../../data/providers/company_provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/logo.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/static/about_page.dart';
import 'package:z_ecommerce/presentation/pages/static/contact_us_page.dart';
import 'package:z_ecommerce/presentation/pages/static/terms_page.dart';
import 'package:z_ecommerce/presentation/pages/static/privacy_policy_page.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: isMobile ? 40 : 64,
            ),
            child: isMobile ? _MobileFooter() : const _DesktopFooter(),
          ),
          Container(height: 1, color: Theme.of(context).dividerColor),
          Copyright(),
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

        Spacer(flex: 2),
        Expanded(
          child: _FooterLinkColumn(
            title: TranslationKeys.help.tr(context),
            links: [
              (
                label: TranslationKeys.about.tr(context),
                onTap: () {
                  changeScreen(context, const AboutPage());
                },
              ),
              (
                label: TranslationKeys.contactUs.tr(context),
                onTap: () {
                  changeScreen(context, const ContactUsPage());
                },
              ),
              (
                label: TranslationKeys.termsConditions.tr(context),
                onTap: () {
                  changeScreen(context, const TermsPage());
                },
              ),
              (
                label: TranslationKeys.privacyPolicy.tr(context),
                onTap: () {
                  changeScreen(context, const PrivacyPolicyPage());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BrandColumn(),
        const SizedBox(height: 40),
        Wrap(
          spacing: 40,
          runSpacing: 32,
          children: [
            _FooterLinkColumn(
              title: TranslationKeys.help.tr(context),
              links: [
                (
                  label: TranslationKeys.about.tr(context),
                  onTap: () {
                    changeScreen(context, const AboutPage());
                  },
                ),
                (
                  label: TranslationKeys.contactUs.tr(context),
                  onTap: () {
                    changeScreen(context, const ContactUsPage());
                  },
                ),
                (
                  label: TranslationKeys.termsConditions.tr(context),
                  onTap: () {
                    changeScreen(context, const TermsPage());
                  },
                ),
                (
                  label: TranslationKeys.privacyPolicy.tr(context),
                  onTap: () {
                    changeScreen(context, const PrivacyPolicyPage());
                  },
                ),
              ],
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
    final companyData = context.watch<CompanyProvider>().companySettings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          companyData?.name.get(context) ?? 'SHOP.CO',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          companyData?.footerDescription.get(context) ??
              'We have clothes that suits your style and which you\'re proud to wear. From women to men.',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        if (companyData?.socials != null && companyData!.socials.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: companyData.socials.where((social) {
              return social.socialType != SocialType.contactPhoneFirst &&
                  social.socialType != SocialType.contactPhoneSecond &&
                  social.socialType != SocialType.contactEmail;
            }).map((social) {
              return _SocialIcon(
                icon: _getIconForType(social.socialType),
                onTap: () {
                  if (social.socialType == SocialType.whatsapp) {
                    final phone = social.link.replaceAll(RegExp(r'[^\d+]'), '');
                    _launchUrl('https://wa.me/$phone');
                  } else {
                    _launchUrl(social.link);
                  }
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  dynamic _getIconForType(SocialType type) {
    switch (type) {
      case SocialType.facebook:
        return FontAwesomeIcons.facebookF;
      case SocialType.instagram:
        return FontAwesomeIcons.instagram;
      case SocialType.twitter:
        return FontAwesomeIcons.xTwitter;
      case SocialType.whatsapp:
        return FontAwesomeIcons.whatsapp;
      case SocialType.tiktok:
        return FontAwesomeIcons.tiktok;
      case SocialType.linkedin:
        return FontAwesomeIcons.linkedinIn;
      case SocialType.youtube:
        return FontAwesomeIcons.youtube;
      default:
        return Icons.link;
    }
  }

  void _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}

class _SocialIcon extends StatefulWidget {
  final dynamic icon;
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovered ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
          child: Center(
            child: widget.icon is IconData
                ? Icon(
                    widget.icon,
                    size: 18,
                    color: _hovered ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  )
                : FaIcon(
                    widget.icon,
                    size: 18,
                    color: _hovered ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 14,
              color: _hovered ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: _hovered ? FontWeight.w500 : FontWeight.w400,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

