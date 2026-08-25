import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/data/models/super_admin/platform_settings.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/super_admin_home.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import 'package:z_ecommerce/presentation/widgets/auth/password_field.dart';
import 'package:z_ecommerce/presentation/widgets/common/custom_network_image.dart';

class PlatformSetupPage extends StatefulWidget {
  const PlatformSetupPage({super.key});

  @override
  State<PlatformSetupPage> createState() => _PlatformSetupPageState();
}

class _PlatformSetupPageState extends State<PlatformSetupPage> {
  int _currentStep = 0;
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  // Step 1: Admin Account
  final _adminNameController = TextEditingController(text: 'سوبر أدمن المنصة');
  final _adminEmailController = TextEditingController(
    text: 'admin@zmatajer.com',
  );
  final _adminPasswordController = TextEditingController(text: 'Admin@123456');
  final _adminPhoneController = TextEditingController(text: '+966 50 123 4567');

  // Step 2: Platform Identity
  final _nameArController = TextEditingController(text: 'زد للمتاجر');
  final _nameEnController = TextEditingController(text: 'Z-Matajer');
  final _sloganArController = TextEditingController(
    text: 'منصتك الشاملة لأفضل المتاجر والمنتجات',
  );
  final _sloganEnController = TextEditingController(
    text: 'Your All-in-One Multi-Store Platform',
  );
  final _descArController = TextEditingController(
    text: 'وجهتك الأولى لتسوق أفضل المنتجات واكتشاف المتاجر الرائدة.',
  );
  final _descEnController = TextEditingController(
    text: 'Your premier destination for leading stores and top products.',
  );
  final _footerArController = TextEditingController(
    text: 'منظومة تجارة إلكترونية متطورة تربط المتاجر بالعملاء.',
  );
  final _footerEnController = TextEditingController(
    text: 'Advanced e-commerce ecosystem connecting stores and customers.',
  );

  // Step 3: Theme & Visual Identity
  Color _primaryColor = const Color(0xFF1E3A8A); // Deep Indigo
  Color _secondaryColor = const Color(0xFFF59E0B); // Warm Amber
  final Color _backgroundColor = const Color(0xFFF8FAFC);
  final _logoUrlController = TextEditingController(text: '');
  final String _fontFamily = 'Cairo';
  final double _buttonRadius = 12;
  final double _cardRadius = 16;

