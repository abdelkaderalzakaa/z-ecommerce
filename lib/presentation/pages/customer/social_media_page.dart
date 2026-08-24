import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/top_title.dart';

class SocialMediaPage extends StatelessWidget {
  const SocialMediaPage({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(
      url.startsWith('http') ||
              url.startsWith('tel:') ||
              url.startsWith('mailto:') ||
              url.startsWith('https://wa.me')
          ? url
          : 'https://$url',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _copyToClipboard(context, url);
        }
      }
    } catch (_) {
      if (context.mounted) {
        _copyToClipboard(context, url);
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ الرابط: $text'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final businessProvider = context.watch<BusinessProvider>();
    final selectedBusiness = businessProvider.selectedBusiness;
    final hasSelectedBusiness = !selectedBusiness.isEmpty;

    final superAdminProvider = context.watch<SuperAdminProvider>();

    final String pageTitle = hasSelectedBusiness
        ? selectedBusiness.localization.name.get(context)
        : (superAdminProvider.platformLocalization.name.get(context).isNotEmpty
            ? superAdminProvider.platformLocalization.name.get(context)
            : 'z-matajer');

    final String phone = hasSelectedBusiness
        ? (selectedBusiness.ownerPhone ?? '')
        : ((superAdminProvider.platformSettings.phone != null &&
                superAdminProvider.platformSettings.phone!.isNotEmpty)
            ? superAdminProvider.platformSettings.phone!
            : '+966 50 123 4567');
    final String email = hasSelectedBusiness
        ? (selectedBusiness.ownerEmail ?? '')
        : ((superAdminProvider.platformSettings.email != null &&
                superAdminProvider.platformSettings.email!.isNotEmpty)
            ? superAdminProvider.platformSettings.email!
            : 'support@z-matajer.com');

    final List<SocialModel> entitySocials = hasSelectedBusiness
        ? selectedBusiness.socials
        : superAdminProvider.platformSocials;

    final List<_SocialChannelItem> channels = [];

    // Map SocialModel list to display channels
    for (final s in entitySocials.where(
      (s) => s.isVisible && s.url.isNotEmpty,
    )) {
      channels.add(
        _SocialChannelItem(
          name: s.title.get(context),
          subtitle: s.url,
          icon: Icons.link,
          color: s.color,
          url: s.url,
        ),
      );
    }

    // Default Fallbacks if list is empty
    if (channels.isEmpty) {
      if (phone.isNotEmpty) {
        channels.add(
          _SocialChannelItem(
            name: isAr ? 'واتساب الرسمي' : 'Official WhatsApp',
            subtitle: phone,
            icon: Icons.chat,
            color: const Color(0xFF25D366),
            url: 'https://wa.me/${phone.replaceAll(RegExp(r'[^0-9+]'), '')}',
          ),
        );
        channels.add(
          _SocialChannelItem(
            name: isAr ? 'الاتصال المباشر' : 'Direct Call',
            subtitle: phone,
            icon: Icons.phone,
            color: Colors.blue,
            url: 'tel:$phone',
          ),
        );
      }
      if (email.isNotEmpty) {
        channels.add(
          _SocialChannelItem(
            name: isAr ? 'البريد الإلكتروني' : 'Email Address',
            subtitle: email,
            icon: Icons.email,
            color: Colors.deepOrange,
            url: 'mailto:$email',
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: isAr
            ? 'وسائل التواصل والاتصال'
            : 'Social Media & Contact Channels',
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopTitle(
              title: isAr
                  ? 'وسائل التواصل والاتصال'
                  : 'Social Media & Contact Channels',
              paths: [isAr ? 'وسائل التواصل' : 'Social Media'],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Hero Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.share,
                          color: theme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr
                                  ? 'قنوات التواصل الرسمي'
                                  : 'Official Communication Channels',
                              style: TextStyle(
                                fontSize: isMobile ? 22 : 28,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAr
                                  ? 'تواصل معنا مباشرة عبر المنصات الاجتماعية الرسمية لـ ($pageTitle)'
                                  : 'Connect with ($pageTitle) via official social media channels',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Channels Grid
                  if (channels.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 60,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.contact_support_outlined,
                            size: 64,
                            color: theme.primaryColor.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isAr
                                ? 'لم يتم إضافة وسائل تواصل بعد'
                                : 'No Social Channels Available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: isMobile ? 1.4 : 1.6,
                      ),
                      itemCount: channels.length,
                      itemBuilder: (context, index) {
                        final channel = channels[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _launchUrl(context, channel.url),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: channel.color.withOpacity(
                                              0.12,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            channel.icon,
                                            color: channel.color,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                channel.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                channel.subtitle,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textMuted,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ButtonApp(
                                          label: isAr
                                              ? 'انتقال / زيارة'
                                              : 'Visit Now',
                                          icon: Icons.open_in_new,
                                          fontSize: 12,
                                          onPressed: () =>
                                              _launchUrl(context, channel.url),
                                        ),
                                        IconButton(
                                          tooltip: isAr
                                              ? 'نسخ الرابط'
                                              : 'Copy Link',
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 18,
                                          ),
                                          onPressed: () => _copyToClipboard(
                                            context,
                                            channel.url,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _SocialChannelItem {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String url;

  _SocialChannelItem({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.url,
  });
}
