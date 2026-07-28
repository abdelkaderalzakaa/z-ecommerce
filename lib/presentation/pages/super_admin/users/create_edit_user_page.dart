import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/fake_data/users.dart';
import 'package:z_ecommerce/data/models/user_model.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class CreateEditUserPage extends StatefulWidget {
  final UserModel? user;

  const CreateEditUserPage({super.key, this.user});

  @override
  State<CreateEditUserPage> createState() => _CreateEditUserPageState();
}

class _CreateEditUserPageState extends State<CreateEditUserPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyIdController;
  late TextEditingController _avatarUrlController;

  UserRole _selectedRole = UserRole.customer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;

    _nameController = TextEditingController(text: u?.name ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _phoneController = TextEditingController(text: u?.phoneNumber ?? '');
    _companyIdController = TextEditingController(text: u?.companyId ?? '');
    _avatarUrlController = TextEditingController(text: u?.avatarUrl ?? '');

    _selectedRole = u?.role ?? UserRole.customer;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyIdController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final isEdit = widget.user != null;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final userId = isEdit ? widget.user!.id : 'usr_${timestamp.substring(timestamp.length - 6)}';

    final updatedUser = UserModel(
      id: userId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: _selectedRole,
      phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      companyId: _selectedRole == UserRole.companyOwner && _companyIdController.text.trim().isNotEmpty
          ? _companyIdController.text.trim()
          : null,
      avatarUrl: _avatarUrlController.text.trim().isNotEmpty ? _avatarUrlController.text.trim() : null,
      createdAt: widget.user?.createdAt ?? DateTime.now(),
    );

    if (isEdit) {
      final index = fakeUsers.indexWhere((u) => u.id == userId);
      if (index != -1) {
        fakeUsers[index] = updatedUser;
      }
    } else {
      fakeUsers.insert(0, updatedUser);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'تم تحديث بيانات المستخدم بنجاح!' : 'تم إضافة المستخدم الجديد بنجاح!',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return AddEditTemplate(
      title: isEdit ? 'تعديل بيانيات المستخدم' : TranslationKeys.addNewUser.tr(context),
      subtitle: isEdit ? 'تعديل الاسم والبريد والدور والصلاحيات بالحساب' : 'إدخال بيانات الحساب الجديد والدور المطلوب في المنصة',
      isEditMode: isEdit,
      formKey: _formKey,
      submitLabel: isEdit ? TranslationKeys.saveChanges.tr(context) : TranslationKeys.addNewUser.tr(context),
      submitIcon: isEdit ? Icons.save_rounded : Icons.person_add_alt_1_rounded,
      onSubmit: _submit,
      isSubmitting: _isSubmitting,
      cancelLabel: TranslationKeys.cancel.tr(context),
      sections: [
        // 1. Account Info Section
        FormSection(
          title: TranslationKeys.accountInformation.tr(context),
          subtitle: 'الاسم الكامل، البريد الإلكتروني ورقم الهاتف',
          icon: Icons.person_rounded,
          fields: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: TranslationKeys.user.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.email.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    ),
                    validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.phone.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // 2. Role & Permissions Section
        FormSection(
          title: 'الدور والصلاحيات في المنصة',
          subtitle: 'تحديد نوع حساب المستخدم وصلاحياته',
          icon: Icons.admin_panel_settings_rounded,
          fields: [
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: TranslationKeys.role.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.shield_outlined, size: 20),
              ),
              items: [
                DropdownMenuItem(
                  value: UserRole.customer,
                  child: Text(TranslationKeys.customerRole.tr(context)),
                ),
                DropdownMenuItem(
                  value: UserRole.companyOwner,
                  child: Text(TranslationKeys.storeOwnerRole.tr(context)),
                ),
                DropdownMenuItem(
                  value: UserRole.superAdmin,
                  child: Text(TranslationKeys.superAdminRole.tr(context)),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedRole = val);
                }
              },
            ),
            if (_selectedRole == UserRole.companyOwner) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyIdController,
                decoration: InputDecoration(
                  labelText: '${TranslationKeys.associatedStore.tr(context)} (رمز المتجر ID)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.storefront_rounded, size: 20),
                ),
              ),
            ],
          ],
        ),

        // 3. Avatar Section
        FormSection(
          title: 'الصورة الشخصية',
          subtitle: 'رابط الصورة الشخصية للحساب',
          icon: Icons.image_rounded,
          fields: [
            TextFormField(
              controller: _avatarUrlController,
              decoration: const InputDecoration(
                labelText: 'رابط الصورة الشخصية (Avatar URL)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link_rounded, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
