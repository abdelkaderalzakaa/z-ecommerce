import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/data/models/super_admin/platform_settings.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';

class PlatformConfigModel {
  final String id;
  final LocalizationAdmin localization;
  final ThemeAdmin theme;
  final List<SocialModel> socials;
  final PlatformSettings settings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PlatformConfigModel({
    this.id = 'global_config',
    LocalizationAdmin? localization,
    ThemeAdmin? theme,
    List<SocialModel>? socials,
    PlatformSettings? settings,
    this.createdAt,
    this.updatedAt,
  })  : localization = localization ?? LocalizationAdmin.empty(),
        theme = theme ?? ThemeAdmin.empty(),
        socials = socials ?? const [],
        settings = settings ?? PlatformSettings.empty();

  factory PlatformConfigModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return PlatformConfigModel(
      id: docId ?? map['id'] ?? 'global_config',
      localization: map['localization'] != null
          ? LocalizationAdmin.fromMap(map['localization'])
          : (map['localizationAdmin'] != null
              ? LocalizationAdmin.fromMap(map['localizationAdmin'])
              : LocalizationAdmin.empty()),
      theme: map['theme'] != null
          ? ThemeAdmin.fromMap(map['theme'])
          : (map['themeAdmin'] != null
              ? ThemeAdmin.fromMap(map['themeAdmin'])
              : ThemeAdmin.empty()),
      socials: map['socials'] != null
          ? (map['socials'] as List)
              .map((e) => SocialModel.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      settings: map['settings'] != null
          ? PlatformSettings.fromMap(map['settings'])
          : (map['platformSettings'] != null
              ? PlatformSettings.fromMap(map['platformSettings'])
              : PlatformSettings.empty()),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'localization': localization.toMap(),
      'theme': theme.toMap(),
      'socials': socials.map((e) => e.toMap()).toList(),
      'settings': settings.toMap(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PlatformConfigModel copyWith({
    String? id,
    LocalizationAdmin? localization,
    ThemeAdmin? theme,
    List<SocialModel>? socials,
    PlatformSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlatformConfigModel(
      id: id ?? this.id,
      localization: localization ?? this.localization,
      theme: theme ?? this.theme,
      socials: socials ?? this.socials,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PlatformConfigModel.defaultConfig() {
    return PlatformConfigModel(
      id: 'global_config',
      localization: LocalizationAdmin(
        name: const LocalizedString(
          ar: 'متاجر زد',
          en: 'Z-Matajer',
        ),
        slogan: const LocalizedString(
          ar: 'وجهتك الأولى للتسوق الإلكتروني وربط المتاجر',
          en: 'Your first destination for e-commerce and store connection',
        ),
        description: const LocalizedString(
          ar: 'منصة متكاملة تتيح لك التسوق من أفضل المتاجر بكل سهولة وأمان.',
          en: 'An integrated platform allowing you to shop from top stores with ease and security.',
        ),
        footerDescription: const LocalizedString(
          ar: 'نحن هنا لخدمتك على مدار الساعة، تسوق بأمان واطمئنان.',
          en: 'We are here to serve you 24/7. Shop safely and with peace of mind.',
        ),
        aboutUs: const LocalizedString(
          ar: 'منصة متاجر زد هي الرائدة في تقديم حلول التجارة الإلكترونية لتجربة تسوق لا مثيل لها.',
          en: 'Z-Matajer is the leading platform in providing e-commerce solutions for an unparalleled shopping experience.',
        ),
        termsAndConditions: const LocalizedString(
          ar: 'يرجى مراجعة صفحة الشروط والأحكام لمعرفة التفاصيل الخاصة باستخدام المنصة.',
          en: 'Please review the Terms and Conditions page for details on using the platform.',
        ),
        privacyPolicy: const LocalizedString(
          ar: 'نحن نلتزم بحماية بياناتك الشخصية وضمان سرية معلوماتك تماماً.',
          en: 'We are committed to protecting your personal data and ensuring the complete confidentiality of your information.',
        ),
      ),
      theme: ThemeAdmin.empty(),
      socials: const [],
      settings: PlatformSettings.empty(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
