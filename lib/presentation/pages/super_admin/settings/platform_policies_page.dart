import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class PlatformPoliciesPage extends StatefulWidget {
  const PlatformPoliciesPage({super.key});

  @override
  State<PlatformPoliciesPage> createState() => _PlatformPoliciesPageState();
}

class _PlatformPoliciesPageState extends State<PlatformPoliciesPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _termsArController;
  late TextEditingController _termsEnController;
  late TextEditingController _privacyArController;
  late TextEditingController _privacyEnController;
  late TextEditingController _aboutArController;
  late TextEditingController _aboutEnController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SuperAdminProvider>();
    final loc = provider.platformLocalization;
    final settings = provider.platformSettings;

    final termsAr = loc.termsAndConditions.ar.isNotEmpty
        ? loc.termsAndConditions.ar
        : settings.termsContent.ar;
    final termsEn = loc.termsAndConditions.en.isNotEmpty
        ? loc.termsAndConditions.en
        : settings.termsContent.en;

    final privacyAr = loc.privacyPolicy.ar.isNotEmpty
        ? loc.privacyPolicy.ar
        : settings.privacyContent.ar;
    final privacyEn = loc.privacyPolicy.en.isNotEmpty
        ? loc.privacyPolicy.en
        : settings.privacyContent.en;

    final aboutAr = loc.aboutUs.ar.isNotEmpty
        ? loc.aboutUs.ar
        : settings.aboutUsContent.ar;
    final aboutEn = loc.aboutUs.en.isNotEmpty
        ? loc.aboutUs.en
        : settings.aboutUsContent.en;

    _termsArController = TextEditingController(text: termsAr);
    _termsEnController = TextEditingController(text: termsEn);
    _privacyArController = TextEditingController(text: privacyAr);
    _privacyEnController = TextEditingController(text: privacyEn);
    _aboutArController = TextEditingController(text: aboutAr);
    _aboutEnController = TextEditingController(text: aboutEn);
  }

  @override
  void dispose() {
    _termsArController.dispose();
    _termsEnController.dispose();
    _privacyArController.dispose();
    _privacyEnController.dispose();
    _aboutArController.dispose();
    _aboutEnController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<SuperAdminProvider>();
      final currentLoc = provider.platformLocalization;

      final termsLoc = LocalizedString(
        ar: _termsArController.text.trim(),
        en: _termsEnController.text.trim(),
      );
      final privacyLoc = LocalizedString(
        ar: _privacyArController.text.trim(),
        en: _privacyEnController.text.trim(),
      );
      final aboutLoc = LocalizedString(
        ar: _aboutArController.text.trim(),
        en: _aboutEnController.text.trim(),
      );

      final updatedLoc = currentLoc.copyWith(
        termsAndConditions: termsLoc,
        privacyPolicy: privacyLoc,
        aboutUs: aboutLoc,
      );

      final updatedSettings = provider.platformSettings.copyWith(
        termsContent: termsLoc,
        privacyContent: privacyLoc,
        aboutUsContent: aboutLoc,
      );

      await provider.updatePlatformLocalization(updatedLoc);
      await provider.updatePlatformSettings(updatedSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.gavel_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('تم حفظ الشروط والسياسات وصفحة من نحن بنجاح!'),
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
      title: 'الصفحات الثابتة والشروط والسياسات',
      subtitle: 'تعديل نصوص الشروط والأحكام، سياسة الخصوصية، وصفحة من نحن للمنصة العامة.',
      isEditMode: true,
      formKey: _formKey,
      isSubmitting: _isSubmitting,
      submitLabel: 'حفظ السياسات والصفحات',
      onSubmit: _handleSubmit,
      sections: [
        FormSection(
          title: 'صفحة من نحن (About Us)',
          subtitle: 'النص التفصيلي التعريفي بنشاط المنصة ورؤيتها',
          icon: Icons.info_outline_rounded,
          fields: [
            TextFormField(
              controller: _aboutArController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'نص صفحة من نحن (بالعربية)',
                hintText: 'اكتب نبذة شاملة عن المنصة ورؤيتها وأهدافها...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aboutEnController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'نص صفحة من نحن (بالإنجليزية)',
                hintText: 'Write comprehensive overview about the platform...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        FormSection(
          title: 'الشروط والأحكام (Terms & Conditions)',
          subtitle: 'البنود القانونية واتفاقية الاستخدام للعملاء والتجار',
          icon: Icons.gavel_rounded,
          fields: [
            TextFormField(
              controller: _termsArController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'نص الشروط والأحكام (بالعربية)',
                hintText: 'أدخل بنود الشروط والأحكام وقواعد الاستخدام...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _termsEnController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'نص الشروط والأحكام (بالإنجليزية)',
                hintText: 'Enter the terms, conditions, and usage policies...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        FormSection(
          title: 'سياسة الخصوصية (Privacy Policy)',
          subtitle: 'سياسة معالجة وحماية بيانات المستخدمين والمتاجر',
          icon: Icons.privacy_tip_rounded,
          fields: [
            TextFormField(
              controller: _privacyArController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'نص سياسة الخصوصية (بالعربية)',
                hintText: 'أدخل سياسة الخصوصية وحماية البيانات...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _privacyEnController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'نص سياسة الخصوصية (بالإنجليزية)',
                hintText: 'Enter the privacy policy and data security details...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
