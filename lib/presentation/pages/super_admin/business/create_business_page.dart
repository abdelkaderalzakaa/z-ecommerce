import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/models/store/currency_store.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';
import 'package:z_ecommerce/data/services/user_service.dart';

class CreateBusinessPage extends StatefulWidget {
  const CreateBusinessPage({super.key});

  @override
  State<CreateBusinessPage> createState() => _CreateBusinessPageState();
}

class _CreateBusinessPageState extends State<CreateBusinessPage> {
  final _formKey = GlobalKey<FormState>();

  // Store Info Controllers
  final _storeNameEnController = TextEditingController();
  final _storeNameArController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  // Owner Info Controllers
  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerPasswordController = TextEditingController();

  // Business type selection
  BusinessType _selectedBusinessType = BusinessType.retailStore;

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final businessProvider = context.read<BusinessProvider>();
    final userService = UserService();

    // Generate IDs
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final storeId = 'cmp_${timestamp.substring(timestamp.length - 8)}';

    try {
      // Create owner account in Firebase Auth
      final ownerId = await userService.createNewAuthUserWithoutLoggingOut(
        _ownerEmailController.text.trim(),
        _ownerPasswordController.text.trim(),
      );

      if (ownerId == null) {
        throw Exception(TranslationKeys.errorCreatingStore.tr(context));
      }

      // بناء UserModel للمالك باستخدام الـ UID الصحيح
      final newOwner = UserModel(
        id: ownerId,
        name: _ownerNameController.text.trim(),
        email: _ownerEmailController.text.trim(),
        role: UserRole.businessOwner,
        businessId: storeId,
        phoneNumber: _contactPhoneController.text.trim(),
        createdAt: DateTime.now(),
      );

      // بناء LocalizationAdmin للمتجر
      final localization = LocalizationAdmin(
        name: LocalizedString(
          en: _storeNameEnController.text.trim(),
          ar: _storeNameArController.text.trim(),
        ),
        slogan: const LocalizedString(en: '', ar: ''),
        description: const LocalizedString(en: '', ar: ''),
        footerDescription: const LocalizedString(en: '', ar: ''),
        aboutUs: const LocalizedString(en: '', ar: ''),
        termsAndConditions: const LocalizedString(en: '', ar: ''),
        privacyPolicy: const LocalizedString(en: '', ar: ''),
      );

      // بناء CurrencyStore
      final currency = CurrencyStore(
        id: 'curr_usd',
        code: 'USD',
        symbol: '\$',
        name: 'US Dollar',
        exchangeRate: 1.0,
        isPrimary: true,
      );

      final newStore = BusinessModel(
        id: storeId,
        owner: newOwner,
        businessType: _selectedBusinessType,
        theme: const ThemeAdmin(
          primaryColor: '#000000',
          secondaryColor: '#FFFFFF',
          backgroundColor: '#F9FAFB',
          surfaceColor: '#FFFFFF',
          textColor: '#111827',
          fontFamily: 'Cairo',
          fontScale: 1.0,
          buttonRadius: 12.0,
          cardRadius: 16.0,
          inputRadius: 10.0,
        ),
        localization: localization,
        currency: currency,
        status: 'Active',
        createdAt: DateTime.now(),
      );

      await businessProvider.saveBusiness(newStore);
      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TranslationKeys.storeCreatedSuccessfully.tr(context)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              businessProvider.errorMessage ?? e.toString(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                    validator: (v) =>
                        v!.isEmpty ? TranslationKeys.required.tr(context) : null,
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
                    validator: (v) =>
                        v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<BusinessType>(
              value: _selectedBusinessType,
              decoration: InputDecoration(
                labelText: TranslationKeys.category.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category_rounded, size: 20),
              ),
              items: BusinessType.values.map((type) {
                return DropdownMenuItem<BusinessType>(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedBusinessType = val);
              },
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
              validator: (v) =>
                  v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
            TextFormField(
              controller: _ownerEmailController,
              decoration: InputDecoration(
                labelText: TranslationKeys.ownerLoginEmail.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
              ),
              validator: (v) =>
                  v!.isEmpty ? TranslationKeys.required.tr(context) : null,
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
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPasswordController.dispose();
    super.dispose();
  }
}
