import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/brand_model.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

class StoreCreateEditBrandPage extends StatefulWidget {
  final String businessId;
  final BrandModel? brand;

  const StoreCreateEditBrandPage({
    super.key,
    required this.businessId,
    this.brand,
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

  @override
  void initState() {
    super.initState();
    final b = widget.brand;
    _nameController = TextEditingController(text: b?.name ?? '');
    _logoUrlController = TextEditingController(text: b?.logoUrl ?? '');
    _descriptionController = TextEditingController(text: b?.description ?? '');
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
      businessId: widget.businessId,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل علامة تجارية' : 'إضافة علامة تجارية للمتجر'),
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
