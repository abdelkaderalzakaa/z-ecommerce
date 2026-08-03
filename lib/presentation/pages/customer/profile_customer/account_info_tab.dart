import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import '../../../../../data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry_page.dart';

class AccountInfoTab extends StatefulWidget {
  const AccountInfoTab({super.key});

  @override
  State<AccountInfoTab> createState() => _AccountInfoTabState();
}

class _AccountInfoTabState extends State<AccountInfoTab> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize data after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        final nameParts = user.name.split(' ');
        _firstNameController.text = nameParts.first;
        _lastNameController.text = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber;
      }
    });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationKeys.profileUpdatedSuccessfully.tr(context)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.accountInformation.tr(context),
          style: AppTextStyles.heroTitle(context, isMobile).copyWith(
            fontSize: 24,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          TranslationKeys.updateYourPersonalInfo.tr(context),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        const SizedBox(height: 32),

        // Form
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                controller: _firstNameController,
                label: TranslationKeys.firstName.tr(context),
                hintText: TranslationKeys.enterYourFirstName.tr(context),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: AuthTextField(
                controller: _lastNameController,
                label: TranslationKeys.lastName.tr(context),
                hintText: TranslationKeys.enterYourLastName.tr(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AuthTextField(
          controller: _emailController,
          label: TranslationKeys.emailAddress.tr(context),
          hintText: TranslationKeys.enterYourEmail.tr(context),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        AuthTextField(
          controller: _phoneController,
          label: TranslationKeys.phoneNumber.tr(context),
          hintText: TranslationKeys.enterYourPhoneNumber.tr(context),
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 48),

        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SaveButton(onTap: _saveChanges),
                  const SizedBox(height: 16),
                  _LogoutButton(isMobile: isMobile),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _LogoutButton(isMobile: isMobile),
                  const SizedBox(width: 16),
                  _SaveButton(onTap: _saveChanges),
                ],
              ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      ),
      child: Text(
        TranslationKeys.saveChanges.tr(context),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool isMobile;

  const _LogoutButton({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    Widget buildBtn(Widget child) {
      if (isMobile) {
        return Expanded(child: child);
      }
      return SizedBox(width: 150, child: child);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildBtn(
          OutlinedButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              changeScreenReplacement(context, const BusinessEntryPage());
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: Text(
              TranslationKeys.logout.tr(context),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 12),
        buildBtn(
          ElevatedButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('حذف الحساب'),
                  content: const Text(
                    'هل أنت تأكد من أنك تريد حذف حسابك نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'حذف الحساب',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                final success = await context.read<AuthProvider>().deleteAccount();
                if (success && context.mounted) {
                  changeScreenReplacement(context, const BusinessEntryPage());
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'حذف الحساب',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

