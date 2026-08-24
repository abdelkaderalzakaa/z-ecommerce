import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/providers/delivery_provider.dart';
import 'package:z_ecommerce/data/services/user_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';

class CreateDeliveryPage extends StatefulWidget {
  final DeliveryModel? deliveryToEdit;

  const CreateDeliveryPage({super.key, this.deliveryToEdit});

  @override
  State<CreateDeliveryPage> createState() => _CreateDeliveryPageState();
}

class _CreateDeliveryPageState extends State<CreateDeliveryPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _baseFeeController = TextEditingController();
  final _vehicleDetailsController = TextEditingController();
  final _coverageAreasController = TextEditingController();

  DeliveryEntityType _selectedType = DeliveryEntityType.company;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.deliveryToEdit != null) {
      final d = widget.deliveryToEdit!;
      _nameController.text = d.name;
      _phoneController.text = d.phone;
      _emailController.text = d.email ?? '';
      _baseFeeController.text = d.baseFee.toString();
      _vehicleDetailsController.text = d.vehicleDetails ?? '';
      _coverageAreasController.text = d.coverageAreas.join(', ');
      _selectedType = d.type;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userService = UserService();
      
      String deliveryId = '';
      
      if (widget.deliveryToEdit != null) {
        // Edit mode
        deliveryId = widget.deliveryToEdit!.id;
        final updatedDelivery = widget.deliveryToEdit!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          type: _selectedType,
          vehicleDetails: _vehicleDetailsController.text.trim(),
          coverageAreas: _coverageAreasController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          baseFee: double.tryParse(_baseFeeController.text) ?? 0.0,
          updatedAt: DateTime.now(),
        );
        await context.read<DeliveryProvider>().saveDelivery(updatedDelivery);

        // Optional: Update user model email/name if needed (assuming user service allows it easily)
      } else {
        // Create mode
        final userId = await userService.createNewAuthUserWithoutLoggingOut(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (userId == null) {
          throw Exception('فشل إنشاء حساب المستخدم للمندوب/الشركة.');
        }
        deliveryId = userId;

        // Create User Model
        final user = UserModel(
          id: userId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          role: UserRole.delivery,
          createdAt: DateTime.now(),
        );
        await userService.saveUser(user);

        // Create Delivery Model
        final delivery = DeliveryModel(
          id: deliveryId,
          name: _nameController.text.trim(),
          type: _selectedType,
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          vehicleDetails: _vehicleDetailsController.text.trim(),
          coverageAreas: _coverageAreasController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          baseFee: double.tryParse(_baseFeeController.text) ?? 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: userId,
        );
        
        await context.read<DeliveryProvider>().saveDelivery(delivery);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.deliveryToEdit == null ? 'تمت الإضافة بنجاح!' : 'تم التحديث بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _baseFeeController.dispose();
    _vehicleDetailsController.dispose();
    _coverageAreasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddEditTemplate(
      title: widget.deliveryToEdit == null ? 'إضافة جهة توصيل' : 'تعديل جهة توصيل',
      subtitle: 'إدارة تفاصيل المندوب أو شركة التوصيل وحساب الدخول الخاص بهم',
      isEditMode: widget.deliveryToEdit != null,
      formKey: _formKey,
      isSubmitting: _isSubmitting,
      submitLabel: widget.deliveryToEdit == null ? 'إنشاء' : 'حفظ التعديلات',
      onSubmit: _submit,
      sections: [
        FormSection(
          title: 'البيانات الأساسية للتوصيل',
          icon: Icons.local_shipping_outlined,
          fields: [
            Row(
              children: [
                Expanded(
                  child: RadioListTile<DeliveryEntityType>(
                    title: const Text('شركة'),
                    value: DeliveryEntityType.company,
                    groupValue: _selectedType,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<DeliveryEntityType>(
                    title: const Text('فرد/مندوب'),
                    value: DeliveryEntityType.individual,
                    groupValue: _selectedType,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'الاسم (المندوب أو الشركة)', border: OutlineInputBorder()),
              validator: (val) => val == null || val.isEmpty ? 'حقل مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'رقم الهاتف للتواصل المباشر', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
              validator: (val) => val == null || val.isEmpty ? 'حقل مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _baseFeeController,
              decoration: const InputDecoration(labelText: 'رسوم التوصيل الأساسية', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        FormSection(
          title: 'بيانات المركبة والعمل',
          icon: Icons.two_wheeler_outlined,
          fields: [
            TextFormField(
              controller: _vehicleDetailsController,
              decoration: const InputDecoration(
                labelText: 'تفاصيل المركبة (اختياري)',
                hintText: 'مثال: سيارة كامري أبيض 2020، اللوحة: abc 123',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _coverageAreasController,
              decoration: const InputDecoration(
                labelText: 'مناطق التغطية (اختياري)',
                hintText: 'مثال: الرياض, الدمام, جدة (افصل بينها بفاصلة)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        if (widget.deliveryToEdit == null)
          FormSection(
            title: 'بيانات حساب تسجيل الدخول',
            icon: Icons.lock_outline_rounded,
            fields: [
              const Text(
                'سيتم استخدام هذه البيانات لدخول المندوب أو الشركة إلى لوحة التحكم الخاصة بهم.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'حقل مطلوب';
                  if (!val.contains('@')) return 'بريد غير صالح';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder()),
                obscureText: true,
                validator: (val) => val == null || val.length < 6 ? 'يجب أن لا تقل عن 6 أحرف' : null,
              ),
            ],
          ),
      ],
    );
  }
}
