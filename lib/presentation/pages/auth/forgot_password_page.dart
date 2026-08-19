import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/auth/reset_password_page.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_split_layout.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import 'package:z_ecommerce/presentation/widgets/auth/primary_auth_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

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
        changeScreen(context, const ResetPasswordPage());
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? "حدث خطأ أثناء إرسال البريد";
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
