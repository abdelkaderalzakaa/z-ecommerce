import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/translate/localized_string.dart';
import '../../widgets/auth/auth_split_layout.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/password_field.dart';
import '../../widgets/auth/primary_auth_button.dart';
import '../../widgets/auth/social_login_buttons.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/auth/login_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/super_admin_home.dart';
import 'package:z_ecommerce/presentation/pages/business/admin_business_home.dart';

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
      if (success) {
        final role = authProvider.currentUser?.role;
        if (role == UserRole.superAdmin) {
          changeScreenUntill(context, const SuperAdminHome());
        } else if (role == UserRole.businessOwner ||
            role == UserRole.businessOwner) {
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
              TranslationKeys.registrationFailed.tr(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthSplitLayout(
      pageTitle: const LocalizedString(
        ar: 'أنشئ حسابك الجديد',
        en: 'Create your new account',
      ),
      pageSubtitle: const LocalizedString(
        ar: 'انضم إلينا اليوم واستمتع بتجربة فريدة ومميزة.',
        en: 'Join us today and enjoy a unique experience.',
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AuthTextField(
                      controller: _firstNameController,
                      label: TranslationKeys.firstName.tr(context),
                      hintText: 'John',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AuthTextField(
                      controller: _lastNameController,
                      label: TranslationKeys.lastName.tr(context),
                      hintText: 'Doe',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _emailController,
                label: TranslationKeys.email.tr(context),
                hintText: 'alex.jordan@gmail.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                hintText: '+966 50 123 4567',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _passwordController,
                label: TranslationKeys.password.tr(context),
                hintText: '••••••••••••',
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _confirmPasswordController,
                label: TranslationKeys.confirmPassword.tr(context),
                hintText: '••••••••••••',
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (val) =>
                        setState(() => _agreeToTerms = val ?? false),
                  ),
                  Expanded(
                    child: Text(
                      const LocalizedString(
                        ar: 'أوافق على الشروط والأحكام وسياسة الخصوصية',
                        en: 'I agree to the Terms, Conditions & Privacy Policy',
                      ).get(context),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryAuthButton(
                  label: TranslationKeys.signUp.tr(context),
                  onPressed: _handleRegister,
                  isLoading: context.watch<AuthProvider>().isLoading,

                ),
              ),

              if (true) ...[
                const SizedBox(height: 20),
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
                            MaterialPageRoute(builder: (_) => const BusinessPage()),
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
                            'فشل إنشاء الحساب عبر غوغل';
                      });
                    }
                  },
                ),
              ],

              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      TranslationKeys.alreadyHaveAccount.tr(context),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        changeScreen(
                          context,
                          LoginPage(
                            redirectTo: widget.redirectTo,
                          ),
                        );
                      },
                      child: Text(
                        TranslationKeys.signIn.tr(context),
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
