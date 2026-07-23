import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/company_settings_model.dart';
import 'package:z_ecommerce/data/models/user_model.dart';
import 'package:z_ecommerce/data/models/localized_string.dart';
import 'package:z_ecommerce/data/providers/super_admin_stores_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class CreateStorePage extends StatefulWidget {
  const CreateStorePage({super.key});

  @override
  State<CreateStorePage> createState() => _CreateStorePageState();
}

class _CreateStorePageState extends State<CreateStorePage> {
  final _formKey = GlobalKey<FormState>();

  // Store Info Controllers
  final _storeNameEnController = TextEditingController();
  final _storeNameArController = TextEditingController();
  final _categoryController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  // Owner Info Controllers
  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerPasswordController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<SuperAdminStoresProvider>();

    // Generate IDs
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final storeId = 'cmp_${timestamp.substring(timestamp.length - 8)}';
    final ownerId = 'usr_${timestamp.substring(timestamp.length - 8)}';

    final newStore = CompanySettingsModel(
      id: storeId,
      name: LocalizedString(
        en: _storeNameEnController.text,
        ar: _storeNameArController.text,
      ),
      category: StoreCategoryModel(
        id: 'cat_1',
        name: LocalizedString(
          en: _categoryController.text,
          ar: _categoryController.text,
        ),
      ),
      slogan: LocalizedString(en: '', ar: ''),
      description: LocalizedString(en: '', ar: ''),
      footerDescription: LocalizedString(en: '', ar: ''),
      theme: const StoreTheme(
        primaryColor: '#000000',
        secondaryColor: '#FFFFFF',
      ),
      brands: [],
      currency: 'USD',
      deliveryFee: 0.0,
      aboutUs: LocalizedString(en: '', ar: ''),
      termsAndConditions: LocalizedString(en: '', ar: ''),
      privacyPolicy: LocalizedString(en: '', ar: ''),
      socials: [],
      contactEmail: _contactEmailController.text,
      contactPhone: _contactPhoneController.text,
      createdAt: DateTime.now(),
      status: 'Active',
    );

    final newOwner = UserModel(
      id: ownerId,
      name: _ownerNameController.text,
      email: _ownerEmailController.text,
      role: UserRole.companyOwner,
      companyId: storeId,
      phoneNumber: _contactPhoneController.text,
      createdAt: DateTime.now(),
    );

    final success = await provider.createStoreAndOwner(
      newStore: newStore,
      newOwner: newOwner,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TranslationKeys.storeCreatedSuccessfully.tr(context))),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? TranslationKeys.errorCreatingStore.tr(context))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddEditTemplate(
      title: TranslationKeys.createNewStore.tr(context),
      subtitle: TranslationKeys.createNewStoreSubtitle.tr(context),
      isEditMode: false,
      formKey: _formKey,
      submitLabel: TranslationKeys.createStoreAndOwner.tr(context),
      submitIcon: Icons.storefront_rounded,
      onSubmit: _submit,
      isSubmitting: _isSubmitting,
      cancelLabel: TranslationKeys.cancel.tr(context),
      sections: [
        // Section 1: Store Information
        FormSection(
          title: TranslationKeys.storeInformation.tr(context),
          subtitle: TranslationKeys.storeInfoSubtitle.tr(context),
          icon: Icons.store_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _storeNameEnController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.storeNameEn.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.language, size: 20),
                    ),
                    validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _storeNameArController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.storeNameAr.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.language, size: 20),
                    ),
                    validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: TranslationKeys.category.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category_rounded, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _contactEmailController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.storeContactEmail.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _contactPhoneController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.storeContactPhone.tr(context),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Section 2: Owner Account Information
        FormSection(
          title: TranslationKeys.ownerAccountInfo.tr(context),
          subtitle: TranslationKeys.ownerAccountSubtitle.tr(context),
          icon: Icons.person_rounded,
          fields: [
            TextFormField(
              controller: _ownerNameController,
              decoration: InputDecoration(
                labelText: TranslationKeys.ownerFullName.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
            TextFormField(
              controller: _ownerEmailController,
              decoration: InputDecoration(
                labelText: TranslationKeys.ownerLoginEmail.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
            TextFormField(
              controller: _ownerPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: TranslationKeys.ownerPassword.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              ),
              validator: (v) =>
                  v!.length < 6 ? TranslationKeys.minChars.tr(context) : null,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _storeNameEnController.dispose();
    _storeNameArController.dispose();
    _categoryController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPasswordController.dispose();
    super.dispose();
  }
}
