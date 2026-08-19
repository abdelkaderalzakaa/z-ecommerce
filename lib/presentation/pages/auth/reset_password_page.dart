import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/auth/auth_success_page.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_split_layout.dart';
import 'package:z_ecommerce/presentation/widgets/auth/password_field.dart';
import 'package:z_ecommerce/presentation/widgets/auth/primary_auth_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

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
      setState(() {
        _errorMessage = TranslationKeys.passwordsDoNotMatch.tr(context);
      });
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
            buttonLabel: TranslationKeys.signIn.tr(context),
          ),
        );
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? "فشل تحديث كلمة المرور";
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
        if (_errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],

        PasswordField(
          controller: _passwordController,
          label: TranslationKeys.password.tr(context),
          hintText: '••••••••••••',
        ),
        const SizedBox(height: 20),
        PasswordField(
          controller: _confirmPasswordController,
          label: TranslationKeys.confirmPassword.tr(context),
          hintText: '••••••••••••',
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
        const SizedBox(height: 24),

        Center(
          child: ButtonApp(
            format: FormatButtonApp.text,
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
