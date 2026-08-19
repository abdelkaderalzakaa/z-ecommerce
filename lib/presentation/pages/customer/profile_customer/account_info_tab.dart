import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';

class AccountInfoTab extends StatefulWidget {
  const AccountInfoTab({super.key});

  @override
  State<AccountInfoTab> createState() => _AccountInfoTabState();
}

class _AccountInfoTabState extends State<AccountInfoTab> {
  bool _isEditing = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final nameParts = user.name.split(' ');
      _firstNameController.text = nameParts.first;
      _lastNameController.text =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      name:
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
              .trim(),
      phoneNumber: _phoneController.text.trim(),
    );
    if (mounted && success) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationKeys.profileUpdatedSuccessfully.tr(context)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final user = context.watch<AuthProvider>().currentUser;

    final fullName = user?.name ?? '---';
    final email = user?.email ?? '---';
    final phone = user?.phoneNumber.isNotEmpty == true ? user!.phoneNumber : (isAr ? 'غير محدد' : 'Not set');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Fixed Top Account Summary Header Card (كارد علوي ثابت)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // User Avatar Circle
              CircleAvatar(
                radius: isMobile ? 26 : 30,
                backgroundColor: theme.primaryColor.withOpacity(0.12),
                child: Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // User Name, Badges & Contacts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            fullName,
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isAr ? 'حساب زبون معتمد' : 'Verified Customer',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.email_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              email,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              phone,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons: Edit Info Toggle & Logout
              if (!isMobile) ...[
                const SizedBox(width: 12),
                ButtonApp(
                  format: _isEditing ? FormatButtonApp.outline : FormatButtonApp.elevated,
                  label: _isEditing ? (isAr ? 'إلغاء' : 'Cancel') : (isAr ? 'تعديل البيانات' : 'Edit Profile'),
                  icon: _isEditing ? Icons.close : Icons.edit_outlined,
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (_isEditing) _loadUserData();
                    });
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: isAr ? 'تسجيل الخروج' : 'Logout',
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                    changeScreenReplacement(context, const BusinessEntry());
                  },
                ),
              ],
            ],
          ),
        ),

        // Mobile Buttons Row
        if (isMobile) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ButtonApp(
                  format: _isEditing ? FormatButtonApp.outline : FormatButtonApp.elevated,
                  label: _isEditing ? (isAr ? 'إلغاء' : 'Cancel') : (isAr ? 'تعديل البيانات' : 'Edit Profile'),
                  icon: _isEditing ? Icons.close : Icons.edit_outlined,
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (_isEditing) _loadUserData();
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  changeScreenReplacement(context, const BusinessEntry());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: Text(isAr ? 'خروج' : 'Logout'),
              ),
            ],
          ),
        ],

        // 2. Profile Editing Form (Toggled via Edit Button)
        if (_isEditing) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'تحديث البيانات الشخصية' : 'Update Personal Information',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _firstNameController,
                        label: TranslationKeys.firstName.tr(context),
                        hintText: TranslationKeys.enterYourFirstName.tr(context),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AuthTextField(
                        controller: _lastNameController,
                        label: TranslationKeys.lastName.tr(context),
                        hintText: TranslationKeys.enterYourLastName.tr(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _emailController,
                  label: TranslationKeys.emailAddress.tr(context),
                  hintText: TranslationKeys.enterYourEmail.tr(context),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _phoneController,
                  label: TranslationKeys.phoneNumber.tr(context),
                  hintText: TranslationKeys.enterYourPhoneNumber.tr(context),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                  child: ButtonApp(
                    onPressed: _saveChanges,
                    label: TranslationKeys.saveChanges.tr(context),
                    icon: Icons.save_outlined,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
