import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/core/constants/payment_methods_constant.dart';

import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class SettingsTab extends StatelessWidget {
  final BusinessModel store;

  const SettingsTab({super.key, required this.store});

  Color _parseColor(String hexColor, Color fallback) {
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse('0x$hex'));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryThemeColor = _parseColor(
      store.theme.primaryColor,
      theme.primaryColor,
    );
    final secondaryThemeColor = _parseColor(
      store.theme.secondaryColor,
      Colors.grey,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Text(
            TranslationKeys.settingsTab.tr(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 1. Store Identity & Basic Info Card
          _buildSectionCard(
            context,
            title: 'هوية وبيانات المتجر الأساسية',
            icon: Icons.storefront_rounded,
            child: Column(
              children: [
                _buildDetailRow(
                  context,
                  'اسم المتجر (عربي)',
                  store.localization.name.ar,
                  Icons.language_rounded,
                ),
                const Divider(),
                _buildDetailRow(
                  context,
                  'اسم المتجر (إنجليزي)',
                  store.localization.name.en,
                  Icons.language_rounded,
                ),
                const Divider(),
                _buildDetailRow(
                  context,
                  TranslationKeys.category.tr(context),
                  store.category.name.get(context),
                  Icons.category_rounded,
                ),
                if (store.slogan.get(context).isNotEmpty) ...[
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'الشعار اللفظي (Slogan)',
                    store.slogan.get(context),
                    Icons.format_quote_rounded,
                  ),
                ],
                if (store.description.get(context).isNotEmpty) ...[
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'وصف المتجر',
                    store.description.get(context),
                    Icons.description_rounded,
                  ),
                ],
                if (store.footerDescription.get(context).isNotEmpty) ...[
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'وصف الفوتر',
                    store.footerDescription.get(context),
                    Icons.subtitles_rounded,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Theme, Financials & Payment Methods Card
          _buildSectionCard(
            context,
            title: 'الهوية البصرية والإعدادات المالية',
            icon: Icons.palette_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.color_lens_outlined,
                      size: 20,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'الألوان المعتمدة للثيم:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: primaryThemeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: secondaryThemeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                _buildDetailRow(
                  context,
                  TranslationKeys.currency.tr(context),
                  store.currency,
                  Icons.attach_money_rounded,
                ),
                const Divider(),
                _buildDetailRow(
                  context,
                  TranslationKeys.deliveryFee.tr(context),
                  '\$${store.deliveryFee.toStringAsFixed(2)}',
                  Icons.local_shipping_rounded,
                ),
                const Divider(),
                const SizedBox(height: 6),
                const Text(
                  'وسائل الدفع المفعلة في المتجر:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: store.paymentMethods.map((pm) {
                    String pmName;
                    switch (pm) {
                      case PaymentMethodType.cashOnDelivery:
                        pmName = TranslationKeys.paymentMethodCod.tr(context);
                        break;
                      case PaymentMethodType.wishMoney:
                        pmName = 'تحويل Wish Money';
                        break;
                      case PaymentMethodType.omt:
                        pmName = 'تحويل OMT';
                        break;
                      case PaymentMethodType.creditCard:
                        pmName = TranslationKeys.paymentMethodCreditCard.tr(
                          context,
                        );
                        break;
                      case PaymentMethodType.paypal:
                        pmName = TranslationKeys.paymentMethodPaypal.tr(
                          context,
                        );
                        break;
                    }
                    return Chip(
                      avatar: const Icon(Icons.payment_rounded, size: 16),
                      label: Text(pmName),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Contact & Social Media Links
          _buildSectionCard(
            context,
            title: 'معلومات الاتصال وقنوات التواصل الاجتماعي',
            icon: Icons.contact_phone_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  context,
                  TranslationKeys.storeContactEmail.tr(context),
                  store.contactEmail ?? 'غير محدد',
                  Icons.email_rounded,
                ),
                const Divider(),
                _buildDetailRow(
                  context,
                  TranslationKeys.storeContactPhone.tr(context),
                  store.contactPhone ?? 'غير محدد',
                  Icons.phone_rounded,
                ),
                if (store.socials.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 6),
                  const Text(
                    'حسابات التواصل الاجتماعي:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: store.socials.map((social) {
                      return Chip(
                        avatar: Icon(
                          Icons.link_rounded,
                          size: 16,
                          color: social.color,
                        ),
                        label: Text(
                          '${social.title.get(context)} (${social.link})',
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Store Addresses & Branches
          if (store.addresses != null && store.addresses!.isNotEmpty) ...[
            _buildSectionCard(
              context,
              title: 'فروع وعناوين المتجر',
              icon: Icons.location_city_rounded,
              child: Column(
                children: store.addresses!.map((addr) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      addr.address.get(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'خريطة: ${addr.linkMap} (${addr.latitude}, ${addr.longitude})',
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 5. About Us & Store Policies Card
          _buildSectionCard(
            context,
            title: 'معلومات "من نحن" والسياسات والشروط',
            icon: Icons.policy_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExpandablePolicy(
                  context,
                  'من نحن (About Us)',
                  store.aboutUs.get(context),
                ),
                const Divider(),
                _buildExpandablePolicy(
                  context,
                  TranslationKeys.termsConditions.tr(context),
                  store.termsAndConditions.get(context),
                ),
                const Divider(),
                _buildExpandablePolicy(
                  context,
                  TranslationKeys.privacyPolicy.tr(context),
                  store.privacyPolicy.get(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.textTheme.bodySmall?.color),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : 'غير محدد',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandablePolicy(
    BuildContext context,
    String title,
    String content,
  ) {
    final theme = Theme.of(context);

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            content.isNotEmpty ? content : 'لم يتم إدخال نص السياسة بعد.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
