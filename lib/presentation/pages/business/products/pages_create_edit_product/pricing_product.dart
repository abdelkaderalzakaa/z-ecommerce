import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/product_variant.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/product_enums.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

class PricingProductPage extends StatefulWidget {
  final ProductModel product;

  const PricingProductPage({super.key, required this.product});

  @override
  State<PricingProductPage> createState() => _PricingProductPageState();
}

class _PricingProductPageState extends State<PricingProductPage> {
  final _formKey = GlobalKey<FormState>();
  List<ProductVariant> _variants = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _variants = List<ProductVariant>.from(widget.product.variants);
    _ensureDefaultVariant();
  }

  void _ensureDefaultVariant() {
    if (!_variants.any((v) => v.isDefault)) {
      if (_variants.isEmpty) {
        _variants.add(
          const ProductVariant(isDefault: true, price: 0.0, stock: 0),
        );
      } else {
        _variants[0] = _variants[0].copyWith(isDefault: true);
      }
    }
  }

  void _removeVariant(int index) {
    setState(() {
      final wasDefault = _variants[index].isDefault;
      _variants.removeAt(index);
      if (wasDefault && _variants.isNotEmpty) {
        _variants[0] = _variants[0].copyWith(isDefault: true);
      }
      _ensureDefaultVariant();
    });
  }

  void _updateVariant(int index, ProductVariant updated) {
    setState(() {
      _variants[index] = updated;
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<ProductProvider>();

    final updatedProduct = ProductModel(
      id: widget.product.id,
      businessId: widget.product.businessId,
      categoryId: widget.product.categoryId,
      brandId: widget.product.brandId,
      name: widget.product.name,
      description: widget.product.description,
      category: widget.product.category,
      brand: widget.product.brand,
      images: widget.product.images,
      variants: _variants,
      isFeatured: widget.product.isFeatured,
      isTopSelling: widget.product.isTopSelling,
      ratings: widget.product.ratings,
      createdAt: widget.product.createdAt,
      updatedAt: DateTime.now(),
    );

    await provider.updateProduct(updatedProduct);

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث أسعار وخيارات المنتج بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(title: const Text('تسعير وخيارات المنتج')),
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
                      // Product Card at the top
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.dividerColor.withOpacity(0.12),
                          ),
                        ),
                        color: theme.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: theme.dividerColor.withOpacity(0.08),
                                  image: p.images.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(p.images.first),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: p.images.isEmpty
                                    ? const Icon(
                                        Icons.inventory_2_rounded,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${p.category} ${p.brand != null ? "• ${p.brand}" : ""}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textTheme.bodySmall?.color
                                            ?.withOpacity(0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Variants Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'خيارات وأسعار المنتج (Variants)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VariantFormPage(
                                    onSave: (newVariant) {
                                      setState(() {
                                        if (newVariant.isDefault) {
                                          for (
                                            int i = 0;
                                            i < _variants.length;
                                            i++
                                          ) {
                                            _variants[i] = _variants[i]
                                                .copyWith(isDefault: false);
                                          }
                                        }
                                        _variants.add(newVariant);
                                        _ensureDefaultVariant();
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة خيار'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_variants.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.1),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'لا توجد خيارات مضافة حالياً. سيتم بيع المنتج كخيار واحد قياسي.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _variants.length,
                          separatorBuilder: (context, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final variant = _variants[index];

                            final List<String> details = [];
                            if (variant.name.isNotEmpty) {
                              details.add(variant.name);
                            }
                            if (variant.size != null) {
                              details.add(
                                'المقاس: ${variant.size!.displayName}',
                              );
                            }
                            if (variant.color != null) {
                              details.add(
                                'اللون: ${variant.color!.displayName(context)}',
                              );
                            }
                            if (variant.material != null) {
                              details.add(
                                'المادة: ${variant.material!.displayName(context)}',
                              );
                            }
                            if (variant.type != null) {
                              details.add(
                                'النوع: ${variant.type!.displayName(context)}',
                              );
                            }
                            if (variant.weight != null) {
                              details.add(
                                'الوزن: ${variant.weight} ${variant.weightUnit?.displayName(context) ?? ''}',
                              );
                            }

                            final detailText = details.isEmpty
                                ? 'خيار قياسي'
                                : details.join(' • ');

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: variant.isDefault
                                      ? theme.primaryColor
                                      : theme.dividerColor.withOpacity(0.15),
                                  width: variant.isDefault ? 1.5 : 1.0,
                                ),
                              ),
                              color: theme.cardColor,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Icon(
                                  variant.isDefault
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                title: Text(
                                  detailText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: variant.isActive
                                        ? null
                                        : theme.disabledColor,
                                    decoration: variant.isActive
                                        ? null
                                        : TextDecoration.lineThrough,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'السعر: \$${variant.price.toStringAsFixed(2)} • الكمية: ${variant.stock}',
                                    style: TextStyle(
                                      color: variant.isActive
                                          ? theme.textTheme.bodySmall?.color
                                                ?.withOpacity(0.7)
                                          : theme.disabledColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Active/Inactive toggle switch
                                    Switch(
                                      value: variant.isActive,
                                      onChanged: (val) {
                                        _updateVariant(
                                          index,
                                          variant.copyWith(isActive: val),
                                        );
                                      },
                                    ),
                                    ButtonApp(
                                      format: FormatButtonApp.icon,
                                      icon: Icons.edit_outlined,
                                      label: "",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VariantFormPage(
                                                  variant: variant,
                                                  onSave: (updated) {
                                                    _updateVariant(
                                                      index,
                                                      updated,
                                                    );
                                                  },
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    ButtonApp(
                                      format: FormatButtonApp.icon,
                                      label: "",
                                      icon: Icons.delete_outline,
                                      color: Colors.red,
                                      onPressed: () => _removeVariant(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(TranslationKeys.cancel.tr(context)),
                  ),
                  ButtonApp(
                    onPressed: _isSubmitting ? null : _submit,
                    isLoading: _isSubmitting,
                    icon: Icons.save,
                    label: TranslationKeys.saveChanges.tr(context),
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

class VariantFormPage extends StatefulWidget {
  final ProductVariant? variant;
  final ValueChanged<ProductVariant> onSave;

  const VariantFormPage({super.key, this.variant, required this.onSave});

  @override
  State<VariantFormPage> createState() => _VariantFormPageState();
}

class _VariantFormPageState extends State<VariantFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _stockController;
  late TextEditingController _weightController;

  ProductSize? _size;
  ProductColor? _color;
  ProductMaterial? _material;
  ProductType? _type;
  WeightUnit? _weightUnit;
  bool _isDefault = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final v = widget.variant;
    _nameController = TextEditingController(text: v?.name ?? '');
    _priceController = TextEditingController(
      text: v != null && v.price > 0 ? v.price.toString() : '',
    );
    _originalPriceController = TextEditingController(
      text: v?.originalPrice != null ? v!.originalPrice.toString() : '',
    );
    _stockController = TextEditingController(
      text: v != null && v.stock >= 0 ? v.stock.toString() : '',
    );
    _weightController = TextEditingController(
      text: v?.weight != null ? v!.weight.toString() : '',
    );

    _size = v?.size;
    _color = v?.color;
    _material = v?.material;
    _type = v?.type;
    _weightUnit = v?.weightUnit;
    _isDefault = v?.isDefault ?? false;
    _isActive = v?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.variant == null
              ? (isAr ? 'إضافة خيار جديد' : 'Add New Variant')
              : (isAr ? 'تعديل الخيار' : 'Edit Variant'),
        ),
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
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم الخيار (مثال: أحمر - XL)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'سعر البيع (\$)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? TranslationKeys.required.tr(context)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'الكمية',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? TranslationKeys.required.tr(context)
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<ProductSize?>(
                              value: _size,
                              decoration: const InputDecoration(
                                labelText: 'المقاس',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('بلا مقاس'),
                                ),
                                ...ProductSize.values.map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.displayName),
                                  ),
                                ),
                              ],
                              onChanged: (val) => setState(() => _size = val),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<ProductColor?>(
                              value: _color,
                              decoration: const InputDecoration(
                                labelText: 'اللون',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('بلا لون'),
                                ),
                                ...ProductColor.values.map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.displayName(context)),
                                  ),
                                ),
                              ],
                              onChanged: (val) => setState(() => _color = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<ProductMaterial?>(
                              value: _material,
                              decoration: const InputDecoration(
                                labelText: 'المادة',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('بلا مادة'),
                                ),
                                ...ProductMaterial.values.map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m.displayName(context)),
                                  ),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _material = val),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<ProductType?>(
                              value: _type,
                              decoration: const InputDecoration(
                                labelText: 'النوع',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('بلا نوع'),
                                ),
                                ...ProductType.values.map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.displayName(context)),
                                  ),
                                ),
                              ],
                              onChanged: (val) => setState(() => _type = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'الوزن',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<WeightUnit?>(
                              value: _weightUnit,
                              decoration: const InputDecoration(
                                labelText: 'وحدة الوزن',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('بلا وحدة'),
                                ),
                                ...WeightUnit.values.map(
                                  (u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u.displayName(context)),
                                  ),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _weightUnit = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: Text(
                          isAr
                              ? 'تعيين كخيار افتراضي للمنتج'
                              : 'Set as default variant',
                        ),
                        value: _isDefault,
                        onChanged: (val) =>
                            setState(() => _isDefault = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: Text(isAr ? 'تفعيل الخيار' : 'Enable option'),
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(TranslationKeys.cancel.tr(context)),
                  ),
                  ButtonApp(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      final newVariant = ProductVariant(
                        isDefault: _isDefault,
                        isActive: _isActive,
                        name: _nameController.text.trim(),
                        price: double.tryParse(_priceController.text) ?? 0.0,
                        originalPrice: null,
                        stock: int.tryParse(_stockController.text) ?? 0,
                        size: _size,
                        color: _color,
                        material: _material,
                        type: _type,
                        weight: double.tryParse(_weightController.text),
                        weightUnit: _weightUnit,
                      );
                      widget.onSave(newVariant);
                      Navigator.pop(context);
                    },
                    icon: Icons.check,
                    label: isAr ? 'حفظ الخيار' : 'Save Variant',
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

extension ProductSizeExt on ProductSize {
  String get displayName {
    switch (this) {
      case ProductSize.small:
        return 'S (صغير)';
      case ProductSize.medium:
        return 'M (متوسط)';
      case ProductSize.large:
        return 'L (كبير)';
      case ProductSize.xlarge:
        return 'XL (كبير جداً)';
      case ProductSize.xxlarge:
        return 'XXL (كبير جداً جداً)';
    }
  }
}

extension ProductColorExt on ProductColor {
  String displayName(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (this) {
      case ProductColor.red:
        return isAr ? 'أحمر' : 'Red';
      case ProductColor.blue:
        return isAr ? 'أزرق' : 'Blue';
      case ProductColor.black:
        return isAr ? 'أسود' : 'Black';
      case ProductColor.white:
        return isAr ? 'أبيض' : 'White';
      case ProductColor.green:
        return isAr ? 'أخضر' : 'Green';
      case ProductColor.yellow:
        return isAr ? 'أصفر' : 'Yellow';
    }
  }
}

extension ProductMaterialExt on ProductMaterial {
  String displayName(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (this) {
      case ProductMaterial.cotton:
        return isAr ? 'قطن' : 'Cotton';
      case ProductMaterial.leather:
        return isAr ? 'جلد' : 'Leather';
      case ProductMaterial.silk:
        return isAr ? 'حرير' : 'Silk';
      case ProductMaterial.wool:
        return isAr ? 'صوف' : 'Wool';
      case ProductMaterial.polyester:
        return isAr ? 'بوليستر' : 'Polyester';
      case ProductMaterial.wood:
        return isAr ? 'خشب' : 'Wood';
      case ProductMaterial.metal:
        return isAr ? 'معدن' : 'Metal';
      case ProductMaterial.plastic:
        return isAr ? 'بلاستيك' : 'Plastic';
    }
  }
}

extension ProductTypeExt on ProductType {
  String displayName(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (this) {
      case ProductType.casual:
        return isAr ? 'كاجوال' : 'Casual';
      case ProductType.formal:
        return isAr ? 'رسمي' : 'Formal';
      case ProductType.sport:
        return isAr ? 'رياضي' : 'Sport';
      case ProductType.classic:
        return isAr ? 'كلاسيك' : 'Classic';
    }
  }
}

extension WeightUnitExt on WeightUnit {
  String displayName(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (this) {
      case WeightUnit.gram:
        return isAr ? 'جرام' : 'g';
      case WeightUnit.kilogram:
        return isAr ? 'كيلوجرام' : 'kg';
      case WeightUnit.pound:
        return isAr ? 'رطل' : 'lb';
    }
  }
}
