import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/auth/forgot_password_page.dart';
import 'package:z_ecommerce/presentation/pages/auth/register_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/admin_business_home.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/super_admin_home.dart';
import 'package:z_ecommerce/presentation/pages/delivery/delivery_home.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_split_layout.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import 'package:z_ecommerce/presentation/widgets/auth/password_field.dart';
import 'package:z_ecommerce/presentation/widgets/auth/primary_auth_button.dart';
import 'package:z_ecommerce/presentation/widgets/auth/social_login_buttons.dart';

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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BusinessProvider>().clearSelectedBusiness();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      emailOrPhone: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        final role = authProvider.currentUser?.role;
        if (role == UserRole.superAdmin) {
          changeScreenUntill(context, const SuperAdminHome());
        } else if (role == UserRole.businessOwner) {
          if (authProvider.currentUser?.businessId != null) {
            await context
                .read<BusinessProvider>()
                .selectBusiness(authProvider.currentUser!.businessId!);
          }
          changeScreenUntill(context, const AdminStore());
        } else if (role == UserRole.delivery) {
          changeScreenUntill(context, const DeliveryPortalHome());
        } else {
          final destination = widget.redirectTo ?? '/';
          if (destination == '/') {
            changeScreenUntill(context, const BusinessEntry());
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

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        final role = authProvider.currentUser?.role;
        if (role == UserRole.superAdmin) {
          changeScreenUntill(context, const SuperAdminHome());
        } else if (role == UserRole.businessOwner) {
          if (authProvider.currentUser?.businessId != null) {
            await context
                .read<BusinessProvider>()
                .selectBusiness(authProvider.currentUser!.businessId!);
          }
          changeScreenUntill(context, const AdminStore());
        } else if (role == UserRole.delivery) {
          changeScreenUntill(context, const DeliveryPortalHome());
        } else {
          final destination = widget.redirectTo ?? '/';
          if (destination == '/') {
            changeScreenUntill(context, const BusinessEntry());
          } else {
            Navigator.pushReplacementNamed(context, destination);
          }
        }
      } else if (authProvider.errorMessage != null) {
        setState(() {
          _errorMessage = authProvider.errorMessage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthSplitLayout(
      pageTitle: const LocalizedString(
        ar: 'مرحباً بك مجدداً',
        en: 'Welcome Back',
      ),
      pageSubtitle: const LocalizedString(
        ar: 'أدخل بياناتك للمتابعة والتسوق بكل سهولة.',
        en: 'Enter your credentials to continue shopping.',
      ),
      children: [
        if (_errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accent.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

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
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return TranslationKeys.emailRequired.tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              PasswordField(
                controller: _passwordController,
                label: TranslationKeys.password.tr(context),
                hintText: '••••••••••••',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return TranslationKeys.passwordRequired.tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Remember Me & Forgot Password Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() => _rememberMe = val ?? false);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        TranslationKeys.rememberMe.tr(context),
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      changeScreen(context, const ForgotPasswordPage());
                    },
                    child: Text(
                      TranslationKeys.forgotPassword.tr(context),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              PrimaryAuthButton(
                label: TranslationKeys.signIn.tr(context),
                onPressed: _handleLogin,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),

              // Divider with Text
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      TranslationKeys.or.tr(context),
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 20),

              // Social Login
              SocialLoginButtons(
                onGooglePressed: _handleGoogleSignIn,
              ),
              const SizedBox(height: 24),

              // Register Page Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TranslationKeys.dontHaveAccount.tr(context),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      changeScreen(context, RegisterPage(redirectTo: widget.redirectTo));
                    },
                    child: Text(
                      TranslationKeys.signUp.tr(context),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
