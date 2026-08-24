import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/common/custom_network_image.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/top_title.dart';

class ContactUsPage extends StatelessWidget {
  final bool useAdminTheme;
  const ContactUsPage({super.key, this.useAdminTheme = true});

  void _openLink(String url, SocialPlatform? platform) {
    if (url.isEmpty) return;
    String target = url.trim();
    if (platform == SocialPlatform.contactEmail && !target.startsWith('mailto:')) {
      target = 'mailto:$target';
    } else if ((platform == SocialPlatform.contactPhoneFirst ||
            platform == SocialPlatform.contactPhoneSecond) &&
        !target.startsWith('tel:')) {
      target = 'tel:$target';
    } else if (platform == SocialPlatform.whatsapp && !target.startsWith('http')) {
      final cleanNum = target.replaceAll(RegExp(r'[^0-9+]'), '');
      target = 'https://wa.me/$cleanNum';
    } else if (!target.startsWith('http://') &&
        !target.startsWith('https://') &&
        !target.startsWith('mailto:') &&
        !target.startsWith('tel:')) {
      target = 'https://$target';
    }

    try {
      html.window.open(target, '_blank');
    } catch (_) {
      launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication);
    }
  }

  String _getPlatformLabel(BuildContext context, SocialPlatform platform) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (platform) {
      case SocialPlatform.whatsapp:
        return isAr ? 'واتساب' : 'WhatsApp';
      case SocialPlatform.instagram:
        return isAr ? 'إنستغرام' : 'Instagram';
      case SocialPlatform.facebook:
        return isAr ? 'فيسبوك' : 'Facebook';
      case SocialPlatform.tiktok:
        return isAr ? 'تيك توك' : 'TikTok';
      case SocialPlatform.twitter:
        return isAr ? 'تويتر / X' : 'Twitter (X)';
      case SocialPlatform.linkedin:
        return isAr ? 'لينكد إن' : 'LinkedIn';
      case SocialPlatform.youtube:
        return isAr ? 'يوتيوب' : 'YouTube';
      case SocialPlatform.website:
        return isAr ? 'الموقع الإلكتروني' : 'Website';
      case SocialPlatform.contactPhoneFirst:
        return isAr ? 'الهاتف الرئيسي' : 'Main Phone';
      case SocialPlatform.contactPhoneSecond:
        return isAr ? 'هاتف إضافي' : 'Secondary Phone';
      case SocialPlatform.contactEmail:
        return isAr ? 'البريد الإلكتروني' : 'Email Address';
    }
  }

  IconData _getPlatformIcon(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.whatsapp:
        return Icons.chat_rounded;
      case SocialPlatform.instagram:
        return Icons.camera_alt_rounded;
      case SocialPlatform.facebook:
        return Icons.facebook_rounded;
      case SocialPlatform.tiktok:
        return Icons.music_note_rounded;
      case SocialPlatform.twitter:
        return Icons.flutter_dash_rounded;
      case SocialPlatform.linkedin:
        return Icons.business_center_rounded;
      case SocialPlatform.youtube:
        return Icons.play_circle_fill_rounded;
      case SocialPlatform.website:
        return Icons.language_rounded;
      case SocialPlatform.contactPhoneFirst:
        return Icons.phone_rounded;
      case SocialPlatform.contactPhoneSecond:
        return Icons.phone_iphone_rounded;
      case SocialPlatform.contactEmail:
        return Icons.email_rounded;
    }
  }

  Color _getPlatformColor(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.whatsapp:
        return const Color(0xFF25D366);
      case SocialPlatform.instagram:
        return const Color(0xFFE4405F);
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.tiktok:
        return const Color(0xFF000000);
      case SocialPlatform.twitter:
        return const Color(0xFF1DA1F2);
      case SocialPlatform.linkedin:
        return const Color(0xFF0A66C2);
      case SocialPlatform.youtube:
        return const Color(0xFFFF0000);
      case SocialPlatform.website:
        return Colors.indigo;
      case SocialPlatform.contactPhoneFirst:
        return Colors.green;
      case SocialPlatform.contactPhoneSecond:
        return Colors.teal;
      case SocialPlatform.contactEmail:
        return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final langCode = Localizations.localeOf(context).languageCode;

    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final isGlobal = selectedBusiness.id.isEmpty;
    final superAdminProvider = context.watch<SuperAdminProvider>();

    final storeName = isGlobal
        ? (superAdminProvider.platformLocalization.name.get(context).isNotEmpty
            ? superAdminProvider.platformLocalization.name.get(context)
            : 'z-matajer')
        : selectedBusiness.localization.name.get(context);
    final storeSlogan = isGlobal
        ? (superAdminProvider.platformLocalization.slogan.get(context).isNotEmpty
            ? superAdminProvider.platformLocalization.slogan.get(context)
            : (isAr ? 'المنصة التجارية الشاملة للمتاجر والتسوق الإلكتروني' : 'Comprehensive e-commerce platform'))
        : selectedBusiness.localization.slogan.get(context);
    final storeDesc = isGlobal
        ? (superAdminProvider.platformLocalization.description.get(context).isNotEmpty
            ? superAdminProvider.platformLocalization.description.get(context)
            : (isAr ? 'نحن هنا لخدمتك ومساعدتك في أي استفسار أو دعم فني.' : 'We are here to help with any inquiry or technical support.'))
        : selectedBusiness.localization.description.get(context);
    final logoUrl = isGlobal
        ? superAdminProvider.platformTheme.logoUrl
        : selectedBusiness.theme.logoUrl;
    final primaryColor = theme.primaryColor;

    final visibleSocials = isGlobal
        ? superAdminProvider.platformSocials
            .where((s) => s.isVisible && s.url.trim().isNotEmpty)
            .toList()
        : selectedBusiness.socials
            .where((s) => s.isVisible && s.url.trim().isNotEmpty)
            .toList();
    final addresses = selectedBusiness.addAddress;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.contactUs.tr(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopTitle(
              title: TranslationKeys.contactUs.tr(context),
              paths: [
                TranslationKeys.home.tr(context),
                TranslationKeys.contactUs.tr(context),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: hPad),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 1. بطاقة تعريف البزنس العلوية
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.cardBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.12),
                              border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                            ),
                            child: ClipOval(
                              child: logoUrl != null && logoUrl.isNotEmpty
                                  ? CustomNetworkImage(
                                      imageUrl: logoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        Icons.storefront_rounded,
                                        size: 36,
                                        color: primaryColor,
                                      ),
                                    )
                                  : Icon(
                                      Icons.storefront_rounded,
                                      size: 36,
                                      color: primaryColor,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        storeName.isNotEmpty
                                            ? storeName
                                            : (isGlobal
                                                ? (isAr ? 'منصة Z-Ecommerce' : 'Z-Ecommerce Platform')
                                                : (isAr ? 'بيانات المتجر' : 'Store Details')),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: theme.textTheme.displayLarge?.color,
                                        ),
                                      ),
                                    ),
                                    if (selectedBusiness.isVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                                if (storeSlogan.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    storeSlogan,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                                if (storeDesc.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    storeDesc,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// 2. قنوات ووسائل التواصل المباشرة
                    Text(
                      isAr ? 'قنوات التواصل ووسائل التواصل الاجتماعي' : 'Contact & Social Channels',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (isGlobal) ...[
                      // في حالة عدم اختيار متجر: عرض بيانات المنصة العامة
                      _buildGlobalPlatformContacts(context, superAdminProvider, isAr),
                    ] else if (visibleSocials.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Center(
                          child: Text(
                            isAr
                                ? 'لم يتم إضافة قنوات تواصل بعد لهذا المتجر'
                                : 'No contact channels added yet for this store',
                            style: TextStyle(
                              fontSize: 15,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 850
                              ? 3
                              : (constraints.maxWidth > 550 ? 2 : 1);
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: visibleSocials.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              mainAxisExtent: 80,
                            ),
                            itemBuilder: (context, index) {
                              final social = visibleSocials[index];
                              final label = social.title.get(context).isNotEmpty
                                  ? social.title.get(context)
                                  : _getPlatformLabel(context, social.platform);
                              final icon = _getPlatformIcon(social.platform);
                              final color = _getPlatformColor(social.platform);

                              return _ContactActionTile(
                                icon: icon,
                                color: color,
                                title: label,
                                subtitle: social.url,
                                onTap: () => _openLink(social.url, social.platform),
                              );
                            },
                          );
                        },
                      ),
                    ],

                    /// 3. الفروع والعناوين الجغرافية
                    if (addresses.isNotEmpty) ...[
                      const SizedBox(height: 36),
                      Text(
                        isAr ? 'الفروع والعناوين' : 'Branches & Locations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: addresses.map((address) {
                          return _AddressCard(
                            address: address,
                            langCode: langCode,
                            primaryColor: primaryColor,
                          );
                        }).toList(),
                      ),
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

  Widget _buildGlobalPlatformContacts(
    BuildContext context,
    SuperAdminProvider superAdminProvider,
    bool isAr,
  ) {
    final email = superAdminProvider.platformSettings.email ?? 'support@z-matajer.com';
    final phone = superAdminProvider.platformSettings.phone ?? '+966 50 123 4567';
    final whatsapp = superAdminProvider.platformSettings.whatsapp ?? '+966 50 123 4567';

    return Column(
      children: [
        _ContactActionTile(
          icon: Icons.email_rounded,
          color: Colors.deepOrange,
          title: isAr ? 'البريد الإلكتروني' : 'Email Address',
          subtitle: email,
          onTap: () => _openLink('mailto:$email', SocialPlatform.contactEmail),
        ),
        const SizedBox(height: 12),
        _ContactActionTile(
          icon: Icons.phone_rounded,
          color: Colors.green,
          title: isAr ? 'رقم الهاتف' : 'Phone Number',
          subtitle: phone,
          onTap: () => _openLink('tel:$phone', SocialPlatform.contactPhoneFirst),
        ),
        const SizedBox(height: 12),
        _ContactActionTile(
          icon: Icons.chat_rounded,
          color: const Color(0xFF25D366),
          title: isAr ? 'واتساب الدعم' : 'Support WhatsApp',
          subtitle: whatsapp,
          onTap: () => _openLink(whatsapp, SocialPlatform.whatsapp),
        ),
      ],
    );
  }
}

/// بطاقة التفاعل والتواصل المباشر
class _ContactActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : AppColors.cardBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: theme.dividerColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة عرض العنوان والخريطة
class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final String langCode;
  final Color primaryColor;

  const _AddressCard({
    required this.address,
    required this.langCode,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final formatted = address.getFormattedAddress(langCode: langCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : AppColors.cardBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.location_on_rounded, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address.title.isNotEmpty) ...[
                  Text(
                    address.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  formatted.isNotEmpty ? formatted : 'العنوان غير محدد',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (address.latitude != null && address.longitude != null)
            IconButton(
              icon: Icon(Icons.map_rounded, color: primaryColor),
              tooltip: 'عرض على الخريطة',
              onPressed: () {
                final url =
                    'https://www.google.com/maps/search/?api=1&query=${address.latitude},${address.longitude}';
                try {
                  html.window.open(url, '_blank');
                } catch (_) {
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
    );
  }
}
