import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class CreateEditProductPage extends StatefulWidget {
  final Product? product;

  const CreateEditProductPage({super.key, this.product});

  @override
  State<CreateEditProductPage> createState() => _CreateEditProductPageState();
}

class _CreateEditProductPageState extends State<CreateEditProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Basic Controllers
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _brandController;
  late TextEditingController _descriptionController;

  // Pricing Controllers
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _discountController;

  // Image Controllers
  late TextEditingController _image1Controller;
  late TextEditingController _image2Controller;
  late TextEditingController _image3Controller;

  // Flags & Selections
  bool _isNewArrival = false;
  bool _isTopSelling = false;
  bool _isSubmitting = false;

  final List<String> _selectedSizes = [];
  final List<Color> _selectedColors = [];

  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '38', '40', '42', '44'];
  final List<Color> _availableColors = [
    Colors.black,
    Colors.white,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.amber,
    Colors.purple,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');

    _priceController = TextEditingController(text: p != null ? p.price.toString() : '');
    _originalPriceController = TextEditingController(text: p?.originalPrice != null ? p!.originalPrice.toString() : '');
    _discountController = TextEditingController(text: p?.discountPercent != null ? p!.discountPercent.toString() : '');

    _image1Controller = TextEditingController(text: (p != null && p.images.isNotEmpty) ? p.images[0] : '');
    _image2Controller = TextEditingController(text: (p != null && p.images.length > 1) ? p.images[1] : '');
    _image3Controller = TextEditingController(text: (p != null && p.images.length > 2) ? p.images[2] : '');

    _isNewArrival = p?.isNewArrival ?? false;
    _isTopSelling = p?.isTopSelling ?? false;

    if (p != null) {
      _selectedSizes.addAll(p.sizes);
      _selectedColors.addAll(p.colors);
    } else {
      _selectedSizes.addAll(['M', 'L']);
      _selectedColors.addAll([Colors.black, Colors.blue]);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();

    _priceController.dispose();
    _originalPriceController.dispose();
    _discountController.dispose();

    _image1Controller.dispose();
    _image2Controller.dispose();
    _image3Controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<ProductProvider>();

    final double price = double.tryParse(_priceController.text) ?? 0.0;
    final double? origPrice = double.tryParse(_originalPriceController.text);
    final int? discount = int.tryParse(_discountController.text);

    final List<String> imagesList = [];
    if (_image1Controller.text.trim().isNotEmpty) imagesList.add(_image1Controller.text.trim());
    if (_image2Controller.text.trim().isNotEmpty) imagesList.add(_image2Controller.text.trim());
    if (_image3Controller.text.trim().isNotEmpty) imagesList.add(_image3Controller.text.trim());

    final isEdit = widget.product != null;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final productId = isEdit ? widget.product!.id : 'prd_${timestamp.substring(timestamp.length - 6)}';

    final updatedProduct = Product(
      id: productId,
      name: _nameController.text.trim(),
      price: price,
      originalPrice: origPrice,
      discountPercent: discount,
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      brand: _brandController.text.trim().isNotEmpty ? _brandController.text.trim() : null,
      colors: _selectedColors,
      sizes: _selectedSizes,
      images: imagesList,
      rating: widget.product?.rating ?? 4.5,
      reviewsCount: widget.product?.reviewsCount ?? 12,
      isNewArrival: _isNewArrival,
      isTopSelling: _isTopSelling,
    );

    if (isEdit) {
      provider.updateProduct(updatedProduct);
    } else {
      provider.addProduct(updatedProduct);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'تم تحديث بيانات المنتج بنجاح!' : 'تم إضافة المنتج الجديد بنجاح!',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return AddEditTemplate(
      title: isEdit ? 'تعديل المنتج' : TranslationKeys.addNewProduct.tr(context),
      subtitle: isEdit ? 'تعديل كافة بيانات واسعار وخيارات المنتج الحالية' : 'إدخال كامل تفاصيل ومعلومات المنتج الجديد',
      isEditMode: isEdit,
      formKey: _formKey,
      submitLabel: isEdit ? TranslationKeys.saveChanges.tr(context) : TranslationKeys.addNewProduct.tr(context),
      submitIcon: isEdit ? Icons.save_rounded : Icons.add_circle_outline_rounded,
      onSubmit: _submit,
      isSubmitting: _isSubmitting,
      cancelLabel: TranslationKeys.cancel.tr(context),
      sections: [
        // 1. Basic Info Section
        FormSection(
          title: 'معلومات المنتج الأساسية',
          subtitle: 'اسم المنتج والتصنيف والوصف الشامل',
          icon: Icons.inventory_2_rounded,
          fields: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${TranslationKeys.product.tr(context)} (الاسم)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.shopping_bag_outlined, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.category.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.category_rounded, size: 20),
                    ),
                    validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'العلامة التجارية (Brand)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.branding_watermark_rounded, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'وصف المنتج',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
          ],
        ),

        // 2. Pricing & Discount Section
        FormSection(
          title: 'التسعير والخصومات',
          subtitle: 'سعر البيع، السعر الأصلي ونسبة الخصم',
          icon: Icons.attach_money_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: '${TranslationKeys.price.tr(context)} (\$)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.monetization_on_outlined, size: 20),
                    ),
                    validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _originalPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'السعر الأصلي (قبل الخصم)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.price_change_outlined, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${TranslationKeys.discountRate.tr(context)} (%)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.percent_rounded, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // 3. Media Section
        FormSection(
          title: 'صور المنتج والوسائط',
          subtitle: 'روابط صور المنتج المعروضة',
          icon: Icons.image_rounded,
          fields: [
            TextFormField(
              controller: _image1Controller,
              decoration: const InputDecoration(
                labelText: 'رابط الصورة الرئيسية (Image URL 1)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link_rounded, size: 20),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _image2Controller,
                    decoration: const InputDecoration(
                      labelText: 'رابط صورة إضافية 2',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link_rounded, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _image3Controller,
                    decoration: const InputDecoration(
                      labelText: 'رابط صورة إضافية 3',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link_rounded, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // 4. Variants, Colors & Sizes Section
        FormSection(
          title: 'الخيارات والمقاسات والألوان',
          subtitle: 'تحديد مقاسات وألوان المنتج المتاحة',
          icon: Icons.palette_rounded,
          fields: [
            const Text('الألوان المتاحة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _availableColors.map((color) {
                final isSelected = _selectedColors.contains(color);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedColors.remove(color);
                      } else {
                        _selectedColors.add(color);
                      }
                    });
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.4),
                        width: isSelected ? 3 : 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 20,
                            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('المقاسات المتاحة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSizes.map((size) {
                final isSelected = _selectedSizes.contains(size);
                return FilterChip(
                  label: Text(size),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSizes.add(size);
                      } else {
                        _selectedSizes.remove(size);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),

        // 5. Marketing Badges Section
        FormSection(
          title: 'شارات التسويق والترويج',
          subtitle: 'تحديد الشارات الترويجية للمنتج',
          icon: Icons.campaign_rounded,
          fields: [
            SwitchListTile(
              title: const Text('وصل حديثاً (New Arrival)'),
              subtitle: const Text('إظهار شارة "جديد" على المنتج في المنصة'),
              value: _isNewArrival,
              onChanged: (val) => setState(() => _isNewArrival = val),
            ),
            SwitchListTile(
              title: const Text('الأكثر مبيعاً (Top Selling)'),
              subtitle: const Text('إظهار شارة "الأكثر مبيعاً" في نتائج البحث'),
              value: _isTopSelling,
              onChanged: (val) => setState(() => _isTopSelling = val),
            ),
          ],
        ),
      ],
    );
  }
}
