import 'package:z_ecommerce/presentation/pages/auth/register_page.dart';
import 'package:z_ecommerce/presentation/pages/auth/forgot_password_page.dart';
import 'package:z_ecommerce/presentation/pages/home_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/super_admin_home.dart';
import 'package:z_ecommerce/presentation/pages/admin_store/admin_store_home.dart';
import 'package:z_ecommerce/presentation/pages/stores_page.dart';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_auth.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/common/footer_section.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/password_field.dart';
import '../../widgets/auth/primary_auth_button.dart';
import '../../widgets/auth/social_login_buttons.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';


class LoginPage extends StatefulWidget {
  final String? redirectTo;
  const LoginPage({super.key, this.redirectTo});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (mounted) {
      if (success) {
        final role = authProvider.currentUser?.role;
        if (role == UserRole.superAdmin) {
          changeScreenUntill(context, const SuperAdminHome());
        } else if (role == UserRole.companyOwner) {
          changeScreenUntill(context, const AdminStore());
        } else {
          final destination = widget.redirectTo ?? '/';
          if (destination == '/') {
            changeScreenUntill(context, const HomePage());
          } else {
            Navigator.pushReplacementNamed(context, destination);
          }
        }
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? TranslationKeys.loginFailed.tr(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderAuth(title: TranslationKeys.welcomeBack.tr(context)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthCard(
              subtitle: TranslationKeys.pleaseEnterDetailsToSignIn.tr(context),
              subtitleWidget: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _QuickFillButton(
                      label: "Customer",
                      email: 'sarah@example.com',
                      onTap: (e) { _emailController.text = e; _passwordController.text = 'password123'; },
                    ),
                    _QuickFillButton(
                      label: "Store Owner",
                      email: 'owner@cmp1.com',
                      onTap: (e) { _emailController.text = e; _passwordController.text = 'password123'; },
                    ),
                    _QuickFillButton(
                      label: "Super Admin",
                      email: 'admin@shop.com',
                      onTap: (e) { _emailController.text = e; _passwordController.text = 'password123'; },
                    ),
                  ],
                ),
              ),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _emailController,
                        label: TranslationKeys.email.tr(context),
                        hintText: TranslationKeys.enterYourEmail.tr(context),
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || v.isEmpty ? TranslationKeys.emailRequired.tr(context) : null,
                      ),
                      const SizedBox(height: 24),
                      PasswordField(
                        controller: _passwordController,
                        label: TranslationKeys.password.tr(context),
                        hintText: TranslationKeys.enterYourPassword.tr(context),
                        validator: (v) => v == null || v.isEmpty
                            ? TranslationKeys.passwordRequired.tr(context)
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() => _rememberMe = value ?? false);
                                  },
                                  activeColor: Theme.of(context).primaryColor,
                                ),
                                Flexible(
                                  child: Text(
                                    TranslationKeys.rememberMe.tr(context),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: () {
                                changeScreen(context, const ForgotPasswordPage());
                              },
                              child: Text(
                                TranslationKeys.forgotPassword.tr(context),
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
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
                            border: Border.all(
                              color: Colors.red.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) => PrimaryAuthButton(
                          label: TranslationKeys.signIn.tr(context),
                          onPressed: _handleLogin,
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
                      TranslationKeys.dontHaveAccount.tr(context),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        changeScreen(context, RegisterPage(redirectTo: widget.redirectTo));
                      },
                      child: Text(TranslationKeys.signUp.tr(context)),
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

class _QuickFillButton extends StatelessWidget {
  final String label;
  final String email;
  final Function(String) onTap;

  const _QuickFillButton({
    required this.label,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(email),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
