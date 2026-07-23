import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_auth.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/company_provider.dart';
import '../../widgets/common/headers/header_home.dart';
import '../../widgets/common/footer_section.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/password_field.dart';
import '../../widgets/auth/primary_auth_button.dart';
import '../../widgets/auth/social_login_buttons.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'package:flutter/gestures.dart';
import 'package:z_ecommerce/presentation/pages/auth/login_page.dart';
import 'package:z_ecommerce/presentation/pages/auth/register_page.dart';
import 'package:z_ecommerce/presentation/pages/static/terms_page.dart';
import 'package:z_ecommerce/presentation/pages/home_page.dart';

class RegisterPage extends StatefulWidget {
  final String? redirectTo;

  const RegisterPage({super.key, this.redirectTo});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreeToTerms) {
      setState(() => _errorMessage = TranslationKeys.pleaseAgreeToTerms.tr(context));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = TranslationKeys.passwordsDoNotMatch.tr(context));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    final success = await authProvider.register(
      fullName,
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        final destination = widget.redirectTo ?? '/';
        if (destination == '/') {
          changeScreenUntill(context, const HomePage());
        } else {
          Navigator.pushReplacementNamed(context, destination);
        }
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? TranslationKeys.registrationFailed.tr(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderAuth(title: TranslationKeys.createAccount.tr(context)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthCard(
              subtitle: TranslationKeys.pleaseEnterDetailsToSignUp.tr(context),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AuthTextField(
                              controller: _firstNameController,
                              label: TranslationKeys.firstName.tr(context),
                              hintText: TranslationKeys.john.tr(context),
                              prefixIcon: Icons.person_outline,
                              validator: (v) => v == null || v.isEmpty ? TranslationKeys.requiredField.tr(context) : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AuthTextField(
                              controller: _lastNameController,
                              label: TranslationKeys.lastName.tr(context),
                              hintText: TranslationKeys.doe.tr(context),
                              prefixIcon: Icons.person_outline,
                              validator: (v) => v == null || v.isEmpty ? TranslationKeys.requiredField.tr(context) : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      AuthTextField(
                        controller: _emailController,
                        label: TranslationKeys.email.tr(context),
                        hintText: TranslationKeys.enterYourEmail.tr(context),
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || v.isEmpty ? TranslationKeys.requiredField.tr(context) : null,
                      ),
                      const SizedBox(height: 24),
                      PasswordField(
                        controller: _passwordController,
                        label: TranslationKeys.password.tr(context),
                        hintText: TranslationKeys.createPassword.tr(context),
                        validator: (v) => v == null || v.isEmpty ? TranslationKeys.requiredField.tr(context) : null,
                      ),
                      const SizedBox(height: 24),
                      PasswordField(
                        controller: _confirmPasswordController,
                        label: TranslationKeys.confirmPassword.tr(context),
                        hintText: TranslationKeys.confirmYourPassword.tr(context),
                        validator: (v) => v == null || v.isEmpty ? TranslationKeys.requiredField.tr(context) : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() => _agreeToTerms = value ?? false);
                              },
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                children: [
                                  TextSpan(text: TranslationKeys.iAgreeToThe.tr(context)),
                                  TextSpan(
                                    text: TranslationKeys.termsConditions.tr(context),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        changeScreen(context, const TermsPage());
                                      },
                                  ),
                                  TextSpan(text: TranslationKeys.andPrivacyPolicy.tr(context)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) => PrimaryAuthButton(
                          label: TranslationKeys.createAccount.tr(context),
                          onPressed: _handleRegister,
                          isLoading: auth.isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const SocialLoginButtons(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      TranslationKeys.alreadyHaveAccount.tr(context),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          changeScreen(context, LoginPage(redirectTo: widget.redirectTo));
                        },
                        child: Text(
                          TranslationKeys.logIn.tr(context),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
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
