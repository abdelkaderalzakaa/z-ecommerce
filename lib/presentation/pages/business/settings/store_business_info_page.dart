import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class StoreBusinessInfoPage extends StatefulWidget {
  const StoreBusinessInfoPage({super.key});

  @override
  State<StoreBusinessInfoPage> createState() => _StoreBusinessInfoPageState();
}

class _StoreBusinessInfoPageState extends State<StoreBusinessInfoPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _sloganArController;
  late TextEditingController _sloganEnController;
  late TextEditingController _descriptionArController;
  late TextEditingController _descriptionEnController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final business = context.read<BusinessProvider>().selectedBusiness;
    _nameArController = TextEditingController(text: business.localization.name.ar);
    _nameEnController = TextEditingController(text: business.localization.name.en);
    _sloganArController = TextEditingController(text: business.localization.slogan.ar);
    _sloganEnController = TextEditingController(text: business.localization.slogan.en);
    _descriptionArController = TextEditingController(text: business.localization.description.ar);
    _descriptionEnController = TextEditingController(text: business.localization.description.en);
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _sloganArController.dispose();
    _sloganEnController.dispose();
    _descriptionArController.dispose();
    _descriptionEnController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final business = context.read<BusinessProvider>().selectedBusiness;
    if (business.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ: لم يتم تحديد المتجر'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final updatedLocalization = business.localization.copyWith(
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
          ar: _descriptionArController.text.trim(),
          en: _descriptionEnController.text.trim(),
        ),
      );

      await context.read<BusinessProvider>().updateLocalization(
            business.id,
            updatedLocalization,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ وتحديث بيانات المتجر بنجاح!'),
            backgroundColor: Colors.green,
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
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddEditTemplate(
      title: 'معلومات المتجر',
      subtitle: 'تعديل البيانات الأساسية والنصوص الخاصة بالمتجر',
      isEditMode: true,
      formKey: _formKey,
      submitLabel: TranslationKeys.saveChanges.tr(context),
      submitIcon: Icons.save_rounded,
      onSubmit: _submit,
      isSubmitting: _isSubmitting,
      cancelLabel: TranslationKeys.cancel.tr(context),
      sections: [
        FormSection(
          title: TranslationKeys.storeInformation.tr(context),
          subtitle: TranslationKeys.storeInfoSubtitle.tr(context),
          icon: Icons.storefront_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameArController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.storeNameAr.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.language, size: 20),
                    ),
                    validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _nameEnController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.storeNameEn.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.language, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sloganArController,
                    decoration: InputDecoration(
                      labelText: '${TranslationKeys.storeSlogan.tr(context)} (عربي)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.format_quote_rounded, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sloganEnController,
                    decoration: InputDecoration(
                      labelText: '${TranslationKeys.storeSlogan.tr(context)} (English)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.format_quote_rounded, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionArController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '${TranslationKeys.storeDescription.tr(context)} (عربي)',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionEnController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '${TranslationKeys.storeDescription.tr(context)} (English)',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
