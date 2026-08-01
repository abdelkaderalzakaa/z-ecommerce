import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/data/providers/offer_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class CreateEditOfferPage extends StatefulWidget {
  final OfferModel? offer;

  const CreateEditOfferPage({super.key, this.offer});

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

  String _selectedType = 'percentage_discount';
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final o = widget.offer;

    _titleArController = TextEditingController(text: o?.name.ar ?? '');
    _titleEnController = TextEditingController(text: o?.name.en ?? '');
    _businessIdController = TextEditingController(text: o?.businessId);
    _couponCodeController = TextEditingController(text: o?.couponCode ?? '');
    _discountPercentController = TextEditingController(
      text: o?.discountPercent != null ? o!.discountPercent.toString() : '',
    );
    _discountAmountController = TextEditingController(
      text: o?.discountAmount != null ? o!.discountAmount.toString() : '',
    );

    _selectedType = o?.type ?? 'percentage_discount';
    _isActive = o?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _businessIdController.dispose();
    _couponCodeController.dispose();
    _discountPercentController.dispose();
    _discountAmountController.dispose();
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

    final updatedOffer = OfferModel(
      id: offerId,
      businessId: _businessIdController.text.trim(),
      name: LocalizedString(
        ar: _titleArController.text.trim(),
        en: _titleEnController.text.trim(),
      ),
      type: _selectedType,
      couponCode: _couponCodeController.text.trim().isNotEmpty
          ? _couponCodeController.text.trim()
          : null,
      discountPercent: double.tryParse(_discountPercentController.text),
      discountAmount: double.tryParse(_discountAmountController.text),
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

        // 2. Type & Discounts Section
        FormSection(
          title: 'نوع العرض وقيمة الخصم',
          subtitle: 'تحديد فئة العرض، الكوبون ونسبة الخصم',
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _couponCodeController,
                    decoration: const InputDecoration(
                      labelText: 'كود الخصم (Coupon Code)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code_rounded, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _discountAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'قيمة الخصم (\$)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money_rounded, size: 20),
                    ),
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
