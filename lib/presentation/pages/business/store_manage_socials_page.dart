import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class StoreManageSocialsPage extends StatefulWidget {
  final BusinessModel store;

  const StoreManageSocialsPage({super.key, required this.store});

  @override
  State<StoreManageSocialsPage> createState() => _StoreManageSocialsPageState();
}

class _StoreManageSocialsPageState extends State<StoreManageSocialsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _whatsappCtrl;
  late TextEditingController _instagramCtrl;
  late TextEditingController _facebookCtrl;
  late TextEditingController _tiktokCtrl;
  late TextEditingController _twitterCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _websiteCtrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final socials = widget.store.socials;

    String getUrl(SocialPlatform platform) {
      for (final s in socials) {
        if (s.platform == platform) {
          return s.url;
        }
      }
      return '';
    }

    _whatsappCtrl = TextEditingController(text: getUrl(SocialPlatform.whatsapp));
    _instagramCtrl = TextEditingController(text: getUrl(SocialPlatform.instagram));
    _facebookCtrl = TextEditingController(text: getUrl(SocialPlatform.facebook));
    _tiktokCtrl = TextEditingController(text: getUrl(SocialPlatform.tiktok));
    _twitterCtrl = TextEditingController(text: getUrl(SocialPlatform.twitter));
    _phoneCtrl = TextEditingController(text: getUrl(SocialPlatform.contactPhoneFirst).isNotEmpty ? getUrl(SocialPlatform.contactPhoneFirst) : (widget.store.ownerPhone ?? ''));
    _emailCtrl = TextEditingController(text: getUrl(SocialPlatform.contactEmail).isNotEmpty ? getUrl(SocialPlatform.contactEmail) : (widget.store.ownerEmail ?? ''));
    _websiteCtrl = TextEditingController(text: getUrl(SocialPlatform.website));
  }

  @override
  void dispose() {
    _whatsappCtrl.dispose();
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _tiktokCtrl.dispose();
    _twitterCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSocials() async {
    setState(() => _isSubmitting = true);

    final provider = context.read<BusinessProvider>();
    final currentStore = provider.businesses.firstWhere(
      (b) => b.id == widget.store.id,
      orElse: () => widget.store,
    );

    final List<SocialModel> newSocials = [];

    void addIfNotEmpty(SocialPlatform platform, String titleAr, String titleEn, String url, Color color) {
      if (url.trim().isNotEmpty) {
        newSocials.add(
          SocialModel(
            title: LocalizedString(ar: titleAr, en: titleEn),
            url: url.trim(),
            icon: platform.name,
            color: color,
            platform: platform,
            isVisible: true,
          ),
        );
      }
    }

    addIfNotEmpty(SocialPlatform.whatsapp, 'واتساب الرسمي', 'Official WhatsApp', _whatsappCtrl.text, const Color(0xFF25D366));
    addIfNotEmpty(SocialPlatform.instagram, 'إنستغرام', 'Instagram', _instagramCtrl.text, const Color(0xFFE4405F));
    addIfNotEmpty(SocialPlatform.facebook, 'فيسبوك', 'Facebook', _facebookCtrl.text, const Color(0xFF1877F2));
    addIfNotEmpty(SocialPlatform.tiktok, 'تيك توك', 'TikTok', _tiktokCtrl.text, const Color(0xFF000000));
    addIfNotEmpty(SocialPlatform.twitter, 'تويتر / X', 'Twitter / X', _twitterCtrl.text, const Color(0xFF1DA1F2));
    addIfNotEmpty(SocialPlatform.contactPhoneFirst, 'الاتصال المباشر', 'Direct Phone', _phoneCtrl.text, Colors.blue);
    addIfNotEmpty(SocialPlatform.contactEmail, 'البريد الإلكتروني', 'Contact Email', _emailCtrl.text, Colors.deepOrange);
    addIfNotEmpty(SocialPlatform.website, 'الموقع الإلكتروني', 'Website', _websiteCtrl.text, Colors.deepPurple);

    final updatedStore = currentStore.copyWith(socials: newSocials);
    await provider.saveBusiness(updatedStore);

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ وتحديث وسائل وقنوات التواصل بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final businessProvider = context.watch<BusinessProvider>();
    final currentStore = businessProvider.businesses.firstWhere(
      (b) => b.id == widget.store.id,
      orElse: () => widget.store,
    );

    return AddEditTemplate(
      title: isAr ? 'إدارة وتعديل وسائل وقنوات التواصل' : 'Manage Store Social Channels',
      subtitle: isAr ? 'إضافة وتعديل روابط التواصل لـ (${currentStore.localization.name.get(context)})' : 'Manage official store links',
      formKey: _formKey,
      isSubmitting: _isSubmitting,
      isEditMode: true,
      submitLabel: isAr ? 'حفظ وتطبيق وسائل التواصل' : 'Save Social Channels',
      onSubmit: _saveSocials,
      sections: [
        FormSection(
          title: isAr ? 'روابط وقنوات التواصل المعتمدة للمتجر' : 'Store Official Social Media Links',
          icon: Icons.share_rounded,
          fields: [
            AuthTextField(
              controller: _whatsappCtrl,
              label: isAr ? 'رقم الواتساب الرسمي' : 'Official WhatsApp',
              hintText: isAr ? 'مثال: +9647700000000' : 'e.g. +9647700000000',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _instagramCtrl,
              label: isAr ? 'رابط حساب الإنستغرام' : 'Instagram Link / Handle',
              hintText: isAr ? 'مثال: instagram.com/store_name' : 'Instagram URL',
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _facebookCtrl,
              label: isAr ? 'رابط صفحة الفيسبوك' : 'Facebook Page Link',
              hintText: isAr ? 'مثال: facebook.com/store_page' : 'Facebook URL',
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _tiktokCtrl,
              label: isAr ? 'رابط حساب التيك توك' : 'TikTok Account Link',
              hintText: isAr ? 'مثال: tiktok.com/@store_user' : 'TikTok URL',
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _twitterCtrl,
              label: isAr ? 'رابط حساب تويتر / X' : 'Twitter / X Account',
              hintText: isAr ? 'مثال: x.com/store_user' : 'Twitter URL',
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _phoneCtrl,
              label: isAr ? 'رقم هاتف الاتصال المباشر' : 'Direct Contact Phone',
              hintText: isAr ? 'مثال: +964 770 000 0000' : 'Phone number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _emailCtrl,
              label: isAr ? 'البريد الإلكتروني للعمل' : 'Business Email',
              hintText: isAr ? 'مثال: store@domain.com' : 'Email address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _websiteCtrl,
              label: isAr ? 'رابط الموقع الإلكتروني الرسمي' : 'Official Website',
              hintText: isAr ? 'مثال: https://mystore.com' : 'Website URL',
            ),
          ],
        ),
      ],
    );
  }
}
