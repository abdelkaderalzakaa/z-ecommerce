import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/category_model.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class CreateEditCategoryPage extends StatefulWidget {
  final CategoryModel? category;

  const CreateEditCategoryPage({super.key, this.category});

  @override
  State<CreateEditCategoryPage> createState() => _CreateEditCategoryPageState();
}

class _CreateEditCategoryPageState extends State<CreateEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _labelController;
  late Color _selectedColor;
  IconData _selectedIcon = Icons.category_rounded;
  bool _isSubmitting = false;

  final List<Color> _colorOptions = [
    const Color(0xFFF4EBD9),
    const Color(0xFFE8F5E9),
    const Color(0xFFE3F2FD),
    const Color(0xFFF3E5F5),
    const Color(0xFFFFF3E0),
    const Color(0xFFFFEBEE),
    const Color(0xFFE0F7FA),
    const Color(0xFFF1F8E9),
  ];

  final List<IconData> _iconOptions = [
    Icons.category_rounded,
    Icons.checkroom_rounded,
    Icons.smartphone_rounded,
    Icons.home_rounded,
    Icons.face_rounded,
    Icons.sports_soccer_rounded,
    Icons.auto_awesome_rounded,
    Icons.shopping_bag_rounded,
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.category;

    _labelController = TextEditingController(text: c?.label ?? '');
    _selectedColor = c?.bgColor ?? _colorOptions.first;
    _selectedIcon = c?.icon ?? Icons.category_rounded;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<CategoryProvider>();
    final isEdit = widget.category != null;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final catId = isEdit ? widget.category!.id : 'cat_${timestamp.substring(timestamp.length - 6)}';

    final updatedCategory = CategoryModel(
      id: catId,
      label: _labelController.text.trim(),
      bgColor: _selectedColor,
      icon: _selectedIcon,
    );

    if (isEdit) {
      final index = provider.categories.indexWhere((c) => c.id == catId);
      if (index != -1) {
        provider.categories[index] = updatedCategory;
      }
    } else {
      provider.categories.insert(0, updatedCategory);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'تم تحديث القسم بنجاح!' : 'تم إضافة القسم الجديد بنجاح!',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return AddEditTemplate(
      title: isEdit ? 'تعديل القسم' : TranslationKeys.addNewCategory.tr(context),
      subtitle: isEdit ? 'تعديل اسم ولون وأيقونة القسم الرئيسي' : 'إدخال بيانات واسم ولون القسم الهيكلي الجديد',
      isEditMode: isEdit,
      formKey: _formKey,
      submitLabel: isEdit ? TranslationKeys.saveChanges.tr(context) : TranslationKeys.addNewCategory.tr(context),
      submitIcon: isEdit ? Icons.save_rounded : Icons.add_circle_outline_rounded,
      onSubmit: _submit,
      isSubmitting: _isSubmitting,
      cancelLabel: TranslationKeys.cancel.tr(context),
      sections: [
        FormSection(
          title: TranslationKeys.categoryName.tr(context),
          subtitle: 'اسم وتصنيف القسم الهيكلي',
          icon: Icons.category_rounded,
          fields: [
            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: TranslationKeys.categoryName.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.label_outline_rounded, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
            const SizedBox(height: 16),
            const Text('لون خلفية كرت القسم:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorOptions.map((c) {
                final isSelected = _selectedColor == c;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 3 : 1.5,
                      ),
                    ),
                    child: isSelected ? Icon(Icons.check, size: 20, color: Theme.of(context).primaryColor) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('أيقونة القسم المعروضة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _iconOptions.map((iconData) {
                final isSelected = _selectedIcon == iconData;
                return FilterChip(
                  avatar: Icon(iconData, size: 18, color: isSelected ? Colors.white : Theme.of(context).primaryColor),
                  label: Icon(iconData, size: 16),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedIcon = iconData),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
