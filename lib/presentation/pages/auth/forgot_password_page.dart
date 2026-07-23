import 'package:z_ecommerce/presentation/pages/auth/reset_password_page.dart';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_auth.dart';
import '../../../data/providers/company_provider.dart';
import '../../widgets/common/headers/header_home.dart';
import '../../widgets/common/footer_section.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/primary_auth_button.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _isLoading = false;

  void _handleReset() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        changeScreen(context, const ResetPasswordPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderAuth(title: TranslationKeys.forgotPassword.tr(context)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthCard(
              subtitle: TranslationKeys.noWorriesResetInstructions.tr(context),
              children: [
                AuthTextField(
                  label: TranslationKeys.email.tr(context),
                  hintText: TranslationKeys.enterYourEmail.tr(context),
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 32),
                const SizedBox(height: 32),
                PrimaryAuthButton(
                  label: TranslationKeys.sendResetLink.tr(context),
                  onPressed: _handleReset,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Back to login
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
