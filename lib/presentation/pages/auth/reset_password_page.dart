import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/pages/auth/auth_success_page.dart';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/translate/localized_string.dart';
import '../../widgets/auth/auth_split_layout.dart';
import '../../widgets/auth/password_field.dart';
import '../../widgets/auth/primary_auth_button.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || password != confirmPassword) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updatePassword(password);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        changeScreen(
          context,
          AuthSuccessPage(
            title: TranslationKeys.passwordReset.tr(context),
            message: TranslationKeys.passwordResetSuccessMessage.tr(context),
            buttonLabel: TranslationKeys.continueToLogin.tr(context),
          ),
        );
      } else {
        setState(() {
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthSplitLayout(
      pageTitle: const LocalizedString(
        ar: 'تعيين كلمة مرور جديدة',
        en: 'Set new password',
      ),
      pageSubtitle: const LocalizedString(
        ar: 'يجب أن تكون كلمة المرور الجديدة مختلفة عن السابقة.',
        en: 'Your new password must be different from previously used passwords.',
      ),
      children: [
        PasswordField(
          controller: _passwordController,
          label: TranslationKeys.password.tr(context),
          hintText: TranslationKeys.mustBeAtLeast8.tr(context),
        ),
        const SizedBox(height: 20),
        PasswordField(
          controller: _confirmPasswordController,
          label: TranslationKeys.confirmPassword.tr(context),
          hintText: TranslationKeys.mustBeAtLeast8.tr(context),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: PrimaryAuthButton(
            label: TranslationKeys.resetPassword.tr(context),
            onPressed: _handleReset,
            isLoading: _isLoading,
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: ButtonApp(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icons.arrow_back,
            label: TranslationKeys.backToLogin.tr(context),
          ),
        ),
      ],
    );
  }
}
