import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/category_model.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

class StoreCreateEditCategoryPage extends StatefulWidget {
  final String? businessId;
  final CategoryModel? category;
  final bool isSuperAdmin;

  const StoreCreateEditCategoryPage({
    super.key,
    this.businessId,
    this.category,
    this.isSuperAdmin = false,
  });

  @override
  State<StoreCreateEditCategoryPage> createState() =>
      _StoreCreateEditCategoryPageState();
}

class _StoreCreateEditCategoryPageState
    extends State<StoreCreateEditCategoryPage> {
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

  CategoryModel? _existingCategory;

  @override
  void initState() {
    super.initState();
    final c = widget.category;

    _labelController = TextEditingController(text: c?.label ?? '');
    _selectedColor = c?.bgColor ?? _colorOptions.first;
    _selectedIcon = c?.icon ?? Icons.category_rounded;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().listenToAllCategories();
    });
    _labelController.addListener(_checkDuplicate);
  }

  void _checkDuplicate() {
    final text = _labelController.text.trim().toLowerCase();
    if (text.isEmpty) {
      if (_existingCategory != null) setState(() => _existingCategory = null);
      return;
    }
    final allCats = context.read<CategoryProvider>().categories;
    final match = allCats.cast<CategoryModel?>().firstWhere(
      (c) => c != null && c.id != widget.category?.id && c.label.trim().toLowerCase() == text,
      orElse: () => null,
    );
    if (match != _existingCategory) {
      setState(() => _existingCategory = match);
    }
  }

  @override
  void dispose() {
    _labelController.removeListener(_checkDuplicate);
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<CategoryProvider>();
    final isEdit = widget.category != null;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final catId = isEdit
        ? widget.category!.id
        : 'cat_${timestamp.substring(timestamp.length - 6)}';

    final updatedCategory = CategoryModel(
      id: catId,
      businessIds: widget.isSuperAdmin
          ? (widget.category?.businessIds ?? [])
          : (widget.businessId != null ? [widget.businessId!] : []),
      label: _labelController.text.trim(),
      bgColor: _selectedColor,
      icon: _selectedIcon,
      isGlobal: widget.isSuperAdmin,
    );

    bool success = false;
    if (isEdit) {
      success = await provider.updateCategory(updatedCategory);
    } else {
      success = await provider.addCategory(updatedCategory);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'تم تحديث الفئة بنجاح!'
                  : 'تم إضافة الفئة الجديدة بنجاح!',
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
    final isEdit = widget.category != null;
    final appBarTitle = widget.isSuperAdmin
        ? (isEdit ? 'تعديل الفئة العامة' : 'إضافة فئة عامة جديدة للمنصة')
        : (isEdit ? 'تعديل فئة' : 'إضافة فئة جديدة للمتجر');

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label Field
                  TextFormField(
                    controller: _labelController,
                    decoration: InputDecoration(
                      labelText: 'اسم الفئة (عربي/إنجليزي)',
                      hintText: 'مثال: إلكترونيات، أزياء...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.label_outline_rounded),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'يرجى إدخال اسم الفئة';
                      }
                      return null;
                    },
                  ),
                  if (_existingCategory != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تنبيه: الفئة "${_existingCategory!.label}" موجودة بالفعل في قاعدة البيانات.',
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          if (widget.businessId != null &&
                              _existingCategory!.businessIds.contains(widget.businessId))
                            const Text(
                              'هذه الفئة مضافة ومفعلة لمتجرك بالفعل.',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            )
                          else if (widget.businessId != null) ...[
                            const Text(
                              'يمكنك تفعيلها وإضافتها لمتجرك مباشرة لتوفير البيانات.',
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                            const SizedBox(height: 6),
                            TextButton.icon(
                              icon: const Icon(Icons.add_task_rounded),
                              label: const Text('تفعيل وإضافة هذه الفئة لمتجري مباشرة'),
                              onPressed: () async {
                                setState(() => _isSubmitting = true);
                                final updatedList = List<String>.from(_existingCategory!.businessIds)..add(widget.businessId!);
                                final updated = _existingCategory!.copyWith(businessIds: updatedList);
                                final success = await context.read<CategoryProvider>().updateCategory(updated);
                                setState(() => _isSubmitting = false);
                                if (mounted && success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم تفعيل وإضافة الفئة لمتجرك بنجاح!')),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Colors
                  const Text(
                    'لون الفئة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _colorOptions.map((color) {
                      final isSelected = color.value == _selectedColor.value;
                      return InkWell(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(context).primaryColor,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Icons
                  const Text(
                    'أيقونة الفئة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _iconOptions.map((icon) {
                      final isSelected = icon == _selectedIcon;
                      return InkWell(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                : Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ButtonApp(
                      onPressed: _isSubmitting ? null : _submit,
                      isLoading: _isSubmitting,
                      label: isEdit ? 'حفظ التعديلات' : 'إضافة الفئة',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
