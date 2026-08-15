import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/brand_model.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

class StoreCreateEditBrandPage extends StatefulWidget {
  final String? businessId;
  final BrandModel? brand;
  final bool isSuperAdmin;

  const StoreCreateEditBrandPage({
    super.key,
    this.businessId,
    this.brand,
    this.isSuperAdmin = false,
  });

  @override
  State<StoreCreateEditBrandPage> createState() =>
      _StoreCreateEditBrandPageState();
}

class _StoreCreateEditBrandPageState extends State<StoreCreateEditBrandPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _logoUrlController;
  late TextEditingController _descriptionController;

  bool _isSubmitting = false;

  BrandModel? _existingBrand;

  @override
  void initState() {
    super.initState();
    final b = widget.brand;
    _nameController = TextEditingController(text: b?.name ?? '');
    _logoUrlController = TextEditingController(text: b?.logoUrl ?? '');
    _descriptionController = TextEditingController(text: b?.description ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandProvider>().listenToAllBrands();
    });
    _nameController.addListener(_checkDuplicate);
  }

  void _checkDuplicate() {
    final text = _nameController.text.trim().toLowerCase();
    if (text.isEmpty) {
      if (_existingBrand != null) setState(() => _existingBrand = null);
      return;
    }
    final allBrands = context.read<BrandProvider>().brands;
    final match = allBrands.cast<BrandModel?>().firstWhere(
      (b) => b != null && b.id != widget.brand?.id && b.name.trim().toLowerCase() == text,
      orElse: () => null,
    );
    if (match != _existingBrand) {
      setState(() => _existingBrand = match);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkDuplicate);
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
      businessIds: widget.isSuperAdmin
          ? (widget.brand?.businessIds ?? [])
          : (widget.businessId != null ? [widget.businessId!] : []),
      name: _nameController.text.trim(),
      logoUrl: _logoUrlController.text.trim().isEmpty ? null : _logoUrlController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      isGlobal: widget.isSuperAdmin,
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
    final appBarTitle = widget.isSuperAdmin
        ? (isEdit ? 'تعديل العلامة التجارية العامة' : 'إضافة علامة تجارية عامة جديدة')
        : (isEdit ? 'تعديل علامة تجارية' : 'إضافة علامة تجارية للمتجر');

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
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'اسم العلامة التجارية',
                      hintText: 'مثال: سامسونج، أديداس...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.branding_watermark_rounded),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'يرجى إدخال اسم العلامة التجارية';
                      }
                      return null;
                    },
                  ),
                  if (_existingBrand != null) ...[
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
                            'تنبيه: العلامة التجارية "${_existingBrand!.name}" موجودة بالفعل في قاعدة البيانات.',
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          if (widget.businessId != null &&
                              _existingBrand!.businessIds.contains(widget.businessId))
                            const Text(
                              'هذه العلامة التجارية مضافة ومفعلة لمتجرك بالفعل.',
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
                              label: const Text('تفعيل وإضافة هذه العلامة لمتجري مباشرة'),
                              onPressed: () async {
                                setState(() => _isSubmitting = true);
                                final updatedList = List<String>.from(_existingBrand!.businessIds)..add(widget.businessId!);
                                final updated = _existingBrand!.copyWith(businessIds: updatedList);
                                final success = await context.read<BrandProvider>().updateBrand(updated);
                                setState(() => _isSubmitting = false);
                                if (mounted && success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم تفعيل وإضافة العلامة لمتجرك بنجاح!')),
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

                  // Logo URL Field
                  TextFormField(
                    controller: _logoUrlController,
                    decoration: InputDecoration(
                      labelText: 'رابط الشعار (Logo URL)',
                      hintText: 'https://example.com/logo.png',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.image_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'الوصف (اختياري)',
                      hintText: 'وصف مختصر للعلامة التجارية...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ButtonApp(
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submit,
                      label: isEdit ? 'حفظ التعديلات' : 'إضافة العلامة',
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
