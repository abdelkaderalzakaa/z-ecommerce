import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class PlatformSettingsPage extends StatefulWidget {
  const PlatformSettingsPage({super.key});

  @override
  State<PlatformSettingsPage> createState() => _PlatformSettingsPageState();
}

class _PlatformSettingsPageState extends State<PlatformSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _platformNameArController;
  late TextEditingController _platformNameEnController;
  late TextEditingController _commissionRateController;
  late TextEditingController _contactEmailController;
  late TextEditingController _supportPhoneController;
  late TextEditingController _currencyController;

  bool _isMaintenanceMode = false;
  bool _isSubmitting = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _platformNameArController = TextEditingController(text: 'منصة الزكاة الرقمية');
    _platformNameEnController = TextEditingController(text: 'Alzaka Digital Platform');
    _commissionRateController = TextEditingController(text: '5.0');
    _contactEmailController = TextEditingController(text: 'alzakaasimplesolutions@gmail.com');
    _supportPhoneController = TextEditingController(text: '+961 70 123 456');
    _currencyController = TextEditingController(text: 'USD');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = context.watch<AuthProvider>().currentUser;
      if (user != null) {
        if (user.email.isNotEmpty) {
          _contactEmailController.text = user.email;
        }
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
          _supportPhoneController.text = user.phoneNumber!;
        }
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _platformNameArController.dispose();
    _platformNameEnController.dispose();
    _commissionRateController.dispose();
    _contactEmailController.dispose();
    _supportPhoneController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 600));

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ إعدادات المنصة العامة بنجاح!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddEditTemplate(
      title: 'إعدادات المنصة العامة',
      subtitle: 'التحكم في اسم المنصة، نسبة العمولة، وإعدادات الصيانة العالمية',
      isEditMode: true,
      formKey: _formKey,
      submitLabel: TranslationKeys.saveChanges.tr(context),
      submitIcon: Icons.save_rounded,
      onSubmit: _submit,
      isSubmitting: _isSubmitting,
      cancelLabel: TranslationKeys.cancel.tr(context),
      sections: [
        // 1. Identity Section
        FormSection(
          title: 'هوية واسم المنصة العامة',
          subtitle: 'الاسم المعروض للنظام باللغتين والعملة الرئيسية',
          icon: Icons.language_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _platformNameArController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المنصة (عربي)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business_rounded, size: 20),
                    ),
                    validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _platformNameEnController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المنصة (إنجليزي)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business_rounded, size: 20),
                    ),
                    validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _currencyController,
              decoration: InputDecoration(
                labelText: TranslationKeys.currency.tr(context),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
          ],
        ),

        // 2. Financial Commissions Section
        FormSection(
          title: 'المالية والعمولات العامة',
          subtitle: 'تحديد نسبة اقتطاع العمولة الافتراضية على المتاجر',
          icon: Icons.monetization_on_rounded,
          fields: [
            TextFormField(
              controller: _commissionRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'نسبة عمولة المنصة (%)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.percent_rounded, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
          ],
        ),

        // 3. Contact & Support Section
        FormSection(
          title: 'معلومات الدعم والاتصال الإداري',
          subtitle: 'بيانات التواصل الفني الموجهة لمدراء المتاجر',
          icon: Icons.support_agent_rounded,
          fields: [
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
                    controller: _supportPhoneController,
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

        // 4. System Status Section
        FormSection(
          title: 'حالة المنصة وضبط الصيانة',
          subtitle: 'تفعيل أو إيقاف وضع الصيانة العالمي',
          icon: Icons.build_circle_rounded,
          fields: [
            SwitchListTile(
              title: const Text('وضع الصيانة العام (Maintenance Mode)'),
              subtitle: const Text('إظهار شاشة الصيانة وإغلاق استقبال الطلبات مؤقتاً'),
              value: _isMaintenanceMode,
              onChanged: (val) => setState(() => _isMaintenanceMode = val),
            ),
          ],
        ),
      ],
    );
  }
}
