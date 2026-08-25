import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class PlatformSocialsPage extends StatefulWidget {
  const PlatformSocialsPage({super.key});

  @override
  State<PlatformSocialsPage> createState() => _PlatformSocialsPageState();
}

class _PlatformSocialsPageState extends State<PlatformSocialsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;

  late TextEditingController _socialWhatsappController;
  late TextEditingController _instagramController;
  late TextEditingController _facebookController;
  late TextEditingController _linkedinController;
  late TextEditingController _twitterController;
  late TextEditingController _tiktokController;
  late TextEditingController _youtubeController;
  late TextEditingController _websiteController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SuperAdminProvider>();
    final settings = provider.platformSettings;
    final socials = provider.platformSocials;

    _phoneController = TextEditingController(text: settings.phone ?? '');
    _whatsappController = TextEditingController(text: settings.whatsapp ?? '');
    _emailController = TextEditingController(text: settings.email ?? '');

    String getUrl(SocialPlatform plat) {
      final match = socials.where((s) => s.platform == plat);
      return match.isNotEmpty ? match.first.url : '';
    }

    _socialWhatsappController = TextEditingController(text: getUrl(SocialPlatform.whatsapp));
    _instagramController = TextEditingController(text: getUrl(SocialPlatform.instagram));
    _facebookController = TextEditingController(text: getUrl(SocialPlatform.facebook));
    _linkedinController = TextEditingController(text: getUrl(SocialPlatform.linkedin));
    _twitterController = TextEditingController(text: getUrl(SocialPlatform.twitter));
    _tiktokController = TextEditingController(text: getUrl(SocialPlatform.tiktok));
    _youtubeController = TextEditingController(text: getUrl(SocialPlatform.youtube));
    _websiteController = TextEditingController(text: getUrl(SocialPlatform.website));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _socialWhatsappController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _tiktokController.dispose();
    _youtubeController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<SuperAdminProvider>();

      // 1. Update PlatformSettings contacts
      final updatedSettings = provider.platformSettings.copyWith(
        phone: _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        email: _emailController.text.trim(),
      );
      await provider.updatePlatformSettings(updatedSettings);

      // 2. Update PlatformSocials list
      final updatedSocials = [
        SocialModel(
          title: const LocalizedString(ar: 'واتساب', en: 'WhatsApp'),
          icon: 'whatsapp',
          color: const Color(0xFF25D366),
          platform: SocialPlatform.whatsapp,
          url: _socialWhatsappController.text.trim(),
          isVisible: _socialWhatsappController.text.trim().isNotEmpty,
        ),
        SocialModel(
          title: const LocalizedString(ar: 'إنستغرام', en: 'Instagram'),
          icon: 'instagram',
          color: const Color(0xFFE4405F),
          platform: SocialPlatform.instagram,
          url: _instagramController.text.trim(),
          isVisible: _instagramController.text.trim().isNotEmpty,
        ),
        SocialModel(
          title: const LocalizedString(ar: 'فيسبوك', en: 'Facebook'),
          icon: 'facebook',
          color: const Color(0xFF1877F2),
          platform: SocialPlatform.facebook,
          url: _facebookController.text.trim(),
          isVisible: _facebookController.text.trim().isNotEmpty,
        ),
        SocialModel(
          title: const LocalizedString(ar: 'لينكد إن', en: 'LinkedIn'),
          icon: 'linkedin',
          color: const Color(0xFF0A66C2),
          platform: SocialPlatform.linkedin,
          url: _linkedinController.text.trim(),
          isVisible: _linkedinController.text.trim().isNotEmpty,
        ),
        SocialModel(
          title: const LocalizedString(ar: 'تويتر / X', en: 'Twitter / X'),
          icon: 'twitter',
          color: Colors.black,
          platform: SocialPlatform.twitter,
          url: _twitterController.text.trim(),
          isVisible: _twitterController.text.trim().isNotEmpty,
        ),
        SocialModel(
          title: const LocalizedString(ar: 'تيك توك', en: 'TikTok'),
          icon: 'tiktok',
          color: Colors.black,
          platform: SocialPlatform.tiktok,
          url: _tiktokController.text.trim(),
          isVisible: _tiktokController.text.trim().isNotEmpty,
        ),
        SocialModel(
          title: const LocalizedString(ar: 'يوتيوب', en: 'YouTube'),
          icon: 'youtube',
          color: const Color(0xFFFF0000),
          platform: SocialPlatform.youtube,
          url: _youtubeController.text.trim(),
          isVisible: _youtubeController.text.trim().isNotEmpty,
        ),
        SocialModel(
          title: const LocalizedString(ar: 'الموقع الإلكتروني', en: 'Website'),
          icon: 'website',
          color: Colors.indigo,
          platform: SocialPlatform.website,
          url: _websiteController.text.trim(),
          isVisible: _websiteController.text.trim().isNotEmpty,
        ),
      ];

      await provider.updatePlatformSocials(updatedSocials);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.contact_phone_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('تم حفظ قنوات التواصل والدعم الفني للمنصة بنجاح!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحفظ: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddEditTemplate(
      title: 'وسائل التواصل والدعم الفني',
      subtitle: 'إدارة أرقام وقنوات التواصل الرسمي والدعم الفني لزوار المنصة وأصحاب المتاجر.',
      isEditMode: true,
      formKey: _formKey,
      isSubmitting: _isSubmitting,
      submitLabel: 'حفظ بيانات التواصل',
      onSubmit: _handleSubmit,
      sections: [
        FormSection(
          title: 'قنوات الدعم الفني الرسمية',
          subtitle: 'تظهر في صفحة تواصل معنا والفوتر',
          icon: Icons.support_agent_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _phoneController,
                    label: 'رقم هاتف الدعم الفني',
                    hintText: '+966 50 123 4567',
                    prefixIcon: Icons.phone_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AuthTextField(
                    controller: _whatsappController,
                    label: 'رقم واتساب الدعم المباشر',
                    hintText: '+966 50 123 4567',
                    prefixIcon: Icons.chat_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني للدعم الفني',
              hintText: 'support@zmatajer.com',
              prefixIcon: Icons.email_rounded,
            ),
          ],
        ),
        FormSection(
          title: 'حسابات التواصل الاجتماعي الرسمية للمنصة',
          subtitle: 'روابط حسابات المنصة على منصات التواصل',
          icon: Icons.share_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _socialWhatsappController,
                    label: 'رابط واتساب المنصة',
                    hintText: 'https://wa.me/...',
                    prefixIcon: Icons.link_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AuthTextField(
                    controller: _instagramController,
                    label: 'رابط إنستغرام',
                    hintText: 'https://instagram.com/...',
                    prefixIcon: Icons.link_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _facebookController,
                    label: 'رابط فيسبوك',
                    hintText: 'https://facebook.com/...',
                    prefixIcon: Icons.link_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AuthTextField(
                    controller: _linkedinController,
                    label: 'رابط لينكد إن',
                    hintText: 'https://linkedin.com/...',
                    prefixIcon: Icons.link_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _twitterController,
                    label: 'رابط تويتر / X',
                    hintText: 'https://x.com/...',
                    prefixIcon: Icons.link_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AuthTextField(
                    controller: _tiktokController,
                    label: 'رابط تيك توك',
                    hintText: 'https://tiktok.com/...',
                    prefixIcon: Icons.link_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _youtubeController,
                    label: 'رابط قناة يوتيوب',
                    hintText: 'https://youtube.com/...',
                    prefixIcon: Icons.link_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AuthTextField(
                    controller: _websiteController,
                    label: 'رابط الموقع الرسمي',
                    hintText: 'https://zmatajer.com',
                    prefixIcon: Icons.link_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
