import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/constants/payment_methods_constant.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class StoreManagePaymentMethodsPage extends StatefulWidget {
  final BusinessModel store;

  const StoreManagePaymentMethodsPage({super.key, required this.store});

  @override
  State<StoreManagePaymentMethodsPage> createState() => _StoreManagePaymentMethodsPageState();
}

class _StoreManagePaymentMethodsPageState extends State<StoreManagePaymentMethodsPage> {
  final _formKey = GlobalKey<FormState>();

  late bool _enableCod;
  late bool _enableWish;
  late bool _enableOmt;

  late TextEditingController _wishPhoneController;
  late TextEditingController _omtPhoneController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final methods = widget.store.paymentMethods;
    _enableCod = methods.contains(PaymentMethodType.cashOnDelivery);
    _enableWish = methods.contains(PaymentMethodType.wishMoney);
    _enableOmt = methods.contains(PaymentMethodType.omt);

    final socials = widget.store.socials;

    String getSocialUrl(String keyword) {
      for (final s in socials) {
        if (s.title.ar.contains(keyword) || s.title.en.toLowerCase().contains(keyword.toLowerCase())) {
          return s.url;
        }
      }
      return '';
    }

    _wishPhoneController = TextEditingController(text: getSocialUrl('ويش').isNotEmpty ? getSocialUrl('ويش') : getSocialUrl('Wish'));
    _omtPhoneController = TextEditingController(text: getSocialUrl('OMT').isNotEmpty ? getSocialUrl('OMT') : getSocialUrl('أوم تي'));
  }

  @override
  void dispose() {
    _wishPhoneController.dispose();
    _omtPhoneController.dispose();
    super.dispose();
  }

  Future<void> _savePaymentMethods() async {
    if (_enableWish && _wishPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى أدخال رقم الهاتف الخاص بتحويل ويش ماني (Wish Money)')),
      );
      return;
    }

    if (_enableOmt && _omtPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى أدخال رقم الهاتف الخاص بتحويل OMT')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<BusinessProvider>();
    final currentStore = provider.businesses.firstWhere(
      (b) => b.id == widget.store.id,
      orElse: () => widget.store,
    );

    final List<PaymentMethodType> updatedMethods = [];
    if (_enableCod) updatedMethods.add(PaymentMethodType.cashOnDelivery);
    if (_enableWish) updatedMethods.add(PaymentMethodType.wishMoney);
    if (_enableOmt) updatedMethods.add(PaymentMethodType.omt);

    // Update socials to persist transfer phone numbers
    List<SocialModel> updatedSocials = List.from(currentStore.socials);

    // Filter out old Wish / OMT entries if any
    updatedSocials = updatedSocials.where((s) => !s.title.ar.contains('ويش') && !s.title.ar.contains('OMT') && !s.title.en.contains('Wish')).toList();

    if (_enableWish && _wishPhoneController.text.trim().isNotEmpty) {
      updatedSocials.add(
        SocialModel(
          title: const LocalizedString(ar: 'تحويل ويش ماني (Wish)', en: 'Wish Money Transfer'),
          url: _wishPhoneController.text.trim(),
          icon: 'wish',
          color: Colors.purple,
          platform: SocialPlatform.contactPhoneFirst,
          isVisible: true,
        ),
      );
    }

    if (_enableOmt && _omtPhoneController.text.trim().isNotEmpty) {
      updatedSocials.add(
        SocialModel(
          title: const LocalizedString(ar: 'تحويل OMT', en: 'OMT Transfer'),
          url: _omtPhoneController.text.trim(),
          icon: 'omt',
          color: Colors.orange,
          platform: SocialPlatform.contactPhoneSecond,
          isVisible: true,
        ),
      );
    }

    final updatedStore = currentStore.copyWith(
      paymentMethods: updatedMethods,
      socials: updatedSocials,
    );

    await provider.saveBusiness(updatedStore);

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ وتحديث طرق الدفع وأرقام التحويل المعتمدة بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final businessProvider = context.watch<BusinessProvider>();
    final currentStore = businessProvider.businesses.firstWhere(
      (b) => b.id == widget.store.id,
      orElse: () => widget.store,
    );

    return AddEditTemplate(
      title: isAr ? 'إدارة وتحديث طرق الدفع المتاحة للمتجر' : 'Manage Store Payment Methods',
      subtitle: isAr ? 'تحديد طرق الدفع الثلاث المعتمدة ورقم هاتف تحويل الأموال لـ (${currentStore.localization.name.get(context)})' : 'Configure the 3 payment options & transfer phone numbers',
      formKey: _formKey,
      isSubmitting: _isSubmitting,
      isEditMode: true,
      submitLabel: isAr ? 'حفظ وتطبيق طرق الدفع' : 'Save Payment Options',
      onSubmit: _savePaymentMethods,
      sections: [
        FormSection(
          title: isAr ? 'طرق الدفع الثلاث المعتمدة للمتجر' : 'Store Payment Methods (3 Options)',
          icon: Icons.payments_rounded,
          fields: [
            // METHOD 1: COD
            Card(
              margin: const EdgeInsets.only(bottom: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _enableCod ? theme.primaryColor.withOpacity(0.4) : theme.dividerColor.withOpacity(0.15),
                  width: _enableCod ? 1.5 : 1.0,
                ),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (_enableCod ? theme.primaryColor : Colors.grey).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: _enableCod ? theme.primaryColor : Colors.grey,
                  ),
                ),
                title: Text(
                  isAr ? '1️⃣ الدفع عند الاستلام (COD)' : '1️⃣ Cash on Delivery (COD)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isAr ? 'يتيح للعميل الدفع نقداً عند استلام الطلبية على باب المنزل.' : 'Allows customers to pay cash upon order delivery.',
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                  ),
                ),
                value: _enableCod,
                onChanged: (val) => setState(() => _enableCod = val),
              ),
            ),

            // METHOD 2: WISH MONEY
            Card(
              margin: const EdgeInsets.only(bottom: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _enableWish ? Colors.purple.withOpacity(0.4) : theme.dividerColor.withOpacity(0.15),
                  width: _enableWish ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (_enableWish ? Colors.purple : Colors.grey).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: _enableWish ? Colors.purple : Colors.grey,
                      ),
                    ),
                    title: Text(
                      isAr ? '2️⃣ تحويل ويش ماني (Wish Money)' : '2️⃣ Wish Money Transfer',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        isAr ? 'يتطلب إدخال رقم الهاتف المحول عليه ليتسنى للعميل تحويل قيمة الطلب عبر ويش ماني.' : 'Requires entering recipient phone number for Wish Money transfers.',
                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                      ),
                    ),
                    value: _enableWish,
                    onChanged: (val) => setState(() => _enableWish = val),
                  ),
                  if (_enableWish)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: AuthTextField(
                        controller: _wishPhoneController,
                        label: isAr ? 'رقم الهاتف المحول عليه لـ Wish Money' : 'Wish Money Transfer Phone',
                        hintText: isAr ? 'مثال: +96170000000 أو +9647700000000' : 'e.g. +96170000000',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                ],
              ),
            ),

            // METHOD 3: OMT
            Card(
              margin: const EdgeInsets.only(bottom: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _enableOmt ? Colors.orange.withOpacity(0.4) : theme.dividerColor.withOpacity(0.15),
                  width: _enableOmt ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (_enableOmt ? Colors.orange : Colors.grey).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.payments_outlined,
                        color: _enableOmt ? Colors.orange : Colors.grey,
                      ),
                    ),
                    title: Text(
                      isAr ? '3️⃣ تحويل أوم تي (OMT Transfer)' : '3️⃣ OMT Pay Transfer',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        isAr ? 'يتطلب إدخال رقم الهاتف/اسم المحول عليه ليتسنى للعميل التحويل عبر OMT.' : 'Requires entering recipient phone number/details for OMT transfers.',
                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                      ),
                    ),
                    value: _enableOmt,
                    onChanged: (val) => setState(() => _enableOmt = val),
                  ),
                  if (_enableOmt)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: AuthTextField(
                        controller: _omtPhoneController,
                        label: isAr ? 'رقم الهاتف المحول عليه لـ OMT' : 'OMT Transfer Phone',
                        hintText: isAr ? 'مثال: +96170000000 أو +9647700000000' : 'e.g. +96170000000',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
