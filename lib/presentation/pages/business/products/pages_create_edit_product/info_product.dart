import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

class InfoProductPage extends StatefulWidget {
  final ProductModel? product;
  final String? businessId;

  const InfoProductPage({super.key, this.product, this.businessId});

  @override
  State<InfoProductPage> createState() => _InfoProductPageState();
}

class _InfoProductPageState extends State<InfoProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _image1Controller;
  late TextEditingController _image2Controller;
  late TextEditingController _image3Controller;

  String? _selectedCategoryId;
  String? _selectedBrandId;
  String? _selectedBusinessId;
  bool _isFreeShipping = false;
  late TextEditingController _shippingCostController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    
    _image1Controller = TextEditingController(text: p != null && p.images.isNotEmpty ? p.images[0] : '');
    _image2Controller = TextEditingController(text: p != null && p.images.length > 1 ? p.images[1] : '');
    _image3Controller = TextEditingController(text: p != null && p.images.length > 2 ? p.images[2] : '');

    _isFreeShipping = p?.isFreeShipping ?? false;
    _shippingCostController = TextEditingController(text: p?.shippingCost != null && p!.shippingCost > 0 ? p.shippingCost.toString() : '');

    _selectedCategoryId = p?.categoryId.isNotEmpty == true ? p?.categoryId : null;
    _selectedBrandId = p?.brandId?.isNotEmpty == true ? p?.brandId : null;

    final authUser = context.read<AuthProvider>().currentUser;
    _selectedBusinessId = widget.businessId ?? p?.businessId ?? authUser?.businessId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().listenToAllCategories();
      if (_selectedBusinessId != null) {
        context.read<BrandProvider>().listenToBrandsByStore(_selectedBusinessId!);
      } else {
        context.read<BrandProvider>().listenToAllBrands();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _image1Controller.dispose();
    _image2Controller.dispose();
    _image3Controller.dispose();
    _shippingCostController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<ProductProvider>();
    final isEdit = widget.product != null;
    
    final effectiveBusinessId = _selectedBusinessId ?? '';

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final productId = isEdit
        ? widget.product!.id
        : 'prd_${timestamp.substring(timestamp.length - 6)}';

    String catLabel = '';
    try {
      catLabel = context
          .read<CategoryProvider>()
          .categories
          .firstWhere((c) => c.id == _selectedCategoryId)
          .label;
    } catch (_) {
      catLabel = widget.product?.category ?? 'غير مصنف';
    }

    String? brandName;
    if (_selectedBrandId != null) {
      try {
        brandName = context
            .read<BrandProvider>()
            .brands
            .firstWhere((b) => b.id == _selectedBrandId)
            .name;
      } catch (_) {
        brandName = widget.product?.brand;
      }
    }

    final List<String> imagesList = [];
    if (_image1Controller.text.trim().isNotEmpty) {
      imagesList.add(_image1Controller.text.trim());
    }
    if (_image2Controller.text.trim().isNotEmpty) {
      imagesList.add(_image2Controller.text.trim());
    }
    if (_image3Controller.text.trim().isNotEmpty) {
      imagesList.add(_image3Controller.text.trim());
    }

    final updatedProduct = ProductModel(
      id: productId,
      businessId: effectiveBusinessId,
      categoryId: _selectedCategoryId ?? '',
      brandId: _selectedBrandId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: catLabel,
      brand: brandName,
      images: imagesList,
      thumbnail: imagesList.isNotEmpty ? imagesList.first : null,
      variants: widget.product?.variants ?? [],
      discounts: widget.product?.discounts ?? [],
      offers: widget.product?.offers ?? [],
      isActive: widget.product?.isActive ?? true,
      isFeatured: widget.product?.isFeatured ?? false,
      isTopSelling: widget.product?.isTopSelling ?? false,
      isFreeShipping: _isFreeShipping,
      shippingCost: _isFreeShipping ? 0.0 : (double.tryParse(_shippingCostController.text) ?? 0.0),
      ratings: widget.product?.ratings ?? [],
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    if (isEdit) {
      await provider.updateProduct(updatedProduct);
    } else {
      await provider.addProduct(updatedProduct);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'تم حفظ التعديلات بنجاح!' : 'تم إضافة المنتج بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final theme = Theme.of(context);
    final categories = context.watch<CategoryProvider>().categories;
    final brands = context.watch<BrandProvider>().brands;
    final businesses = context.watch<BusinessProvider>().businesses;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasPresetBusiness = widget.businessId != null || widget.product != null;

    BusinessModel? store;
    if (_selectedBusinessId != null && businesses.isNotEmpty) {
      try {
        store = businesses.firstWhere((b) => b.id == _selectedBusinessId);
      } catch (_) {
        store = null;
        _selectedBusinessId = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل معلومات المنتج' : 'إضافة معلومات المنتج'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasPresetBusiness && store != null)
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                          ),
                          color: theme.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                                  backgroundImage: store.theme.logoUrl != null
                                      ? NetworkImage(store.theme.logoUrl!)
                                      : null,
                                  child: store.theme.logoUrl == null
                                      ? Icon(Icons.storefront_rounded, color: theme.primaryColor, size: 26)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'المتجر المالك للمنتج',
                                        style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isArabic ? store.localization.name.ar : store.localization.name.en,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isArabic ? store.localization.description.ar : store.localization.description.en,
                                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        DropdownButtonFormField<String>(
                          value: _selectedBusinessId,
                          decoration: const InputDecoration(
                            labelText: 'اختر المتجر المالك للمنتج',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.storefront_rounded, size: 20),
                          ),
                          items: businesses.map((b) {
                            final name = isArabic ? b.localization.name.ar : b.localization.name.en;
                            return DropdownMenuItem<String>(
                              value: b.id,
                              child: Text(name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedBusinessId = val;
                                _selectedCategoryId = null;
                                _selectedBrandId = null;
                              });
                              context.read<BrandProvider>().listenToBrandsByStore(val);
                            }
                          },
                          validator: (v) =>
                              v == null ? TranslationKeys.required.tr(context) : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 16),

                      // Form Fields
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '${TranslationKeys.product.tr(context)} (الاسم)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.shopping_bag_outlined, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? TranslationKeys.required.tr(context) : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: categories.any((cat) => cat.id == _selectedCategoryId && _selectedBusinessId != null && cat.businessIds.contains(_selectedBusinessId!)) ? _selectedCategoryId : null,
                              decoration: InputDecoration(
                                labelText: TranslationKeys.category.tr(context),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.category_rounded, size: 20),
                              ),
                              items: categories.where((cat) => _selectedBusinessId != null && cat.businessIds.contains(_selectedBusinessId!)).map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat.id,
                                  child: Text(cat.label),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCategoryId = val),
                              validator: (v) =>
                                  v == null ? TranslationKeys.required.tr(context) : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: brands.any((b) => b.id == _selectedBrandId && _selectedBusinessId != null && b.businessIds.contains(_selectedBusinessId!)) ? _selectedBrandId : null,
                              decoration: const InputDecoration(
                                labelText: 'العلامة التجارية (Brand)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.branding_watermark_rounded, size: 20),
                              ),
                              items: brands.where((b) => _selectedBusinessId != null && b.businessIds.contains(_selectedBusinessId!)).map((b) {
                                return DropdownMenuItem<String>(
                                  value: b.id,
                                  child: Text(b.name),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedBrandId = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'وصف المنتج',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description_outlined, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? TranslationKeys.required.tr(context) : null,
                      ),
                      const SizedBox(height: 24),

                      // Images Section
                      const Text(
                        'صور المنتج والوسائط',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _image1Controller,
                        decoration: const InputDecoration(
                          labelText: 'رابط الصورة الرئيسية للمنتج (Thumbnail)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _image2Controller,
                        decoration: const InputDecoration(
                          labelText: 'رابط الصورة الإضافية الثانية',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _image3Controller,
                        decoration: const InputDecoration(
                          labelText: 'رابط الصورة الإضافية الثالثة',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Shipping Section
                      const Text(
                        'خيارات الشحن والتوصيل (تظهر ضمن العروض)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('شحن مجاني لكامل الأراضي اللبنانية'),
                        subtitle: const Text('تفعيل شارة الشحن المجاني للمنتج'),
                        value: _isFreeShipping,
                        onChanged: (val) {
                          setState(() {
                            _isFreeShipping = val;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (!_isFreeShipping) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _shippingCostController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'كلفة الشحن إلى كامل الأراضي اللبنانية (\$)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_shipping_outlined, size: 20),
                          ),
                          validator: (v) {
                            if (!_isFreeShipping && (v == null || v.trim().isEmpty)) {
                              return 'يرجى تحديد كلفة الشحن أو تفعيل الشحن المجاني';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.12))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(TranslationKeys.cancel.tr(context)),
                  ),
                  ButtonApp(
                    onPressed: _isSubmitting ? null : _submit,
                    isLoading: _isSubmitting,
                    icon: isEdit ? Icons.save : Icons.add,
                    label: isEdit ? TranslationKeys.saveChanges.tr(context) : 'إضافة المنتج',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
