import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/pages/auth/reset_password_page.dart';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/translate/localized_string.dart';
import '../../widgets/auth/auth_split_layout.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/primary_auth_button.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

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
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordResetEmail(email);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        changeScreen(
          context,
          ResetPasswordPage(),
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
        ar: 'نسيت كلمة المرور؟',
        en: 'Forgot password?',
      ),
      pageSubtitle: const LocalizedString(
        ar: 'لا تقلق، أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة الضبط.',
        en: 'No worries, enter your email and we will send you reset instructions.',
      ),
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
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, size: 16, color: Theme.of(context).primaryColor),
            label: Text(
              TranslationKeys.backToLogin.tr(context),
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
