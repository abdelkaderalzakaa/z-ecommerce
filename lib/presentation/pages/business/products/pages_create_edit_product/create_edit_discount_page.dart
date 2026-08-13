import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/discount_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';

class CreateEditDiscountPage extends StatefulWidget {
  final ProductModel product;
  final DiscountModel? discount;

  const CreateEditDiscountPage({super.key, required this.product, this.discount});

  @override
  State<CreateEditDiscountPage> createState() => _CreateEditDiscountPageState();
}

class _CreateEditDiscountPageState extends State<CreateEditDiscountPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _valueController;
  late TextEditingController _descriptionController;

  String _selectedType = 'product';
  bool _isPercentage = true;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isSubmitting = false;

  final List<Map<String, String>> _discountTypes = [
    {'value': 'product', 'label': 'خصم منتج محدد'},
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.discount;
    _nameController = TextEditingController(text: d?.name ?? '');
    _valueController = TextEditingController(text: d != null ? d.value.toString() : '');
    _descriptionController = TextEditingController(text: d?.description ?? '');
    _selectedType = d?.type ?? 'product';
    _isPercentage = d?.isPercentage ?? true;
    _startDate = d?.startDate;
    _endDate = d?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
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

  bool _hasOverlappingDiscount(DiscountModel newDiscount) {
    final startA = newDiscount.startDate ?? DateTime(1970);
    final endA = newDiscount.endDate ?? DateTime(2100);

    for (final d in widget.product.discounts) {
      if (widget.discount != null && d.id == widget.discount!.id) {
        continue;
      }
      if (!d.isActive) continue;

      final startB = d.startDate ?? DateTime(1970);
      final endB = d.endDate ?? DateTime(2100);

      final latestStart = startA.isAfter(startB) ? startA : startB;
      final earliestEnd = endA.isBefore(endB) ? endA : endB;

      if (latestStart.isBefore(earliestEnd)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<ProductProvider>();
    final isEdit = widget.discount != null;

    final id = isEdit ? widget.discount!.id : 'disc_${DateTime.now().millisecondsSinceEpoch}';
    final newDiscount = DiscountModel(
      id: id,
      name: _nameController.text.trim(),
      type: _selectedType,
      value: double.tryParse(_valueController.text) ?? 0.0,
      isPercentage: _isPercentage,
      startDate: _startDate,
      endDate: _endDate,
      productId: widget.product.id,
      isActive: true, // Always true, status computed by period
      description: _descriptionController.text.trim(),
    );

    if (_hasOverlappingDiscount(newDiscount)) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('عذراً، يوجد خصم آخر نشط يتعارض مع الفترة المحددة لهذا المنتج.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final List<DiscountModel> updatedDiscounts = List<DiscountModel>.from(widget.product.discounts);
    if (isEdit) {
      final index = updatedDiscounts.indexWhere((d) => d.id == widget.discount!.id);
      if (index != -1) {
        updatedDiscounts[index] = newDiscount;
      }
    } else {
      updatedDiscounts.add(newDiscount);
    }

    final updatedProduct = widget.product.copyWith(discounts: updatedDiscounts);
    await provider.updateProduct(updatedProduct);

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'تم تحديث الخصم بنجاح!' : 'تم إضافة الخصم بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.discount != null;
    final theme = Theme.of(context);
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل الخصم للمنتج' : 'إضافة خصم جديد للمنتج'),
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
                      // Mandatory Product Card at the top
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
                          labelText: 'اسم الخصم (مثال: خصم الصيف المحدود)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.bookmark_border_rounded),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? TranslationKeys.required.tr(context)
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Discount Type & Percentage Dropdowns
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'نوع الخصم',
                                border: OutlineInputBorder(),
                              ),
                              items: _discountTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type['value'],
                                  child: Text(type['label']!),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedType = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<bool>(
                              value: _isPercentage,
                              decoration: const InputDecoration(
                                labelText: 'شكل القيمة',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: true, child: Text('نسبة مئوية (%)')),
                                DropdownMenuItem(value: false, child: Text('قيمة ثابتة (\$')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _isPercentage = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Value input
                      TextFormField(
                        controller: _valueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: _isPercentage ? 'قيمة الخصم المئوية (%)' : 'مبلغ الخصم الثابت (\$)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.percent),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? TranslationKeys.required.tr(context)
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Start and End Date selection (Two separate buttons)
                      const Text(
                        'فترة صلاحية الخصم وتوقيته',
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
                      const SizedBox(height: 24),

                      // Description input
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'وصف إضافي أو شروط للخصم (اختياري)',
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
