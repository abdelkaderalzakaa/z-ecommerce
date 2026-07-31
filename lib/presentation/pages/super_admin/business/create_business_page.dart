import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

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

  final List<StoreCategoryModel> _platformCategories = const [
    StoreCategoryModel(
      id: 'cat_restaurants',
      name: LocalizedString(ar: 'مطاعم ومقاهي', en: 'Restaurants & Cafes'),
    ),
    StoreCategoryModel(
      id: 'cat_fashion',
      name: LocalizedString(ar: 'أزياء وملابس', en: 'Fashion & Apparel'),
    ),
    StoreCategoryModel(
      id: 'cat_electronics',
      name: LocalizedString(
        ar: 'إلكترونيات وأجهزة',
        en: 'Electronics & Gadgets',
      ),
    ),
    StoreCategoryModel(
      id: 'cat_home',
      name: LocalizedString(ar: 'المنزل والديكور', en: 'Home & Decor'),
    ),
    StoreCategoryModel(
      id: 'cat_beauty',
      name: LocalizedString(
        ar: 'عطور ومستحضرات تجميل',
        en: 'Perfumes & Beauty',
      ),
    ),
    StoreCategoryModel(
      id: 'cat_grocery',
      name: LocalizedString(
        ar: 'سوبرماركت وبقالة',
        en: 'Supermarket & Grocery',
      ),
    ),
    StoreCategoryModel(
      id: 'cat_general',
      name: LocalizedString(ar: 'خدمات ومنتجات عامة', en: 'General Services'),
    ),
  ];

  StoreCategoryModel? _selectedCategory;

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<SuperAdminProvider>();

    // Generate IDs
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final storeId = 'cmp_${timestamp.substring(timestamp.length - 8)}';
    final ownerId = 'usr_${timestamp.substring(timestamp.length - 8)}';

    final newStore = BusinessModel(
      id: storeId,
      name: LocalizedString(
        en: _storeNameEnController.text,
        ar: _storeNameArController.text,
      ),
      category: _selectedCategory ?? _platformCategories.first,
      slogan: LocalizedString(en: '', ar: ''),
      description: LocalizedString(en: '', ar: ''),
      footerDescription: LocalizedString(en: '', ar: ''),
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
      role: UserRole.businessOwner,
      businessId: storeId,
      phoneNumber: _contactPhoneController.text,
      createdAt: DateTime.now(),
    );

    final success = await provider.createStoreAndOwner(
      newStore: newStore,
      newOwner: newOwner,
      password: _ownerPasswordController.text.isNotEmpty
          ? _ownerPasswordController.text
          : 'StoreOwner123!',
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationKeys.storeCreatedSuccessfully.tr(context)),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? TranslationKeys.errorCreatingStore.tr(context),
          ),
        ),
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
                    validator: (v) => v!.isEmpty
                        ? TranslationKeys.required.tr(context)
                        : null,
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
                    validator: (v) => v!.isEmpty
                        ? TranslationKeys.required.tr(context)
                        : null,
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<StoreCategoryModel>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: TranslationKeys.category.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category_rounded, size: 20),
              ),
              items: _platformCategories.map((cat) {
                return DropdownMenuItem<StoreCategoryModel>(
                  value: cat,
                  child: Text(cat.name.get(context)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedCategory = val);
              },
              validator: (v) =>
                  v == null ? TranslationKeys.required.tr(context) : null,
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
