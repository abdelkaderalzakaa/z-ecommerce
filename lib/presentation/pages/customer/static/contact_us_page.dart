import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/global/theme/app_text_styles.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_details.dart';

class ContactUsPage extends StatefulWidget {
  final bool useAdminTheme;
  const ContactUsPage({super.key, this.useAdminTheme = true});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;
  bool _sentSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _sentSuccess = false;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isSending = false;
        _sentSuccess = true;
        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final isGlobal = selectedBusiness.id.isEmpty;
    final superAdminProvider = context.watch<SuperAdminProvider>();
    final superAdmin = superAdminProvider.currentSuperAdmin;

    String? contactEmail;
    String? contactPhone;
    String? contactWhatsapp;
    String? contactAddress;

    if (isGlobal) {
      // Global context: Super Admin Data
      contactEmail = superAdmin?.platformSettings.email;
      contactPhone = superAdmin?.platformSettings.phone;
      contactWhatsapp = superAdmin?.platformSettings.whatsapp;
      contactAddress = superAdmin?.platformSettings.address.get(context);

      contactEmail = (contactEmail != null && contactEmail.trim().isNotEmpty) ? contactEmail : 'support@z-matajer.com';
      contactPhone = (contactPhone != null && contactPhone.trim().isNotEmpty) ? contactPhone : '+966 50 123 4567';
      contactWhatsapp = (contactWhatsapp != null && contactWhatsapp.trim().isNotEmpty) ? contactWhatsapp : '+966 50 123 4567';
      contactAddress = (contactAddress != null && contactAddress.trim().isNotEmpty) ? contactAddress : 'الرياض، المملكة العربية السعودية';
    } else {
      // Specific Business Context: Business Data (No Fallbacks)
      String? getSocialLink(SocialPlatform type) {
        for (final s in selectedBusiness.socials) {
          if (s.platform == type) return s.url;
        }
        return null;
      }

      contactEmail = getSocialLink(SocialPlatform.contactEmail);
      contactPhone = getSocialLink(SocialPlatform.contactPhoneFirst);
      contactWhatsapp = null;
      contactAddress = selectedBusiness.addAddress.firstOrNull?.getFormattedAddress(
        langCode: Localizations.localeOf(context).languageCode,
      );
    }

    final hasAnyContact = (contactEmail != null && contactEmail.trim().isNotEmpty) ||
        (contactPhone != null && contactPhone.trim().isNotEmpty) ||
        (contactWhatsapp != null && contactWhatsapp.trim().isNotEmpty) ||
        (contactAddress != null && contactAddress.trim().isNotEmpty);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.contactUs.tr(context),
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.contactUs.tr(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 36),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.primaryColor.withOpacity(0.12),
                            radius: 26,
                            child: Icon(Icons.support_agent, color: theme.primaryColor, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  TranslationKeys.contactUs.tr(context),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  TranslationKeys.contactUsDescription.tr(context),
                                  style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (!hasAnyContact && !isGlobal) ...[
                      // Empty state for store with no contact info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.contact_support_outlined, size: 48, color: theme.primaryColor.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              "لم يتم إضافة بيانات تواصل مخصصة من قبل هذا المتجر",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Content Grid: Left Contact Info Cards + Right Contact Form
                      Flex(
                        direction: isMobile ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Contact Cards Section
                          Expanded(
                            flex: isMobile ? 0 : 5,
                            child: Column(
                              children: [
                                if (contactEmail != null && contactEmail.trim().isNotEmpty) ...[
                                  _ContactCard(
                                    icon: Icons.email_outlined,
                                    title: TranslationKeys.email.tr(context),
                                    subtitle: contactEmail,
                                    color: Colors.blue,
                                    onTap: () async {
                                      final url = Uri.parse('mailto:$contactEmail');
                                      if (await canLaunchUrl(url)) await launchUrl(url);
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (contactPhone != null && contactPhone.trim().isNotEmpty) ...[
                                  _ContactCard(
                                    icon: Icons.phone_outlined,
                                    title: TranslationKeys.phone.tr(context),
                                    subtitle: contactPhone,
                                    color: AppColors.green,
                                    onTap: () async {
                                      final url = Uri.parse('tel:$contactPhone');
                                      if (await canLaunchUrl(url)) await launchUrl(url);
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (contactWhatsapp != null && contactWhatsapp.trim().isNotEmpty) ...[
                                  _ContactCard(
                                    icon: Icons.chat_rounded,
                                    title: 'واتساب (WhatsApp)',
                                    subtitle: contactWhatsapp,
                                    color: Colors.teal,
                                    onTap: () async {
                                      final url = Uri.parse('https://wa.me/$contactWhatsapp');
                                      if (await canLaunchUrl(url)) await launchUrl(url);
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (contactAddress != null && contactAddress.trim().isNotEmpty) ...[
                                  _ContactCard(
                                    icon: Icons.location_on_outlined,
                                    title: TranslationKeys.addressFallback.tr(context),
                                    subtitle: contactAddress,
                                    color: Colors.amber.shade900,
                                    onTap: () async {
                                      final addr = selectedBusiness.addAddress.firstOrNull;
                                      if (addr != null &&
                                          addr.latitude != null &&
                                          addr.longitude != null) {
                                        final url = Uri.parse(
                                          'https://www.google.com/maps/search/?api=1&query=${addr.latitude},${addr.longitude}',
                                        );
                                        if (await canLaunchUrl(url)) await launchUrl(url);
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!isMobile) const SizedBox(width: 24),

                          // Right: Interactive Contact Form Section
                          Expanded(
                            flex: isMobile ? 0 : 7,
                            child: Padding(
                              padding: EdgeInsets.only(top: isMobile ? 24 : 0),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.cardBorder),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.shadowColor.withOpacity(0.06),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "أرسل لنا رسالتك مباشرة",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (_sentSuccess) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.green.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: AppColors.green.withOpacity(0.4)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.check_circle, color: AppColors.green, size: 20),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  TranslationKeys.messageSentSuccess.tr(context),
                                                  style: const TextStyle(
                                                    color: AppColors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _FormFieldItem(
                                              controller: _nameController,
                                              label: TranslationKeys.yourName.tr(context),
                                              hint: "محمد أحمد",
                                              icon: Icons.person_outline,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _FormFieldItem(
                                              controller: _emailController,
                                              label: TranslationKeys.yourEmail.tr(context),
                                              hint: "name@domain.com",
                                              icon: Icons.email_outlined,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      _FormFieldItem(
                                        controller: _subjectController,
                                        label: TranslationKeys.messageSubject.tr(context),
                                        hint: "استفسار عن الشحن والطلبات...",
                                        icon: Icons.subtitles_outlined,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        TranslationKeys.yourMessage.tr(context),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _messageController,
                                        maxLines: 4,
                                        validator: (val) => (val == null || val.trim().isEmpty)
                                            ? TranslationKeys.requiredField.tr(context)
                                            : null,
                                        style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: isDark ? theme.colorScheme.surface : Colors.grey.shade100,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: AppColors.cardBorder),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: theme.primaryColor, width: 1.8),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      ButtonApp(
                                        isFullWidth: true,
                                        label: TranslationKeys.sendMessage.tr(context),
                                        icon: Icons.send_rounded,
                                        isLoading: _isSending,
                                        onPressed: _submitForm,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormFieldItem extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  const _FormFieldItem({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: (val) => (val == null || val.trim().isEmpty)
              ? TranslationKeys.requiredField.tr(context)
              : null,
          style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? theme.colorScheme.surface : Colors.grey.shade100,
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: theme.primaryColor.withOpacity(0.7)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
