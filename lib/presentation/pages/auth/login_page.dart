import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/pages/auth/register_page.dart';
import 'package:z_ecommerce/presentation/pages/auth/forgot_password_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/super_admin_home.dart';
import 'package:z_ecommerce/presentation/pages/business/home/admin_business_home.dart';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/translate/localized_string.dart';
import '../../widgets/auth/auth_split_layout.dart';
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
      emailOrPhone: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        final role = authProvider.currentUser?.role;
        if (role == UserRole.superAdmin) {
          changeScreenUntill(context, const SuperAdminHome());
        } else if (role == UserRole.businessOwner) {
          if (authProvider.currentUser?.businessId != null) {
            await context.read<BusinessProvider>().selectBusiness(authProvider.currentUser!.businessId!);
          }
          changeScreenUntill(context, const AdminStore());
        } else {
          final destination = widget.redirectTo ?? '/';
          if (destination == '/') {
            changeScreenUntill(context, const BusinessPage());
          } else {
            Navigator.pushReplacementNamed(context, destination);
          }
        }
      } else {
        setState(() {
          _errorMessage =
              authProvider.errorMessage ??
              TranslationKeys.loginFailed.tr(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthSplitLayout(
      pageTitle: const LocalizedString(
        ar: 'مرحباً بك مجدداً',
        en: 'Welcome back',
      ),
      pageSubtitle: const LocalizedString(
        ar: 'أدخل بياناتك للمتابعة وإدارة حسابك والتسوق بسهولة.',
        en: 'Enter your details to continue, manage your account and shop easily.',
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthTextField(
                controller: _emailController,
                label: TranslationKeys.email.tr(context),
                hintText: 'alex.jordan@gmail.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              PasswordField(
                controller: _passwordController,
                label: TranslationKeys.password.tr(context),
                hintText: '••••••••••••',
              ),
              const SizedBox(height: 12),

              // Forgot Password Link & Remember Me Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      changeScreen(context, ForgotPasswordPage());
                    },
                    child: Text(
                      TranslationKeys.forgotPassword.tr(context),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        TranslationKeys.rememberMe.tr(context),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _rememberMe,
                          onChanged: (val) {
                            setState(() => _rememberMe = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Primary Login Button
              SizedBox(
                width: double.infinity,
                child: PrimaryAuthButton(
                  label: TranslationKeys.logIn.tr(context),
                  onPressed: _handleLogin,
                  isLoading: context.watch<AuthProvider>().isLoading,
                ),
              ),

              const SizedBox(height: 24),

              // OR Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),

              const SizedBox(height: 24),

              // Social Login Button (Google)
              if (true)
                SocialLoginButtons(
                  onGooglePressed: () async {
                    final navigator = Navigator.of(context);
                    final authProvider = context.read<AuthProvider>();
                    final success = await authProvider.signInWithGoogle();
                    if (mounted && success) {
                      final role = authProvider.currentUser?.role;
                      if (role == UserRole.superAdmin) {
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const SuperAdminHome(),
                          ),
                          (route) => false,
                        );
                      } else if (role == UserRole.businessOwner) {
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AdminStore()),
                          (route) => false,
                        );
                      } else {
                        final destination = widget.redirectTo ?? '/';
                        if (destination == '/') {
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const BusinessPage(),
                            ),
                            (route) => false,
                          );
                        } else {
                          navigator.pushReplacementNamed(destination);
                        }
                      }
                    } else if (mounted && !success) {
                      setState(() {
                        _errorMessage =
                            authProvider.errorMessage ??
                            'فشل تسجيل الدخول عبر غوغل';
                      });
                    }
                  },
                ),

              const SizedBox(height: 28),

              // Sign Up Navigation Link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      TranslationKeys.dontHaveAccount.tr(context),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        changeScreen(
                          context,
                          RegisterPage(redirectTo: widget.redirectTo),
                        );
                      },
                      child: Text(
                        TranslationKeys.signUp.tr(context),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
