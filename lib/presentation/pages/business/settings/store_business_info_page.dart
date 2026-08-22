import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
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
  late TextEditingController _sloganController;
  late TextEditingController _descriptionController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // In a real scenario, fetch these from BusinessModel via Provider
    _nameArController = TextEditingController(text: 'متجري التجاري');
    _nameEnController = TextEditingController(text: 'My Commercial Store');
    _sloganController = TextEditingController(text: 'أفخم التشكيلات المودرن');
    _descriptionController = TextEditingController(
      text: 'متجر متخصص بتقديم أحدث المنتجات بجودة عالية وأسعار منافسة',
    );
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _sloganController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ وتحديث بيانات المتجر بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
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
                    validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sloganController,
              decoration: InputDecoration(
                labelText: TranslationKeys.storeSlogan.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.format_quote_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: TranslationKeys.storeDescription.tr(context),
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
