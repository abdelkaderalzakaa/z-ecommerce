import 'package:z_ecommerce/presentation/pages/auth/auth_success_page.dart';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/theme/theme_auth.dart';
import '../../widgets/auth/auth_split_layout.dart';
import '../../widgets/auth/password_field.dart';
import '../../widgets/auth/primary_auth_button.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class ResetPasswordPage extends StatefulWidget {
  final AuthThemeConfig? customAuthTheme;

  const ResetPasswordPage({
    super.key,
    this.customAuthTheme,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

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
      setState(() => _errorMessage = TranslationKeys.passwordsDoNotMatch.tr(context));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
          _errorMessage = authProvider.errorMessage ?? 'فشل تحديث كلمة المرور';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authTheme = widget.customAuthTheme ?? const AuthThemeConfig();
    final primaryColor = authTheme.primaryColor;

    return AuthSplitLayout(
      pageTitle: authTheme.resetPasswordTitle,
      pageSubtitle: authTheme.resetPasswordSubtitle,
      customAuthTheme: authTheme,
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
            customAuthTheme: authTheme,
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, size: 16, color: primaryColor),
            label: Text(
              TranslationKeys.backToLogin.tr(context),
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
