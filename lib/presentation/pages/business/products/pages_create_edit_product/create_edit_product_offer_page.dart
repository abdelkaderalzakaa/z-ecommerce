import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/product_offer_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';

class CreateEditProductOfferPage extends StatefulWidget {
  final ProductModel product;
  final ProductOfferModel? offer;

  const CreateEditProductOfferPage({super.key, required this.product, this.offer});

  @override
  State<CreateEditProductOfferPage> createState() => _CreateEditProductOfferPageState();
}

class _CreateEditProductOfferPageState extends State<CreateEditProductOfferPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _couponCodeController;
  late TextEditingController _minOrderController;
  late TextEditingController _descriptionController;

  // Buy X Get Y controllers
  late TextEditingController _buyQtyController;
  late TextEditingController _getQtyController;

  // Gift controllers
  late TextEditingController _giftNameController;
  late TextEditingController _giftProductIdController;

  String? _selectedBuyProductId;
  String? _selectedGetProductId;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final o = widget.offer;
    _nameController = TextEditingController(text: o?.name ?? '');
    _couponCodeController = TextEditingController(text: o?.couponCode ?? '');
    _minOrderController = TextEditingController(text: o?.minOrderAmount?.toString() ?? '');
    _descriptionController = TextEditingController(text: o?.description ?? '');

    _buyQtyController = TextEditingController(text: o?.buyQuantity?.toString() ?? '');
    _getQtyController = TextEditingController(text: o?.getQuantity?.toString() ?? '');
    _giftNameController = TextEditingController(text: o?.giftName ?? '');
    _giftProductIdController = TextEditingController(text: o?.giftProductId ?? '');

    _selectedBuyProductId = o?.buyProductId ?? widget.product.id;
    _selectedGetProductId = o?.giftProductId;
    _startDate = o?.startDate;
    _endDate = o?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _couponCodeController.dispose();
    _minOrderController.dispose();
    _descriptionController.dispose();
    _buyQtyController.dispose();
    _getQtyController.dispose();
    _giftNameController.dispose();
    _giftProductIdController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null) return null;

    if (!mounted) return date;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );
    if (time == null) return DateTime(date.year, date.month, date.day, 0, 0);

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<ProductProvider>();
    final isEdit = widget.offer != null;

    final id = isEdit ? widget.offer!.id : 'offer_${DateTime.now().millisecondsSinceEpoch}';
    
    // Resolve gift product name
    final allProducts = provider.allProducts.where((p) => p.businessId == widget.product.businessId).toList();
    String? resolvedGiftName;
    if (_selectedGetProductId != null) {
      try {
        resolvedGiftName = allProducts.firstWhere((p) => p.id == _selectedGetProductId).name;
      } catch (_) {
        resolvedGiftName = widget.offer?.giftName;
      }
    }

    final newOffer = ProductOfferModel(
      id: id,
      name: _nameController.text.trim(),
      type: 'buy_x_get_y',
      couponCode: _couponCodeController.text.trim().isEmpty ? null : _couponCodeController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      isActive: true, // Auto-computed in background based on duration
      description: _descriptionController.text.trim(),
      minOrderAmount: double.tryParse(_minOrderController.text),
      buyQuantity: int.tryParse(_buyQtyController.text),
      getQuantity: int.tryParse(_getQtyController.text),
      buyProductId: _selectedBuyProductId,
      giftProductId: _selectedGetProductId,
      giftName: resolvedGiftName,
    );

    final List<ProductOfferModel> updatedOffers = List<ProductOfferModel>.from(widget.product.offers);
    if (isEdit) {
      final index = updatedOffers.indexWhere((o) => o.id == widget.offer!.id);
      if (index != -1) {
        updatedOffers[index] = newOffer;
      }
    } else {
      updatedOffers.add(newOffer);
    }

    final updatedProduct = widget.product.copyWith(offers: updatedOffers);
    await provider.updateProduct(updatedProduct);

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'تم تحديث العرض بنجاح!' : 'تم إضافة العرض بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.offer != null;
    final theme = Theme.of(context);
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل عرض المنتج' : 'إضافة عرض جديد للمنتج'),
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

                      // Name input
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم العرض / الأوفر (مثال: اشترِ قطعتين واحصل على الثالثة مجاناً)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.celebration_rounded),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? TranslationKeys.required.tr(context)
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Buy X Get Y Product and Quantity details
                      const Text(
                        'تفاصيل عرض (اشترِ X واحصل على Y مجاناً)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Purchase Product Selector
                      DropdownButtonFormField<String>(
                        value: _selectedBuyProductId,
                        decoration: const InputDecoration(
                          labelText: 'المنتج المطلوب شراؤه (Buy X)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.shopping_bag_outlined),
                        ),
                        items: context
                            .watch<ProductProvider>()
                            .allProducts
                            .where((p) => p.businessId == widget.product.businessId)
                            .map((p) {
                          return DropdownMenuItem<String>(
                            value: p.id,
                            child: Text(p.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedBuyProductId = val;
                          });
                        },
                        validator: (v) => v == null ? 'يرجى اختيار المنتج المطلوب شراؤه' : null,
                      ),
                      const SizedBox(height: 12),

                      // Purchase quantity
                      TextFormField(
                        controller: _buyQtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'الكمية المطلوبة من المنتج السابق (X)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.onetwothree_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'مطلوب';
                          if (int.tryParse(v) == null || int.parse(v) <= 0) return 'يجب إدخال عدد أكبر من 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Free Product Selector
                      DropdownButtonFormField<String>(
                        value: _selectedGetProductId,
                        decoration: const InputDecoration(
                          labelText: 'المنتج المجاني الممنوح (Get Y)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.card_giftcard_rounded),
                        ),
                        items: context
                            .watch<ProductProvider>()
                            .allProducts
                            .where((p) => p.businessId == widget.product.businessId)
                            .map((p) {
                          return DropdownMenuItem<String>(
                            value: p.id,
                            child: Text(p.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedGetProductId = val;
                          });
                        },
                        validator: (v) => v == null ? 'يرجى اختيار المنتج المجاني الممنوح' : null,
                      ),
                      const SizedBox(height: 12),

                      // Free quantity
                      TextFormField(
                        controller: _getQtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'الكمية المجانية الممنوحة (Y)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.onetwothree_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'مطلوب';
                          if (int.tryParse(v) == null || int.parse(v) <= 0) return 'يجب إدخال عدد أكبر من 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _couponCodeController,
                              decoration: const InputDecoration(
                                labelText: 'رمز الكوبون المرتبط (اختياري)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.vpn_key_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _minOrderController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'الحد الأدنى لقيمة السلة (\$)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Start and End Date selection (Two separate buttons)
                      const Text(
                        'فترة صلاحية العرض والنشاط',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  final dt = await _pickDateTime(_startDate);
                                  if (dt != null) {
                                    setState(() => _startDate = dt);
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.play_circle_outline_rounded, size: 18, color: Colors.green),
                                          SizedBox(width: 6),
                                          Text('تاريخ ووقت البدء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _startDate != null
                                            ? '${_startDate!.toString().substring(0, 10)} ${_startDate!.toString().substring(11, 16)}'
                                            : 'حدد البدء',
                                        style: TextStyle(fontSize: 13, color: _startDate != null ? Colors.black87 : Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  final dt = await _pickDateTime(_endDate);
                                  if (dt != null) {
                                    setState(() => _endDate = dt);
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.stop_circle_outlined, size: 18, color: Colors.red),
                                          SizedBox(width: 6),
                                          Text('تاريخ ووقت الانتهاء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _endDate != null
                                            ? '${_endDate!.toString().substring(0, 10)} ${_endDate!.toString().substring(11, 16)}'
                                            : 'حدد الانتهاء',
                                        style: TextStyle(fontSize: 13, color: _endDate != null ? Colors.black87 : Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description input
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'تفاصيل شروط وتفاصيل العرض (اختياري)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action buttons
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
