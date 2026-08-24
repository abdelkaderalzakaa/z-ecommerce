import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/auth/login_page.dart';
import 'package:z_ecommerce/presentation/pages/business/home/admin_business_home.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/super_admin_home.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_split_layout.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import 'package:z_ecommerce/presentation/widgets/auth/password_field.dart';
import 'package:z_ecommerce/presentation/widgets/auth/primary_auth_button.dart';
import 'package:z_ecommerce/presentation/widgets/auth/social_login_buttons.dart';

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
  final _phoneController = TextEditingController();

  bool _agreeToTerms = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      setState(
        () => _errorMessage = TranslationKeys.pleaseAgreeToTerms.tr(context),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(
        () => _errorMessage = TranslationKeys.passwordsDoNotMatch.tr(context),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    final success = await authProvider.registerCustomer(
      name: fullName,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phoneNumber: _phoneController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        final role = authProvider.currentUser?.role;
        if (role == UserRole.superAdmin) {
          changeScreenUntill(context, const SuperAdminHome());
        } else if (role == UserRole.businessOwner) {
          changeScreenUntill(context, const AdminStore());
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
              TranslationKeys.registrationFailed.tr(context);
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
          changeScreenUntill(context, const AdminStore());
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
        ar: 'أنشئ حسابك الجديد',
        en: 'Create New Account',
      ),
      pageSubtitle: const LocalizedString(
        ar: 'انضم إلينا اليوم واستمتع بتجربة فريدة ومميزة.',
        en: 'Join us today & enjoy an extraordinary shopping experience.',
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
              // First Name & Last Name Row
              Row(
                children: [
                  Expanded(
                    child: AuthTextField(
                      controller: _firstNameController,
                      label: TranslationKeys.firstName.tr(context),
                      hintText: 'الاسم الأول',
                      prefixIcon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return TranslationKeys.requiredField.tr(context);
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AuthTextField(
                      controller: _lastNameController,
                      label: TranslationKeys.lastName.tr(context),
                      hintText: 'الاسم الأخير',
                      prefixIcon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return TranslationKeys.requiredField.tr(context);
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Email Field
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
              const SizedBox(height: 16),

              // Password & Confirm Password
              PasswordField(
                controller: _passwordController,
                label: TranslationKeys.password.tr(context),
                hintText: '••••••••••••',
                validator: (val) {
                  if (val == null || val.length < 6) {
                    return TranslationKeys.passwordRequired.tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _confirmPasswordController,
                label: TranslationKeys.confirmPassword.tr(context),
                hintText: '••••••••••••',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return TranslationKeys.confirmYourPassword.tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Terms Agreement Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      activeColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) {
                        setState(() => _agreeToTerms = val ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          TranslationKeys.iAgreeToThe.tr(context),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        Text(
                          TranslationKeys.termsConditions.tr(context),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        Text(
                          TranslationKeys.andPrivacyPolicy.tr(context),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Register Submit Button
              PrimaryAuthButton(
                label: TranslationKeys.createAccount.tr(context),
                onPressed: _handleRegister,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),

              // Divider
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

              // Login Page Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TranslationKeys.alreadyHaveAccount.tr(context),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      changeScreen(context, LoginPage(redirectTo: widget.redirectTo));
                    },
                    child: Text(
                      TranslationKeys.signIn.tr(context),
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
