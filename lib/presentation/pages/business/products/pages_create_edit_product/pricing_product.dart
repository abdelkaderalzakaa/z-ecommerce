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
        _variants.add(const ProductVariant(
          isDefault: true,
          price: 0.0,
          stock: 0,
        ));
      } else {
        _variants[0] = _variants[0].copyWith(isDefault: true);
      }
    }
  }

  void _setDefault(int index) {
    setState(() {
      for (int i = 0; i < _variants.length; i++) {
        _variants[i] = _variants[i].copyWith(isDefault: i == index);
      }
    });
  }

  void _addVariant() {
    setState(() {
      _variants.add(ProductVariant(
        isDefault: _variants.isEmpty,
        price: 0.0,
        stock: 0,
      ));
    });
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
      appBar: AppBar(
        title: const Text('تسعير وخيارات المنتج'),
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
                      // Product Card at the top
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
                                    ? const Icon(Icons.inventory_2_rounded, color: Colors.grey)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${p.category} ${p.brand != null ? "• ${p.brand}" : ""}',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.name,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.description,
                                      style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
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
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: _addVariant,
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
                            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                          ),
                          child: const Center(
                            child: Text(
                              'لا توجد خيارات مضافة حالياً. سيتم بيع المنتج كخيار واحد قياسي.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _variants.length,
                          separatorBuilder: (context, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final variant = _variants[index];

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: variant.isDefault
                                      ? theme.primaryColor.withOpacity(0.5)
                                      : theme.dividerColor.withOpacity(0.15),
                                  width: variant.isDefault ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      // Size selection
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<ProductSize>(
                                          value: variant.size,
                                          decoration: const InputDecoration(
                                            labelText: 'المقاس',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          ),
                                          items: ProductSize.values.map((size) {
                                            return DropdownMenuItem<ProductSize>(
                                              value: size,
                                              child: Text(size.name.toUpperCase()),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            _updateVariant(index, variant.copyWith(size: val));
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Color selection
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<ProductColor>(
                                          value: variant.color,
                                          decoration: const InputDecoration(
                                            labelText: 'اللون',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          ),
                                          items: ProductColor.values.map((col) {
                                            return DropdownMenuItem<ProductColor>(
                                              value: col,
                                              child: Text(col.name),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            _updateVariant(index, variant.copyWith(color: val));
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Price input
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          key: ValueKey('price_${index}_${variant.isDefault}'),
                                          initialValue: variant.price > 0 ? variant.price.toString() : '',
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(
                                            labelText: 'سعر البيع (\$)',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          ),
                                          validator: (v) => v == null || v.trim().isEmpty
                                              ? TranslationKeys.required.tr(context)
                                              : null,
                                          onChanged: (val) {
                                            final double p = double.tryParse(val) ?? 0.0;
                                            _updateVariant(index, variant.copyWith(price: p));
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Original Price input
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          key: ValueKey('orig_${index}_${variant.isDefault}'),
                                          initialValue: variant.originalPrice != null && variant.originalPrice! > 0
                                              ? variant.originalPrice.toString()
                                              : '',
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(
                                            labelText: 'السعر الأصلي (\$)',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          ),
                                          onChanged: (val) {
                                            final double? op = double.tryParse(val);
                                            _updateVariant(index, variant.copyWith(originalPrice: op));
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Stock input
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          key: ValueKey('stock_${index}_${variant.isDefault}'),
                                          initialValue: variant.stock > 0 ? variant.stock.toString() : '',
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'الكمية',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          ),
                                          validator: (v) => v == null || v.trim().isEmpty
                                              ? TranslationKeys.required.tr(context)
                                              : null,
                                          onChanged: (val) {
                                            final int s = int.tryParse(val) ?? 0;
                                            _updateVariant(index, variant.copyWith(stock: s));
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 4),

                                      // Set default icon button
                                      IconButton(
                                        icon: Icon(
                                          variant.isDefault ? Icons.star : Icons.star_border,
                                          color: Colors.amber,
                                        ),
                                        tooltip: variant.isDefault ? 'الخيار الافتراضي' : 'تعيين كافتراضي',
                                        onPressed: () => _setDefault(index),
                                      ),

                                      // Delete button
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _removeVariant(index),
                                      ),
                                    ],
                                  ),
                                ],
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
