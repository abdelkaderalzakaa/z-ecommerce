import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/data/providers/offer_provider.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class CreateEditOfferPage extends StatefulWidget {
  final OfferModel? offer;
  final String? businessId;

  const CreateEditOfferPage({super.key, this.offer, this.businessId});

  @override
  State<CreateEditOfferPage> createState() => _CreateEditOfferPageState();
}

class _CreateEditOfferPageState extends State<CreateEditOfferPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleArController;
  late TextEditingController _titleEnController;
  late TextEditingController _businessIdController;
  late TextEditingController _couponCodeController;
  late TextEditingController _discountPercentController;
  late TextEditingController _discountAmountController;
  late TextEditingController _minOrderController;

  String _selectedTarget = 'cart'; // 'cart', 'category', 'brand'
  String? _selectedCategoryId;
  String? _selectedBrandId;

  String _selectedType = 'percentage_discount';
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final o = widget.offer;

    _titleArController = TextEditingController(text: o?.name.ar ?? '');
    _titleEnController = TextEditingController(text: o?.name.en ?? '');
    _businessIdController = TextEditingController(text: o?.businessId ?? widget.businessId ?? '');
    _couponCodeController = TextEditingController(text: o?.couponCode ?? '');
    _discountPercentController = TextEditingController(
      text: o?.discountPercent != null ? o!.discountPercent.toString() : '',
    );
    _discountAmountController = TextEditingController(
      text: o?.discountAmount != null ? o!.discountAmount.toString() : '',
    );
    _minOrderController = TextEditingController(
      text: o?.minOrderAmount != null ? o!.minOrderAmount.toString() : '',
    );

    _selectedType = o?.type ?? 'percentage_discount';
    _isActive = o?.isActive ?? true;

    _selectedTarget = o?.categoryId != null
        ? 'category'
        : (o?.brandId != null ? 'brand' : 'cart');
    _selectedCategoryId = o?.categoryId;
    _selectedBrandId = o?.brandId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().listenToAllCategories();
      context.read<BrandProvider>().listenToAllBrands();
    });
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _businessIdController.dispose();
    _couponCodeController.dispose();
    _discountPercentController.dispose();
    _discountAmountController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<OfferProvider>();
    final isEdit = widget.offer != null;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final offerId = isEdit
        ? widget.offer!.id
        : 'ofr_${timestamp.substring(timestamp.length - 6)}';

    final showCouponCode = _selectedType == 'coupon';
    final showPercent = _selectedType == 'percentage_discount' || _selectedType == 'coupon';
    final showAmount = _selectedType == 'fixed_discount';

    final isCart = _selectedTarget == 'cart';
    final isCategory = _selectedTarget == 'category';
    final isBrand = _selectedTarget == 'brand';

    final updatedOffer = OfferModel(
      id: offerId,
      businessId: _businessIdController.text.trim(),
      name: LocalizedString(
        ar: _titleArController.text.trim(),
        en: _titleEnController.text.trim(),
      ),
      type: _selectedType,
      couponCode: showCouponCode && _couponCodeController.text.trim().isNotEmpty
          ? _couponCodeController.text.trim()
          : null,
      discountPercent: showPercent ? double.tryParse(_discountPercentController.text) : null,
      discountAmount: showAmount ? double.tryParse(_discountAmountController.text) : null,
      minOrderAmount: (isCart || _selectedType == 'free_shipping')
          ? double.tryParse(_minOrderController.text)
          : null,
      categoryId: isCategory ? _selectedCategoryId : null,
      brandId: isBrand ? _selectedBrandId : null,
      startDate: widget.offer?.startDate ?? DateTime.now(),
      endDate:
          widget.offer?.endDate ?? DateTime.now().add(const Duration(days: 30)),
      isActive: _isActive,
    );

    if (isEdit) {
      await provider.updateOffer(updatedOffer);
    } else {
      await provider.addOffer(updatedOffer);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'تم تحديث بيانات العرض بنجاح!'
                : 'تم إنشاء العرض التسويقي الجديد بنجاح!',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.offer != null;
    final isStoreOwner = widget.businessId != null || widget.offer?.businessId != null;

    final showCouponCode = _selectedType == 'coupon';
    final showPercent = _selectedType == 'percentage_discount' || _selectedType == 'coupon';
    final showAmount = _selectedType == 'fixed_discount';

    final showCategory = _selectedTarget == 'category';
    final showBrand = _selectedTarget == 'brand';
    final showMinOrder = _selectedTarget == 'cart' || _selectedType == 'free_shipping';

    final categories = context.watch<CategoryProvider>().categories;
    final brands = context.watch<BrandProvider>().brands;
    final businessId = widget.businessId ?? widget.offer?.businessId;

    final filteredCategories = categories.where((c) {
      if (businessId == null || businessId.isEmpty) return true;
      return c.businessIds.contains(businessId);
    }).toList();

    final filteredBrands = brands.where((b) {
      if (businessId == null || businessId.isEmpty) return true;
      return b.businessIds.contains(businessId);
    }).toList();

    return AddEditTemplate(
      title: isEdit
          ? 'تعديل العرض التسويقي'
          : TranslationKeys.addNewOffer.tr(context),
      subtitle: isEdit
          ? 'تعديل بيانات ونسبة العرض والكوبون الحالي'
          : 'إدخال بيانات الحملة التسويقية أو كوبون الخصم الجديد',
      isEditMode: isEdit,
      formKey: _formKey,
      submitLabel: isEdit
          ? TranslationKeys.saveChanges.tr(context)
          : TranslationKeys.addNewOffer.tr(context),
      submitIcon: isEdit ? Icons.save_rounded : Icons.local_offer_rounded,
      onSubmit: _submit,
      isSubmitting: _isSubmitting,
      cancelLabel: TranslationKeys.cancel.tr(context),
      sections: [
        // 1. Basic Offer Info Section
        FormSection(
          title: TranslationKeys.offerMarketing.tr(context),
          subtitle: 'عنوان العرض التسويقي والمتجر التابع',
          icon: Icons.local_offer_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _titleArController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان العرض (عربي)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language, size: 20),
                    ),
                    validator: (v) => v!.isEmpty
                        ? TranslationKeys.required.tr(context)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _titleEnController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان العرض (إنجليزي)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language, size: 20),
                    ),
                    validator: (v) => v!.isEmpty
                        ? TranslationKeys.required.tr(context)
                        : null,
                  ),
                ),
              ],
            ),
            if (!isStoreOwner)
              TextFormField(
                controller: _businessIdController,
                decoration: InputDecoration(
                  labelText: TranslationKeys.associatedStore.tr(context),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.storefront_rounded, size: 20),
                ),
                validator: (v) =>
                    v!.isEmpty ? TranslationKeys.required.tr(context) : null,
              ),
          ],
        ),

        // 2. Targeting Section
        FormSection(
          title: 'مستهدف العرض والشروط',
          subtitle: 'تحديد فئة المنتجات المشمولة بالعرض والحد الأدنى للطلب',
          icon: Icons.track_changes_rounded,
          fields: [
            DropdownButtonFormField<String>(
              value: _selectedTarget,
              decoration: const InputDecoration(
                labelText: 'مستهدف العرض (Target)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.gps_fixed_rounded, size: 20),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'cart',
                  child: Text('كامل السلة/الفاتورة'),
                ),
                DropdownMenuItem(
                  value: 'category',
                  child: Text('فئة منتجات محددة (Category)'),
                ),
                DropdownMenuItem(
                  value: 'brand',
                  child: Text('علامة تجارية محددة (Brand)'),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedTarget = val!;
                  if (_selectedTarget != 'category') _selectedCategoryId = null;
                  if (_selectedTarget != 'brand') _selectedBrandId = null;
                });
              },
            ),
            if (showCategory)
              DropdownButtonFormField<String>(
                value: filteredCategories.any((cat) => cat.id == _selectedCategoryId) ? _selectedCategoryId : null,
                decoration: const InputDecoration(
                  labelText: 'اختر الفئة المشمولة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_rounded, size: 20),
                ),
                items: filteredCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.label),
                  );
                }).toList(),
                validator: (v) => showCategory && v == null
                    ? TranslationKeys.required.tr(context)
                    : null,
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              ),
            if (showBrand)
              DropdownButtonFormField<String>(
                value: filteredBrands.any((b) => b.id == _selectedBrandId) ? _selectedBrandId : null,
                decoration: const InputDecoration(
                  labelText: 'اختر العلامة التجارية المشمولة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.branding_watermark_rounded, size: 20),
                ),
                items: filteredBrands.map((brand) {
                  return DropdownMenuItem(
                    value: brand.id,
                    child: Text(brand.name),
                  );
                }).toList(),
                validator: (v) => showBrand && v == null
                    ? TranslationKeys.required.tr(context)
                    : null,
                onChanged: (val) => setState(() => _selectedBrandId = val),
              ),
            if (showMinOrder)
              TextFormField(
                controller: _minOrderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الحد الأدنى لقيمة الطلب لتفعيل العرض (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_cart_checkout_rounded, size: 20),
                ),
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final val = double.tryParse(v);
                    if (val == null || val < 0) {
                      return 'يرجى إدخال قيمة صحيحة';
                    }
                  }
                  return null;
                },
              ),
          ],
        ),

        // 3. Type & Discounts Section
        FormSection(
          title: 'نوع العرض وقيمة الخصم',
          subtitle: 'تحديد فئة الخصم ونسبته أو قيمته',
          icon: Icons.percent_rounded,
          fields: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'نوع العرض (Offer Type)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_rounded, size: 20),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'percentage_discount',
                  child: Text('خصم مئوي (%)'),
                ),
                DropdownMenuItem(
                  value: 'fixed_discount',
                  child: Text('خصم بمبلغ ثابت (\$)'),
                ),
                DropdownMenuItem(
                  value: 'coupon',
                  child: Text('كوبون خصم (Coupon)'),
                ),
                DropdownMenuItem(
                  value: 'free_shipping',
                  child: Text('شحن مجاني'),
                ),
              ],
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            if (showCouponCode || showPercent || showAmount)
              Row(
                children: [
                  if (showCouponCode)
                    Expanded(
                      child: TextFormField(
                        controller: _couponCodeController,
                        decoration: const InputDecoration(
                          labelText: 'كود الخصم (Coupon Code)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.qr_code_rounded, size: 20),
                        ),
                        validator: (v) => showCouponCode && (v == null || v.trim().isEmpty)
                            ? 'يرجى إدخال كود الخصم'
                            : null,
                      ),
                    ),
                  if (showCouponCode && (showPercent || showAmount))
                    const SizedBox(width: 16),
                  if (showPercent)
                    Expanded(
                      child: TextFormField(
                        controller: _discountPercentController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              '${TranslationKeys.discountRate.tr(context)} (%)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.percent_rounded, size: 20),
                        ),
                        validator: (v) {
                          if (!showPercent) return null;
                          if (v == null || v.trim().isEmpty) {
                            return TranslationKeys.required.tr(context);
                          }
                          final val = double.tryParse(v);
                          if (val == null || val <= 0 || val > 100) {
                            return 'يرجى إدخال نسبة صحيحة بين 0 و 100';
                          }
                          return null;
                        },
                      ),
                    ),
                  if (showAmount)
                    Expanded(
                      child: TextFormField(
                        controller: _discountAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'قيمة الخصم (\$)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money_rounded, size: 20),
                        ),
                        validator: (v) {
                          if (!showAmount) return null;
                          if (v == null || v.trim().isEmpty) {
                            return TranslationKeys.required.tr(context);
                          }
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) {
                            return 'يرجى إدخال قيمة خصم صحيحة';
                          }
                          return null;
                        },
                      ),
                    ),
                ],
              ),
            SwitchListTile(
              title: const Text('العرض مفعل (Active)'),
              subtitle: const Text('تفعيل العرض فوراً للمستخدمين في المتجر'),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
          ],
        ),
      ],
    );
  }
}
