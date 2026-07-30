import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';

/// Configuration class dedicated to Authentication UI styling and dynamic texts.
/// Distinct from general app theme, giving Super Admin full control over Auth aesthetics.
class AuthThemeConfig {
  // --- Branding & Visual Assets ---
  final String sideImageUrl;
  final String logoUrl;
  final String brandName;

  // --- Exclusive Colors & Aesthetics (Distinct from App Theme) ---
  final Color primaryColor; // Electric Violet / Royal Indigo (#635BFF)
  final Color buttonGradientEnd; // Deep Purple (#4F46E5)
  final Color backgroundColor;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtitleColor;
  final Color inputBorderColor;
  final Color inputFillColor;

  // --- Distinctive Button Styling ---
  final double buttonBorderRadius; // Modern Pill/Rounded shape (30.0 for pill, 14.0 for sleek rounded)
  final double buttonHeight;
  final TextStyle? buttonTextStyle;
  final bool enableButtonGradient; // Sleek modern gradient look
  final List<BoxShadow>? buttonShadow;

  // --- Dynamic Terms / Agreements Checkbox Text ---
  final LocalizedString termsAgreementText;
  final LocalizedString termsLinkText;

  // --- Social Login Toggles ---
  final bool showGoogleLogin;

  // --- Dynamic Localized Texts ---
  final LocalizedString loginTitle;
  final LocalizedString loginSubtitle;
  final LocalizedString quoteText;
  final LocalizedString quoteAuthor;
  final LocalizedString quoteRole;

  final LocalizedString registerTitle;
  final LocalizedString registerSubtitle;

  final LocalizedString forgotPasswordTitle;
  final LocalizedString forgotPasswordSubtitle;

  final LocalizedString resetPasswordTitle;
  final LocalizedString resetPasswordSubtitle;

