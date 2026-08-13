import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/product_variant.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

class DiscountOfferProductPage extends StatefulWidget {
  final ProductModel product;

  const DiscountOfferProductPage({super.key, required this.product});

  @override
  State<DiscountOfferProductPage> createState() => _DiscountOfferProductPageState();
}

class _DiscountOfferProductPageState extends State<DiscountOfferProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _discountController;
  late TextEditingController _image1Controller;
  late TextEditingController _image2Controller;
  late TextEditingController _image3Controller;
  bool _isNewArrival = false;
  bool _isTopSelling = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _discountController = TextEditingController(
      text: p.discountPercent != null ? p.discountPercent.toString() : '',
    );
    _image1Controller = TextEditingController(
      text: p.images.isNotEmpty ? p.images[0] : '',
    );
    _image2Controller = TextEditingController(
      text: p.images.length > 1 ? p.images[1] : '',
    );
    _image3Controller = TextEditingController(
      text: p.images.length > 2 ? p.images[2] : '',
    );
    _isNewArrival = p.isFeatured;
    _isTopSelling = p.isTopSelling;
  }

  @override
  void dispose() {
    _discountController.dispose();
    _image1Controller.dispose();
    _image2Controller.dispose();
    _image3Controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<ProductProvider>();
    final int? discount = int.tryParse(_discountController.text);

    // Apply the discount to the default variant
    final List<ProductVariant> updatedVariants = widget.product.variants.map((v) {
      if (v.isDefault) {
        final double orig = v.originalPrice ?? v.price;
        final double newPrice = discount != null && discount > 0
            ? orig * (1 - (discount / 100))
            : orig;
        return v.copyWith(
          originalPrice: orig,
          price: newPrice,
        );
      }
      return v;
    }).toList();

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
      id: widget.product.id,
      businessId: widget.product.businessId,
      categoryId: widget.product.categoryId,
      brandId: widget.product.brandId,
      name: widget.product.name,
      description: widget.product.description,
      category: widget.product.category,
      brand: widget.product.brand,
      images: imagesList,
      variants: updatedVariants,
      isFeatured: _isNewArrival,
      isTopSelling: _isTopSelling,
      ratings: widget.product.ratings,
      createdAt: widget.product.createdAt,
      updatedAt: DateTime.now(),
    );

    await provider.updateProduct(updatedProduct);

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الخصومات والترويج للمنتج بنجاح!'),
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
        title: const Text('الخصومات والعروض الترويجية'),
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

                      // Discount Rate
                      TextFormField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '${TranslationKeys.discountRate.tr(context)} (%)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.percent_rounded, size: 20),
                        ),
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
                          labelText: 'رابط الصورة الرئيسية (Image URL 1)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 24),

                      // Marketing Badges
                      const Text(
                        'شارات التسويق والترويج',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
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
