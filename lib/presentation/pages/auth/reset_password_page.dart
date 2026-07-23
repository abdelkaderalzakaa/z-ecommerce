import 'package:z_ecommerce/presentation/pages/auth/auth_success_page.dart';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_auth.dart';
import '../../../data/providers/company_provider.dart';
import '../../widgets/common/headers/header_home.dart';
import '../../widgets/common/footer_section.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/password_field.dart';
import '../../widgets/auth/primary_auth_button.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _isLoading = false;

  void _handleReset() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        changeScreen(context, AuthSuccessPage(
          title: TranslationKeys.passwordReset.tr(context),
          message: TranslationKeys.passwordResetSuccessMessage.tr(context),
          buttonLabel: TranslationKeys.continueToLogin.tr(context),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderAuth(title: TranslationKeys.setNewPassword.tr(context)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthCard(
              subtitle: TranslationKeys.newPasswordMustBeDifferent.tr(context),
              children: [
                PasswordField(
                  label: TranslationKeys.password.tr(context),
                  hintText: TranslationKeys.mustBeAtLeast8.tr(context),
                ),
                const SizedBox(height: 24),
                PasswordField(
                  label: TranslationKeys.confirmPassword.tr(context),
                  hintText: TranslationKeys.bothPasswordsMustMatch.tr(context),
                ),
                const SizedBox(height: 32),
                PrimaryAuthButton(
                  label: TranslationKeys.resetPassword.tr(context),
                  onPressed: _handleReset,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Back to forgot password
                      },
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: Text(TranslationKeys.backToLogin.tr(context)),
                    ),
                  ],
                ),
              ],
            ),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}