  const AuthThemeConfig({
    this.sideImageUrl =
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=1200&auto=format&fit=crop',
    this.logoUrl = '',
    this.brandName = 'Z-ecommerce',

    // Exclusive Vibrant Colors for Auth Screens
    this.primaryColor = const Color(0xFF635BFF),
    this.buttonGradientEnd = const Color(0xFF4F46E5),
    this.backgroundColor = const Color(0xFFF8FAFC),
    this.cardBackgroundColor = Colors.white,
    this.textColor = const Color(0xFF0F172A),
    this.subtitleColor = const Color(0xFF64748B),
    this.inputBorderColor = const Color(0xFFE2E8F0),
    this.inputFillColor = const Color(0xFFF8FAFC),

    // Dynamic Distinctive Button Styles
    this.buttonBorderRadius = 30.0, // Modern sleek rounded pill style
    this.buttonHeight = 52.0,
    this.buttonTextStyle,
    this.enableButtonGradient = true,
    this.buttonShadow = const [
      BoxShadow(
        color: Color(0x3D635BFF),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],

    // Terms & Conditions Dynamic Text
    this.termsAgreementText = const LocalizedString(
      ar: 'أوافق على الشروط والأحكام وسياسة الخصوصية',
      en: 'I agree to the Terms, Conditions & Privacy Policy',
    ),
    this.termsLinkText = const LocalizedString(
      ar: 'الشروط والأحكام',
      en: 'Terms & Conditions',
    ),

    // Social Logins (Google only)
    this.showGoogleLogin = true,

    // Dynamic Localized Titles & Subtitles
    this.loginTitle = const LocalizedString(
      ar: 'مرحباً بك مجدداً',
      en: 'Welcome back',
    ),
    this.loginSubtitle = const LocalizedString(
      ar: 'أدخل بياناتك للمتابعة وإدارة حسابك والتسوق بسهولة.',
      en: 'Build your design system effortlessly with our powerful component library.',
    ),
    this.quoteText = const LocalizedString(
      ar: 'منصة رائعة توفر كل الأدوات التي نحتاجها للتسوق والتجارة.',
      en: '“Simply all the tools that my team and I need.”',
    ),
    this.quoteAuthor = const LocalizedString(
      ar: 'كارين يو',
      en: 'Karen Yue',
    ),
    this.quoteRole = const LocalizedString(
      ar: 'مديرة التسويق والتكنولوجيا الرقمية',
      en: 'Director of Digital Marketing Technology',
    ),
    this.registerTitle = const LocalizedString(
      ar: 'أنشئ حسابك الجديد',
      en: 'Create your new account',
    ),
    this.registerSubtitle = const LocalizedString(
      ar: 'انضم إلينا اليوم واستمتع بتجربة فريدة ومميزة.',
      en: 'Join us today and enjoy a unique experience.',
    ),
    this.forgotPasswordTitle = const LocalizedString(
      ar: 'نسيت كلمة المرور؟',
      en: 'Forgot password?',
    ),
    this.forgotPasswordSubtitle = const LocalizedString(
      ar: 'لا تقلق، أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة الضبط.',
      en: 'No worries, enter your email and we will send you reset instructions.',
    ),
    this.resetPasswordTitle = const LocalizedString(
      ar: 'تعيين كلمة مرور جديدة',
      en: 'Set new password',
    ),
    this.resetPasswordSubtitle = const LocalizedString(
      ar: 'يجب أن تكون كلمة المرور الجديدة مختلفة عن السابقة.',
      en: 'Your new password must be different from previously used passwords.',
    ),
  });

  factory AuthThemeConfig.fromJson(Map<String, dynamic> json) {
    return AuthThemeConfig(
      sideImageUrl: json['sideImageUrl'] ??
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=1200&auto=format&fit=crop',
      logoUrl: json['logoUrl'] ?? '',
      brandName: json['brandName'] ?? 'Z-ecommerce',
      primaryColor: json['primaryColor'] != null
          ? Color(int.parse(json['primaryColor']))
          : const Color(0xFF635BFF),
      buttonGradientEnd: json['buttonGradientEnd'] != null
          ? Color(int.parse(json['buttonGradientEnd']))
          : const Color(0xFF4F46E5),
      backgroundColor: json['backgroundColor'] != null
          ? Color(int.parse(json['backgroundColor']))
          : const Color(0xFFF8FAFC),
      cardBackgroundColor: json['cardBackgroundColor'] != null
          ? Color(int.parse(json['cardBackgroundColor']))
          : Colors.white,
      textColor: json['textColor'] != null
          ? Color(int.parse(json['textColor']))
          : const Color(0xFF0F172A),
      subtitleColor: json['subtitleColor'] != null
          ? Color(int.parse(json['subtitleColor']))
          : const Color(0xFF64748B),
      buttonBorderRadius: (json['buttonBorderRadius'] ?? 30.0).toDouble(),
      buttonHeight: (json['buttonHeight'] ?? 52.0).toDouble(),
      enableButtonGradient: json['enableButtonGradient'] ?? true,
      showGoogleLogin: json['showGoogleLogin'] ?? true,
      termsAgreementText: json['termsAgreementText'] != null
          ? LocalizedString.fromJson(json['termsAgreementText'])
          : const LocalizedString(
              ar: 'أوافق على الشروط والأحكام وسياسة الخصوصية',
              en: 'I agree to the Terms, Conditions & Privacy Policy',
            ),
      termsLinkText: json['termsLinkText'] != null
          ? LocalizedString.fromJson(json['termsLinkText'])
          : const LocalizedString(
              ar: 'الشروط والأحكام',
              en: 'Terms & Conditions',
            ),
      loginTitle: json['loginTitle'] != null
          ? LocalizedString.fromJson(json['loginTitle'])
          : const LocalizedString(ar: 'مرحباً بك مجدداً', en: 'Welcome back'),
      loginSubtitle: json['loginSubtitle'] != null
          ? LocalizedString.fromJson(json['loginSubtitle'])
          : const LocalizedString(
              ar: 'أدخل بياناتك للمتابعة وإدارة حسابك والتسوق بسهولة.',
              en: 'Build your design system effortlessly with our powerful component library.',
            ),
      quoteText: json['quoteText'] != null
          ? LocalizedString.fromJson(json['quoteText'])
          : const LocalizedString(
              ar: 'منصة رائعة توفر كل الأدوات التي نحتاجها للتسوق والتجارة.',
              en: '“Simply all the tools that my team and I need.”',
            ),
      quoteAuthor: json['quoteAuthor'] != null
          ? LocalizedString.fromJson(json['quoteAuthor'])
          : const LocalizedString(ar: 'كارين يو', en: 'Karen Yue'),
      quoteRole: json['quoteRole'] != null
          ? LocalizedString.fromJson(json['quoteRole'])
          : const LocalizedString(
              ar: 'مديرة التسويق والتكنولوجيا الرقمية',
              en: 'Director of Digital Marketing Technology',
            ),
      registerTitle: json['registerTitle'] != null
          ? LocalizedString.fromJson(json['registerTitle'])
          : const LocalizedString(
              ar: 'أنشئ حسابك الجديد',
              en: 'Create your new account',
            ),
      registerSubtitle: json['registerSubtitle'] != null
          ? LocalizedString.fromJson(json['registerSubtitle'])
          : const LocalizedString(
              ar: 'انضم إلينا اليوم واستمتع بتجربة فريدة ومميزة.',
              en: 'Join us today and enjoy a unique experience.',
            ),
      forgotPasswordTitle: json['forgotPasswordTitle'] != null
          ? LocalizedString.fromJson(json['forgotPasswordTitle'])
          : const LocalizedString(
              ar: 'نسيت كلمة المرور؟',
              en: 'Forgot password?',
            ),
      forgotPasswordSubtitle: json['forgotPasswordSubtitle'] != null
          ? LocalizedString.fromJson(json['forgotPasswordSubtitle'])
          : const LocalizedString(
              ar: 'لا تقلق، أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة الضبط.',
              en: 'No worries, enter your email and we will send you reset instructions.',
            ),
      resetPasswordTitle: json['resetPasswordTitle'] != null
          ? LocalizedString.fromJson(json['resetPasswordTitle'])
          : const LocalizedString(
              ar: 'تعيين كلمة مرور جديدة',
              en: 'Set new password',
            ),
      resetPasswordSubtitle: json['resetPasswordSubtitle'] != null
          ? LocalizedString.fromJson(json['resetPasswordSubtitle'])
          : const LocalizedString(
              ar: 'يجب أن تكون كلمة المرور الجديدة مختلفة عن السابقة.',
              en: 'Your new password must be different from previously used passwords.',
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sideImageUrl': sideImageUrl,
      'logoUrl': logoUrl,
      'brandName': brandName,
      'primaryColor': primaryColor.value.toRadixString(16),
      'buttonGradientEnd': buttonGradientEnd.value.toRadixString(16),
      'backgroundColor': backgroundColor.value.toRadixString(16),
      'cardBackgroundColor': cardBackgroundColor.value.toRadixString(16),
      'textColor': textColor.value.toRadixString(16),
      'subtitleColor': subtitleColor.value.toRadixString(16),
      'buttonBorderRadius': buttonBorderRadius,
      'buttonHeight': buttonHeight,
      'enableButtonGradient': enableButtonGradient,
      'showGoogleLogin': showGoogleLogin,
      'termsAgreementText': termsAgreementText.toJson(),
      'termsLinkText': termsLinkText.toJson(),
      'loginTitle': loginTitle.toJson(),
      'loginSubtitle': loginSubtitle.toJson(),
      'quoteText': quoteText.toJson(),
      'quoteAuthor': quoteAuthor.toJson(),
      'quoteRole': quoteRole.toJson(),
      'registerTitle': registerTitle.toJson(),
      'registerSubtitle': registerSubtitle.toJson(),
      'forgotPasswordTitle': forgotPasswordTitle.toJson(),
      'forgotPasswordSubtitle': forgotPasswordSubtitle.toJson(),
      'resetPasswordTitle': resetPasswordTitle.toJson(),
      'resetPasswordSubtitle': resetPasswordSubtitle.toJson(),
    };
  }
}
