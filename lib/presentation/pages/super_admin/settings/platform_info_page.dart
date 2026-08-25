import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class PlatformInfoPage extends StatefulWidget {
  const PlatformInfoPage({super.key});

  @override
  State<PlatformInfoPage> createState() => _PlatformInfoPageState();
}

class _PlatformInfoPageState extends State<PlatformInfoPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _sloganArController;
  late TextEditingController _sloganEnController;
  late TextEditingController _descArController;
  late TextEditingController _descEnController;
  late TextEditingController _footerArController;
  late TextEditingController _footerEnController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final loc = context.read<SuperAdminProvider>().platformLocalization;
    _nameArController = TextEditingController(text: loc.name.ar);
    _nameEnController = TextEditingController(text: loc.name.en);
    _sloganArController = TextEditingController(text: loc.slogan.ar);
    _sloganEnController = TextEditingController(text: loc.slogan.en);
    _descArController = TextEditingController(text: loc.description.ar);
    _descEnController = TextEditingController(text: loc.description.en);
    _footerArController = TextEditingController(text: loc.footerDescription.ar);
    _footerEnController = TextEditingController(text: loc.footerDescription.en);
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _sloganArController.dispose();
    _sloganEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _footerArController.dispose();
    _footerEnController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final currentLoc = context.read<SuperAdminProvider>().platformLocalization;
      final updatedLoc = currentLoc.copyWith(
        name: LocalizedString(
          ar: _nameArController.text.trim(),
          en: _nameEnController.text.trim().isNotEmpty
              ? _nameEnController.text.trim()
              : _nameArController.text.trim(),
        ),
        slogan: LocalizedString(
          ar: _sloganArController.text.trim(),
          en: _sloganEnController.text.trim(),
        ),
        description: LocalizedString(
          ar: _descArController.text.trim(),
          en: _descEnController.text.trim(),
        ),
        footerDescription: LocalizedString(
          ar: _footerArController.text.trim(),
          en: _footerEnController.text.trim(),
        ),
      );

      await context.read<SuperAdminProvider>().updatePlatformLocalization(updatedLoc);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('تم حفظ معلومات ونصوص المنصة بنجاح!'),
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
      title: 'معلومات ونصوص المنصة',
      subtitle: 'تعديل اسم المنصة الرسمي، الشعار اللفظي، ووصف الواجهة العامة والفوتر.',
      isEditMode: true,
      formKey: _formKey,
      isSubmitting: _isSubmitting,
      submitLabel: 'حفظ التعديلات',
      onSubmit: _handleSubmit,
      sections: [
        FormSection(
          title: 'الاسم الرسمي للمنصة (Platform Name)',
          subtitle: 'يظهر في أعلى الهيدر وعنوان التطبيق والصفحات العامة',
          icon: Icons.storefront_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _nameArController,
                    label: 'اسم المنصة (بالعربية)',
                    hintText: 'زد للمتاجر',
                    prefixIcon: Icons.edit_note_rounded,
                    validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال الاسم بالعربية' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AuthTextField(
                    controller: _nameEnController,
                    label: 'اسم المنصة (بالإنجليزية)',
                    hintText: 'Z-Matajer',
                    prefixIcon: Icons.edit_note_rounded,
                    validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال الاسم بالإنجليزية' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
        FormSection(
          title: 'الشعار الترويجي (Slogan)',
          subtitle: 'العبارة الترويجية الرئيسية التي تظهر في واجهة دليل المتاجر',
          icon: Icons.auto_awesome_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _sloganArController,
                    label: 'الشعار الترويجي (بالعربية)',
                    hintText: 'منصتك الشاملة لأفضل المتاجر',
                    prefixIcon: Icons.auto_awesome_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AuthTextField(
                    controller: _sloganEnController,
                    label: 'الشعار الترويجي (بالإنجليزية)',
                    hintText: 'Your All-in-One Platform',
                    prefixIcon: Icons.auto_awesome_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
        FormSection(
          title: 'وصف المنصة والفوتر',
          subtitle: 'النصوص التوضيحية لتعريف الزوار بخدمات المنصة',
          icon: Icons.description_rounded,
          fields: [
            AuthTextField(
              controller: _descArController,
              label: 'وصف المنصة العام (بالعربية)',
              hintText: 'وجهتك الأولى لتسوق أفضل المنتجات واكتشاف المتاجر الرائدة...',
              prefixIcon: Icons.notes_rounded,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _descEnController,
              label: 'وصف المنصة العام (بالإنجليزية)',
              hintText: 'Your premier destination for leading stores and top products...',
              prefixIcon: Icons.notes_rounded,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _footerArController,
                    label: 'نص الفوتر (بالعربية)',
                    hintText: 'منظومة تجارة إلكترونية متطورة تربط المتاجر بالعملاء.',
                    prefixIcon: Icons.info_outline_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AuthTextField(
                    controller: _footerEnController,
                    label: 'نص الفوتر (بالإنجليزية)',
                    hintText: 'Advanced e-commerce ecosystem connecting stores.',
                    prefixIcon: Icons.info_outline_rounded,
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
