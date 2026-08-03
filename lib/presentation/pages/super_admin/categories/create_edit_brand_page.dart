import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/brand_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class CreateEditBrandPage extends StatefulWidget {
  final BrandModel? brand;

  const CreateEditBrandPage({super.key, this.brand});

  @override
  State<CreateEditBrandPage> createState() => _CreateEditBrandPageState();
}

class _CreateEditBrandPageState extends State<CreateEditBrandPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _logoUrlController;
  late TextEditingController _descriptionController;
  
  String? _selectedBusinessId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final b = widget.brand;

    _nameController = TextEditingController(text: b?.name ?? '');
    _logoUrlController = TextEditingController(text: b?.logoUrl ?? '');
    _descriptionController = TextEditingController(text: b?.description ?? '');
    _selectedBusinessId = b?.businessId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logoUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<BrandProvider>();
    final isEdit = widget.brand != null;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final brandId = isEdit
        ? widget.brand!.id
        : 'br_${timestamp.substring(timestamp.length - 6)}';

    final updatedBrand = BrandModel(
      id: brandId,
      businessId: _selectedBusinessId,
      name: _nameController.text.trim(),
      logoUrl: _logoUrlController.text.trim().isEmpty ? null : _logoUrlController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    bool success = false;
    if (isEdit) {
      success = await provider.updateBrand(updatedBrand);
    } else {
      success = await provider.addBrand(updatedBrand);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'تم تحديث العلامة التجارية بنجاح!'
                  : 'تم إضافة العلامة التجارية بنجاح!',
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'حدث خطأ، يرجى المحاولة.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.brand != null;
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final businesses = businessProvider.businesses;

    return AddEditTemplate(
      title: isEdit ? 'تعديل علامة تجارية' : 'إضافة علامة تجارية جديدة',
      subtitle: isEdit ? 'تعديل بيانات العلامة التجارية الحالية' : 'إدخال بيانات واسم وشعار العلامة التجارية',
      isEditMode: isEdit,
      formKey: _formKey,
      submitLabel: isEdit ? TranslationKeys.saveChanges.tr(context) : 'إضافة علامة تجارية',
      submitIcon: isEdit ? Icons.save_rounded : Icons.add_circle_outline_rounded,
      onSubmit: _submit,
      isSubmitting: _isSubmitting,
      cancelLabel: TranslationKeys.cancel.tr(context),
      sections: [
        FormSection(
          title: 'البيانات الأساسية للعلامة',
          subtitle: 'اسم وشعار ووصف العلامة التجارية',
          icon: Icons.branding_watermark_rounded,
          fields: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم العلامة التجارية',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.branding_watermark_outlined, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _logoUrlController,
              decoration: const InputDecoration(
                labelText: 'رابط الشعار (Logo URL)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'وصف العلامة التجارية (اختياري)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined, size: 20),
              ),
            ),
          ],
        ),
        FormSection(
          title: 'تبعية العلامة التجارية',
          subtitle: 'حدد ما إذا كانت العلامة للمنصة ككل أم لمتجر معين',
          icon: Icons.storefront_rounded,
          fields: [
            DropdownButtonFormField<String?>(
              value: _selectedBusinessId,
              decoration: const InputDecoration(
                labelText: 'الجهة المالكة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business_center_rounded, size: 20),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('المنصة الرئيسية (Global)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...businesses.map((BusinessModel b) {
                  return DropdownMenuItem<String?>(
                    value: b.id,
                    child: Text('متجر: ${b.localization.name.get(context)}'),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedBusinessId = val;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
