import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/global/theme/theme_auth.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';
import 'package:z_ecommerce/presentation/pages/auth/login_page.dart';

class AuthThemeSettingsPage extends StatefulWidget {
  const AuthThemeSettingsPage({super.key});

  @override
  State<AuthThemeSettingsPage> createState() => _AuthThemeSettingsPageState();
}

class _AuthThemeSettingsPageState extends State<AuthThemeSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _brandNameController;
  late TextEditingController _sideImageUrlController;
  late TextEditingController _logoUrlController;

  late TextEditingController _loginTitleArController;
  late TextEditingController _loginTitleEnController;
  late TextEditingController _loginSubArController;
  late TextEditingController _loginSubEnController;

  late TextEditingController _quoteTextArController;
  late TextEditingController _quoteTextEnController;
  late TextEditingController _quoteAuthorArController;
  late TextEditingController _quoteAuthorEnController;

  late TextEditingController _registerTitleArController;
  late TextEditingController _registerTitleEnController;

  late TextEditingController _primaryColorController;
  late TextEditingController _buttonGradientEndController;

  bool _showGoogleLogin = true;
  bool _enableButtonGradient = true;
  double _buttonBorderRadius = 30.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    const currentTheme = AuthThemeConfig();

    _brandNameController = TextEditingController(text: currentTheme.brandName);
    _sideImageUrlController = TextEditingController(text: currentTheme.sideImageUrl);
    _logoUrlController = TextEditingController(text: currentTheme.logoUrl);

    _loginTitleArController = TextEditingController(text: currentTheme.loginTitle.ar);
    _loginTitleEnController = TextEditingController(text: currentTheme.loginTitle.en);
    _loginSubArController = TextEditingController(text: currentTheme.loginSubtitle.ar);
    _loginSubEnController = TextEditingController(text: currentTheme.loginSubtitle.en);

    _quoteTextArController = TextEditingController(text: currentTheme.quoteText.ar);
    _quoteTextEnController = TextEditingController(text: currentTheme.quoteText.en);
    _quoteAuthorArController = TextEditingController(text: currentTheme.quoteAuthor.ar);
    _quoteAuthorEnController = TextEditingController(text: currentTheme.quoteAuthor.en);

    _registerTitleArController = TextEditingController(text: currentTheme.registerTitle.ar);
    _registerTitleEnController = TextEditingController(text: currentTheme.registerTitle.en);

    _primaryColorController = TextEditingController(
      text: '#${currentTheme.primaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
    );
    _buttonGradientEndController = TextEditingController(
      text: '#${currentTheme.buttonGradientEnd.value.toRadixString(16).substring(2).toUpperCase()}',
    );

    _showGoogleLogin = currentTheme.showGoogleLogin;
    _enableButtonGradient = currentTheme.enableButtonGradient;
    _buttonBorderRadius = currentTheme.buttonBorderRadius;
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    _sideImageUrlController.dispose();
    _logoUrlController.dispose();
    _loginTitleArController.dispose();
    _loginTitleEnController.dispose();
    _loginSubArController.dispose();
    _loginSubEnController.dispose();
    _quoteTextArController.dispose();
    _quoteTextEnController.dispose();
    _quoteAuthorArController.dispose();
    _quoteAuthorEnController.dispose();
    _registerTitleArController.dispose();
    _registerTitleEnController.dispose();
    _primaryColorController.dispose();
    _buttonGradientEndController.dispose();
    super.dispose();
  }

  Color _parseColor(String hexString, Color fallback) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث إعدادات واجهات المصادقة وثيم النظام بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _previewAuthUI() {
    final customConfig = AuthThemeConfig(
      brandName: _brandNameController.text.trim(),
      sideImageUrl: _sideImageUrlController.text.trim(),
      logoUrl: _logoUrlController.text.trim(),
      primaryColor: _parseColor(_primaryColorController.text, const Color(0xFF635BFF)),
      buttonGradientEnd: _parseColor(_buttonGradientEndController.text, const Color(0xFF4F46E5)),
      buttonBorderRadius: _buttonBorderRadius,
      enableButtonGradient: _enableButtonGradient,
      showGoogleLogin: _showGoogleLogin,
      loginTitle: LocalizedString(
        ar: _loginTitleArController.text,
        en: _loginTitleEnController.text,
      ),
      loginSubtitle: LocalizedString(
        ar: _loginSubArController.text,
        en: _loginSubEnController.text,
      ),
      quoteText: LocalizedString(
        ar: _quoteTextArController.text,
        en: _quoteTextEnController.text,
      ),
      quoteAuthor: LocalizedString(
        ar: _quoteAuthorArController.text,
        en: _quoteAuthorEnController.text,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(customAuthTheme: customConfig),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AddEditTemplate(
      title: 'تخصيص واجهات المصادقة والتسجيل (Super Admin)',
      subtitle: 'التحكم الكامل في النصوص، الألوان، الأزرار، والبنر البصري لواجهات الدخول والحسابات',
      isEditMode: true,
      formKey: _formKey,
      submitLabel: TranslationKeys.saveChanges.tr(context),
      submitIcon: Icons.save_rounded,
      onSubmit: _submit,
      isSubmitting: _isSubmitting,
      cancelLabel: 'معاينة الواجهة',
      onCancel: _previewAuthUI,
      sections: [
        // 1. Branding & Banner Assets
        FormSection(
          title: 'البنرات والصورة الجانبية للمصادقة',
          subtitle: 'رابط الصورة البصرية واسم العلامة التجارية المعروضة',
          icon: Icons.image_rounded,
          fields: [
            TextFormField(
              controller: _brandNameController,
              decoration: const InputDecoration(
                labelText: 'اسم العلامة التجارية (Brand Name)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.workspace_premium_rounded, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
            TextFormField(
              controller: _sideImageUrlController,
              decoration: const InputDecoration(
                labelText: 'رابط الصورة الجانبية (Side Image URL)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link_rounded, size: 20),
              ),
              validator: (v) => v!.isEmpty ? TranslationKeys.required.tr(context) : null,
            ),
          ],
        ),

        // 2. Colors & Button Styling
        FormSection(
          title: 'الألوان وشكل الأزرار المخصصة',
          subtitle: 'تحديد ألوان التدرجوانحناء حواف الأزرار العصري',
          icon: Icons.palette_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _primaryColorController,
                    decoration: const InputDecoration(
                      labelText: 'اللون الرئيسي (#635BFF)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.color_lens_outlined, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _buttonGradientEndController,
                    decoration: const InputDecoration(
                      labelText: 'لون نهاية التدرج (#4F46E5)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.gradient_rounded, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('تفعيل التدرج اللوني في الأزرار (Gradient Buttons)'),
              subtitle: const Text('إعطاء مظهر عصري بارز للزر الرئيسي'),
              value: _enableButtonGradient,
              onChanged: (val) => setState(() => _enableButtonGradient = val),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'درجة انحناء حواف الزر (Border Radius): ${_buttonBorderRadius.toInt()} px',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _buttonBorderRadius,
                  min: 0.0,
                  max: 40.0,
                  divisions: 8,
                  label: '${_buttonBorderRadius.toInt()} px',
                  onChanged: (val) => setState(() => _buttonBorderRadius = val),
                ),
              ],
            ),
          ],
        ),

        // 3. Texts & Translations
        FormSection(
          title: 'النصوص والعبارات الترحيبية والإقتباسات',
          subtitle: 'تحديث كافة العبارات المعروضة باللغتين العربية والإنجليزي',
          icon: Icons.format_quote_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _loginTitleArController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان تسجيل الدخول (عربي)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _loginTitleEnController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان تسجيل الدخول (English)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quoteTextArController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'الإقتباس البصري (عربي)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _quoteAuthorArController,
                    decoration: const InputDecoration(
                      labelText: 'قائل الإقتباس (عربي)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // 4. Social Integration Settings
        FormSection(
          title: 'خيارات تسجيل الدخول الاجتماعي',
          subtitle: 'تفعيل أو إيقاف تسجيل الدخول بنقرة واحدة عبر غوغل',
          icon: Icons.g_mobiledata_rounded,
          fields: [
            SwitchListTile(
              title: const Text('تفعيل الدخول عبر حساب Google (Continue with Google)'),
              subtitle: const Text('إظهار زر الدخول وإنشاء الحساب السريع بنقرة واحدة'),
              value: _showGoogleLogin,
              onChanged: (val) => setState(() => _showGoogleLogin = val),
            ),
          ],
        ),
      ],
    );
  }
}
