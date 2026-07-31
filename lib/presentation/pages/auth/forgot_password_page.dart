import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/pages/auth/reset_password_page.dart';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/theme/theme_auth.dart';
import '../../widgets/auth/auth_split_layout.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/primary_auth_button.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class ForgotPasswordPage extends StatefulWidget {
  final AuthThemeConfig? customAuthTheme;

  const ForgotPasswordPage({
    super.key,
    this.customAuthTheme,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordResetEmail(email);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        changeScreen(
          context,
          ResetPasswordPage(customAuthTheme: widget.customAuthTheme),
        );
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'فشل إرسال رابط إعادة التعيين';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authTheme = widget.customAuthTheme ?? const AuthThemeConfig();
    final primaryColor = authTheme.primaryColor;

    return AuthSplitLayout(
      pageTitle: authTheme.forgotPasswordTitle,
      pageSubtitle: authTheme.forgotPasswordSubtitle,
      customAuthTheme: authTheme,
      children: [
        AuthTextField(
          controller: _emailController,
          label: TranslationKeys.email.tr(context),
          hintText: 'alex.jordan@gmail.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: PrimaryAuthButton(
            label: TranslationKeys.sendResetLink.tr(context),
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