  // Step 4: Contact & Socials
  final _supportPhoneController = TextEditingController(
    text: '+961 78 123 457',
  );
  final _supportWhatsappController = TextEditingController(
    text: '+961 81 123 457',
  );
  final _supportEmailController = TextEditingController(
    text: "[EMAIL_ADDRESS]",
  );
  final _instagramController = TextEditingController(
    text: '[Instagram_url]',
  );
  final _facebookController = TextEditingController(
    text: '[Facebook_url]',
  );
  final _linkedinController = TextEditingController(
    text: '[Linkedin_url]',
  );
  final _websiteController = TextEditingController(
    text: '[Website_url]',
  );

  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    _adminPhoneController.dispose();
    _nameArController.dispose();
    _nameEnController.dispose();
    _sloganArController.dispose();
    _sloganEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _footerArController.dispose();
    _footerEnController.dispose();
    _logoUrlController.dispose();
    _supportPhoneController.dispose();
    _supportWhatsappController.dispose();
    _supportEmailController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKeyStep1.currentState!.validate()) return;
    } else if (_currentStep == 1) {
      if (!_formKeyStep2.currentState!.validate()) return;
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _handleCompleteSetup() async {
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final superAdminProvider = context.read<SuperAdminProvider>();
    final authProvider = context.read<AuthProvider>();

    final localization = LocalizationAdmin(
      name: LocalizedString(
        ar: _nameArController.text.trim(),
        en: _nameEnController.text.trim(),
      ),
      slogan: LocalizedString(
        ar: _sloganArController.text.trim(),
        en: _sloganEnController.text.trim(),
      ),
      description: LocalizedString(
        ar: _descArController.text.trim(),
        en: _descEnController.text.trim(),
      ),
      footerDescription: LocalizedString(
        ar: _footerArController.text.trim(),
        en: _footerEnController.text.trim(),
      ),
      aboutUs: LocalizedString(
        ar: _descArController.text.trim(),
        en: _descEnController.text.trim(),
      ),
      termsAndConditions: const LocalizedString(
        ar: 'الشروط والأحكام الافتراضية للمنصة',
        en: 'Default Platform Terms and Conditions',
      ),
      privacyPolicy: const LocalizedString(
        ar: 'سياسة الخصوصية الافتراضية للمنصة',
        en: 'Default Platform Privacy Policy',
      ),
    );

    final theme = ThemeAdmin(
      primaryColor:
          '#${_primaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      secondaryColor:
          '#${_secondaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      backgroundColor:
          '#${_backgroundColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      logoUrl: _logoUrlController.text.trim(),
      fontFamily: _fontFamily,
      buttonRadius: _buttonRadius,
      cardRadius: _cardRadius,
      inputRadius: 10,
    );

    final socials = [
      SocialModel(
        title: const LocalizedString(ar: 'واتساب', en: 'WhatsApp'),
        icon: 'whatsapp',
        color: const Color(0xFF25D366),
        platform: SocialPlatform.whatsapp,
        url: _supportWhatsappController.text.trim(),
        isVisible: _supportWhatsappController.text.trim().isNotEmpty,
      ),
      SocialModel(
        title: const LocalizedString(ar: 'إنستغرام', en: 'Instagram'),
        icon: 'instagram',
        color: const Color(0xFFE4405F),
        platform: SocialPlatform.instagram,
        url: _instagramController.text.trim(),
        isVisible: _instagramController.text.trim().isNotEmpty,
      ),
      SocialModel(
        title: const LocalizedString(ar: 'لينكد إن', en: 'LinkedIn'),
        icon: 'linkedin',
        color: const Color(0xFF0A66C2),
        platform: SocialPlatform.linkedin,
        url: _linkedinController.text.trim(),
        isVisible: _linkedinController.text.trim().isNotEmpty,
      ),
      SocialModel(
        title: const LocalizedString(ar: 'فيسبوك', en: 'Facebook'),
        icon: 'facebook',
        color: const Color(0xFF1877F2),
        platform: SocialPlatform.facebook,
        url: _facebookController.text.trim(),
        isVisible: _facebookController.text.trim().isNotEmpty,
      ),
      SocialModel(
        title: const LocalizedString(ar: 'الموقع الإلكتروني', en: 'Website'),
        icon: 'website',
        color: Colors.indigo,
        platform: SocialPlatform.website,
        url: _websiteController.text.trim(),
        isVisible: _websiteController.text.trim().isNotEmpty,
      ),
    ];

    final settings = PlatformSettings(
      phone: _supportPhoneController.text.trim(),
      whatsapp: _supportWhatsappController.text.trim(),
      email: _supportEmailController.text.trim(),
    );

    final success = await superAdminProvider.initializePlatformFromWizard(
      adminName: _adminNameController.text.trim(),
      adminEmail: _adminEmailController.text.trim(),
      adminPassword: _adminPasswordController.text,
      adminPhone: _adminPhoneController.text.trim(),
      localization: localization,
      theme: theme,
      socials: socials,
      settings: settings,
    );

    if (mounted) {
      if (success) {
        // تسجيل الدخول التلقائي للمدير وسيقوم الموجه الجذري بالانتقال السلس تلقائياً
        await authProvider.login(
          emailOrPhone: _adminEmailController.text.trim(),
          password: _adminPasswordController.text,
        );
      } else {
        setState(() {
          _isSubmitting = false;
          _submitError =
              superAdminProvider.errorMessage ?? 'حدث خطأ أثناء تأسيس المنصة';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark elegant slate background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 40,
              vertical: 24,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Banner Header
                  _buildWizardHeader(),

                  // Stepper Progress Indicators
                  _buildStepperIndicators(isMobile),

                  const Divider(height: 1, color: AppColors.cardBorder),

                  // Active Step Content
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 20 : 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_submitError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _submitError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        if (_currentStep == 0) _buildStep1AdminAccount(),
                        if (_currentStep == 1) _buildStep2PlatformIdentity(),
                        if (_currentStep == 2) _buildStep3ThemeAndBranding(),
                        if (_currentStep == 3) _buildStep4ContactAndFinalize(),

                        const SizedBox(height: 36),

                        // Navigation Buttons
                        _buildWizardActions(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWizardHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'معالج التأسيس والتهيئة الأولية للمنصة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'قم بإعداد حساب الإدارة العليا وهوية المنصة والثيم لمرة واحدة للانطلاق',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperIndicators(bool isMobile) {
    final steps = [
      (Icons.admin_panel_settings_rounded, 'حساب السوبر أدمن'),
      (Icons.store_mall_directory_rounded, 'هوية المنصة'),
      (Icons.palette_rounded, 'الثيم والألوان'),
      (Icons.hub_rounded, 'التواصل والإطلاق'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: const Color(0xFFF1F5F9),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = _currentStep > index;
          final isCurrent = _currentStep == index;
          final item = steps[index];

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isCurrent
                            ? _primaryColor
                            : (isCompleted
                                  ? Colors.green
                                  : Colors.grey.shade400),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : Icon(item.$1, size: 16, color: Colors.white),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 8),
                        Text(
                          item.$2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCurrent ? _primaryColor : Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 20,
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey.shade300,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // 1️⃣ Step 1: Admin Account
  // ==========================================
  Widget _buildStep1AdminAccount() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            '1. بيانات حساب السوبر أدمن الرئيسي',
            'هذا الحساب سيكون المسؤول الأعلى لإدارة المتاجر والمستخدمين والإعدادات العامة.',
          ),
          const SizedBox(height: 20),
          AuthTextField(
            controller: _adminNameController,
            label: 'الاسم الكامل للسوبر أدمن',
            hintText: 'مثال: عبد القادر الزكاع',
            prefixIcon: Icons.person_outline,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'يرجى إدخال اسم السوبر أدمن'
                : null,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _adminEmailController,
            label: 'البريد الإلكتروني الإداري',
            hintText: 'admin@zmatajer.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'يرجى إدخال البريد الإلكتروني';
              }
              if (!v.contains('@')) return 'يرجى إدخال بريد إلكتروني صحيح';
              return null;
            },
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: _adminPasswordController,
            label: 'كلمة مرور السوبر أدمن',
            hintText: '••••••••••••',
            validator: (v) => (v == null || v.length < 6)
                ? 'كلمة المرور يجب أن تكون 6 خانات على الأقل'
                : null,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _adminPhoneController,
            label: 'رقم هاتف السوبر أدمن',
            hintText: '+966 50 123 4567',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2️⃣ Step 2: Platform Identity
  // ==========================================
  Widget _buildStep2PlatformIdentity() {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            '2. هوية ونصوص المنصة العامة',
            'البيانات الأساسية التي ستظهر في دليل المتاجر، الهيدر، الفوتر، والصفحات العامة.',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  controller: _nameArController,
                  label: 'اسم المنصة (بالعربية)',
                  hintText: 'زد للمتاجر',
                  prefixIcon: Icons.branding_watermark_outlined,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'مطلوب' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AuthTextField(
                  controller: _nameEnController,
                  label: 'اسم المنصة (بالإنجليزية)',
                  hintText: 'Z-Matajer',
                  prefixIcon: Icons.branding_watermark_outlined,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'مطلوب' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  controller: _sloganArController,
                  label: 'الشعار اللفظي (Slogan) بالعربية',
                  hintText: 'منصتك الشاملة لأفضل المتاجر',
                  prefixIcon: Icons.auto_awesome_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AuthTextField(
                  controller: _sloganEnController,
                  label: 'الشعار اللفظي (Slogan) بالإنجليزية',
                  hintText: 'Your All-in-One Platform',
                  prefixIcon: Icons.auto_awesome_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _descArController,
            label: 'وصف المنصة العام (بالعربية)',
            hintText: 'وجهتك الأولى لتسوق أفضل المنتجات...',
            prefixIcon: Icons.notes_outlined,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _footerArController,
            label: 'نص الفوتر الترويجي (Footer Description)',
            hintText: 'منظومة تجارة إلكترونية متطورة تربط المتاجر بالعملاء.',
            prefixIcon: Icons.info_outline,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3️⃣ Step 3: Theme & Visual Branding
  // ==========================================
  Widget _buildStep3ThemeAndBranding() {
    final primaryPresets = [
      const Color(0xFF1E3A8A), // Deep Indigo
      const Color(0xFF0F766E), // Deep Teal
      const Color(0xFF7C3AED), // Royal Violet
      const Color(0xFFBE123C), // Crimson Red
      const Color(0xFF111827), // Midnight Dark
    ];

    final secondaryPresets = [
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Emerald
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEC4899), // Pink
      const Color(0xFF6366F1), // Indigo
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          '3. ثيم وألوان وهوية المنصة البصرية',
          'حدد الألوان الأساسية، الخط، ورابط الشعار الرسمي للمنصة.',
        ),
        const SizedBox(height: 20),

        // Primary Color Selector
        const Text(
          'اللون الأساسي للمنصة (Primary Color):',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: primaryPresets.map((color) {
            final isSelected = _primaryColor.value == color.value;
            return GestureDetector(
              onTap: () => setState(() => _primaryColor = color),
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Secondary Color Selector
        const Text(
          'اللون الثانوي للمنصة (Secondary Color):',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: secondaryPresets.map((color) {
            final isSelected = _secondaryColor.value == color.value;
            return GestureDetector(
              onTap: () => setState(() => _secondaryColor = color),
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Logo URL Input + Live Preview
        AuthTextField(
          controller: _logoUrlController,
          label: 'رابط شعار المنصة (Logo URL)',
          hintText: 'https://example.com/logo.png',
          prefixIcon: Icons.image_outlined,
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: 20),

        // Live Brand Card Preview with Active Modal Trigger
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(_buttonRadius),
                ),
                child: _logoUrlController.text.isNotEmpty
                    ? CustomNetworkImage(
                        imageUrl: _logoUrlController.text,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                            ),
                      )
                    : const Icon(Icons.storefront_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameArController.text.isNotEmpty
                          ? _nameArController.text
                          : 'زد للمتاجر',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    Text(
                      _sloganArController.text.isNotEmpty
                          ? _sloganArController.text
                          : 'منصتك الشاملة للتسوق',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: const Text('معاينة الواجهة كاملة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_buttonRadius),
                  ),
                ),
                onPressed: () => _showLivePlatformPreviewModal(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 4️⃣ Step 4: Contact & Launch
  // ==========================================
  Widget _buildStep4ContactAndFinalize() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          '4. قنوات الدعم والتواصل وإطلاق المنصة',
          'أدخل قنوات التواصل الرسمية لخدمة العملاء وأصحاب المتاجر.',
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: AuthTextField(
                controller: _supportPhoneController,
                label: 'رقم هاتف الدعم الفني',
                hintText: '+966 50 123 4567',
                prefixIcon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AuthTextField(
                controller: _supportWhatsappController,
                label: 'رقم الواتساب الرسمي',
                hintText: '+966 50 123 4567',
                prefixIcon: Icons.chat_bubble_outline,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        AuthTextField(
          controller: _supportEmailController,
          label: 'البريد الرسمي للدعم الفني',
          hintText: 'support@zmatajer.com',
          prefixIcon: Icons.email_outlined,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: AuthTextField(
                controller: _instagramController,
                label: 'رابط حساب إنستغرام',
                hintText: 'https://instagram.com/...',
                prefixIcon: Icons.link,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AuthTextField(
                controller: _facebookController,
                label: 'رابط حساب فيسبوك',
                hintText: 'https://facebook.com/...',
                prefixIcon: Icons.link,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Launch Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.green, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'أنت على وشك إطلاق وتأسيس المنصة بالكامل!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'سيتم حفظ إعدادات المنصة، ثيم الألوان، وتأسيس حساب السوبر أدمن والدخول تلقائياً إلى لوحة التحكم.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
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

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildWizardActions() {
    return Row(
      children: [
        if (_currentStep > 0)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSubmitting ? null : _previousStep,
            child: const Text('السابق'),
          ),
        const Spacer(),
        if (_currentStep < 3)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _nextStep,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('المتابعة للخطوة التالية'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          )
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSubmitting ? null : _handleCompleteSetup,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rocket_launch_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'إطلاق وتأسيس المنصة الآن',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
      ],
    );
  }

  void _showLivePlatformPreviewModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 850, maxHeight: 750),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(_cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_cardRadius),
              child: Scaffold(
                backgroundColor: _backgroundColor,
                appBar: AppBar(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _logoUrlController.text.isNotEmpty
                          ? CustomNetworkImage(
                              imageUrl: _logoUrlController.text,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.storefront_rounded,
                                    color: _primaryColor,
                                    size: 20,
                                  ),
                            )
                          : Icon(
                              Icons.storefront_rounded,
                              color: _primaryColor,
                              size: 20,
                            ),
                    ),
                  ),
                  title: Text(
                    _nameArController.text.isNotEmpty
                        ? _nameArController.text
                        : 'زد للمتاجر',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Hero Mockup
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 36,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _primaryColor.withOpacity(0.12),
                              _backgroundColor,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _secondaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _secondaryColor.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    color: _secondaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'المنصة الرسمية المعتمدة',
                                    style: TextStyle(
                                      color: _secondaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _sloganArController.text.isNotEmpty
                                  ? _sloganArController.text
                                  : 'منصتك الشاملة لأفضل المتاجر والمنتجات',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _descArController.text.isNotEmpty
                                  ? _descArController.text
                                  : 'وجهتك الأولى لتسوق أفضل المنتجات واكتشاف المتاجر الرائدة.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    _buttonRadius,
                                  ),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text('استكشف المتاجر الآن'),
                            ),
                          ],
                        ),
                      ),

                      // Sample Store Cards Row
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'المتاجر المميزة',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
                                  ),
                                ),
                                Text(
                                  'عرض الكل',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: List.generate(2, (i) {
                                return Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      left: i == 0 ? 12 : 0,
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        _cardRadius,
                                      ),
                                      border: Border.all(
                                        color: AppColors.cardBorder,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: _primaryColor.withOpacity(
                                              0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              _buttonRadius,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.storefront_rounded,
                                              size: 36,
                                              color: _primaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          i == 0
                                              ? 'متجر الأزياء والأناقة'
                                              : 'متجر الإلكترونيات الحديثة',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              color: _secondaryColor,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              '4.9 (120 تقييم)',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      // Mock Footer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Text(
                              _footerArController.text.isNotEmpty
                                  ? _footerArController.text
                                  : 'منظومة تجارة إلكترونية متطورة تربط المتاجر بالعملاء.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '© ${DateTime.now().year} ${_nameArController.text} - جميع الحقوق محفوظة',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
