import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';

class KpiCardConfig {
  final LocalizedString label;
  final String value;

  const KpiCardConfig({
    required this.label,
    required this.value,
  });

  factory KpiCardConfig.fromMap(Map<String, dynamic> map) {
    return KpiCardConfig(
      label: LocalizedString.fromMap(map['label'] ?? {}),
      value: map['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label.toMap(),
      'value': value,
    };
  }

  KpiCardConfig copyWith({
    LocalizedString? label,
    String? value,
  }) {
    return KpiCardConfig(
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }

  static List<KpiCardConfig> defaultCards() {
    return const [
      KpiCardConfig(
        label: LocalizedString(ar: 'المتاجر المفعلة', en: 'Active Stores'),
        value: '50+',
      ),
      KpiCardConfig(
        label: LocalizedString(ar: 'المنتجات المعروضة', en: 'Listed Products'),
        value: '1000+',
      ),
      KpiCardConfig(
        label: LocalizedString(ar: 'العملاء السعداء', en: 'Happy Customers'),
        value: '5000+',
      ),
    ];
  }
}

class PlatformSettings {
  // Feature Flags
  final bool enableLikes;
  final bool enableReviews;
  final bool enableFollows;

  // Section Visibility Toggles (التحكم الجذري بالسوبر أدمن)
  final bool showCategoriesSection;
  final bool showFeaturedBusinessesSection;
  final bool showFeaturedOffersSection;
  final bool showFeaturedProductsSection;
  final bool showKpiCardsSection;
  final bool showJoinFamilyBanner;

  // Homepage Sections
  final List<String> allowedBusinessTypes;
  final List<String> featuredBusinessIds;
  final List<String> featuredOfferIds;
  final List<String> featuredProductIds;
  final List<KpiCardConfig> kpiCards;
  final LocalizedString joinFamilySubtitle;
  final String? youtubeVideoUrl;

  // Contact Channels
  final String? phone;
  final String? whatsapp;
  final String? email;
  final LocalizedString address;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? twitterUrl;
  final String? linkedinUrl;

  // Static Legal Pages Content
  final LocalizedString aboutUsContent;
  final LocalizedString termsContent;
  final LocalizedString privacyContent;

  // Auth Split Layout Banner Content
  final LocalizedString authBannerHeadline;
  final LocalizedString authBannerSubtext;

  const PlatformSettings({
    this.enableLikes = true,
    this.enableReviews = true,
    this.enableFollows = true,
    this.showCategoriesSection = true,
    this.showFeaturedBusinessesSection = true,
    this.showFeaturedOffersSection = true,
    this.showFeaturedProductsSection = true,
    this.showKpiCardsSection = true,
    this.showJoinFamilyBanner = true,
    this.allowedBusinessTypes = const [],
    this.featuredBusinessIds = const [],
    this.featuredOfferIds = const [],
    this.featuredProductIds = const [],
    this.kpiCards = const [],
    this.joinFamilySubtitle = const LocalizedString(
      ar: 'اشترك في النشرة البريدية ليصلك كل جديد من المتاجر المميزة، العروض الحصرية، والمنتجات الرائعة مباشرة إلى بريدك الإلكتروني.',
      en: 'Subscribe to our newsletter to receive the latest updates, exclusive offers, and amazing products directly in your inbox.',
    ),
    this.youtubeVideoUrl,
    this.phone,
    this.whatsapp,
    this.email,
    this.address = const LocalizedString(ar: '', en: ''),
    this.facebookUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.linkedinUrl,
    this.aboutUsContent = const LocalizedString(ar: '', en: ''),
    this.termsContent = const LocalizedString(ar: '', en: ''),
    this.privacyContent = const LocalizedString(ar: '', en: ''),
    this.authBannerHeadline = const LocalizedString(ar: '', en: ''),
    this.authBannerSubtext = const LocalizedString(ar: '', en: ''),
  });

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;
  bool get hasWhatsapp => whatsapp != null && whatsapp!.trim().isNotEmpty;
  bool get hasEmail => email != null && email!.trim().isNotEmpty;
  bool get hasYoutubeVideo => youtubeVideoUrl != null && youtubeVideoUrl!.trim().isNotEmpty;

  factory PlatformSettings.fromMap(Map<String, dynamic> map) {
    return PlatformSettings(
      enableLikes: map['enableLikes'] ?? true,
      enableReviews: map['enableReviews'] ?? true,
      enableFollows: map['enableFollows'] ?? true,
      showCategoriesSection: map['showCategoriesSection'] ?? true,
      showFeaturedBusinessesSection: map['showFeaturedBusinessesSection'] ?? true,
      showFeaturedOffersSection: map['showFeaturedOffersSection'] ?? true,
      showFeaturedProductsSection: map['showFeaturedProductsSection'] ?? true,
      showKpiCardsSection: map['showKpiCardsSection'] ?? true,
      showJoinFamilyBanner: map['showJoinFamilyBanner'] ?? true,
      allowedBusinessTypes: map['allowedBusinessTypes'] != null
          ? List<String>.from(map['allowedBusinessTypes'])
          : [],
      featuredBusinessIds: map['featuredBusinessIds'] != null
          ? List<String>.from(map['featuredBusinessIds'])
          : [],
      featuredOfferIds: map['featuredOfferIds'] != null
          ? List<String>.from(map['featuredOfferIds'])
          : [],
      featuredProductIds: map['featuredProductIds'] != null
          ? List<String>.from(map['featuredProductIds'])
          : [],
      kpiCards: map['kpiCards'] != null
          ? (map['kpiCards'] as List<dynamic>)
                .map((e) => KpiCardConfig.fromMap(e))
                .toList()
          : KpiCardConfig.defaultCards(),
      joinFamilySubtitle: LocalizedString.fromMap(
        map['joinFamilySubtitle'] ?? {},
      ),
      youtubeVideoUrl: map['youtubeVideoUrl'],
      phone: map['phone'],
      whatsapp: map['whatsapp'],
      email: map['email'],
      address: LocalizedString.fromMap(map['address'] ?? {}),
      facebookUrl: map['facebookUrl'],
      instagramUrl: map['instagramUrl'],
      twitterUrl: map['twitterUrl'],
      linkedinUrl: map['linkedinUrl'],
      aboutUsContent: LocalizedString.fromMap(map['aboutUsContent'] ?? {}),
      termsContent: LocalizedString.fromMap(map['termsContent'] ?? {}),
      privacyContent: LocalizedString.fromMap(map['privacyContent'] ?? {}),
      authBannerHeadline: LocalizedString.fromMap(map['authBannerHeadline'] ?? {}),
      authBannerSubtext: LocalizedString.fromMap(map['authBannerSubtext'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableLikes': enableLikes,
      'enableReviews': enableReviews,
      'enableFollows': enableFollows,
      'showCategoriesSection': showCategoriesSection,
      'showFeaturedBusinessesSection': showFeaturedBusinessesSection,
      'showFeaturedOffersSection': showFeaturedOffersSection,
      'showFeaturedProductsSection': showFeaturedProductsSection,
      'showKpiCardsSection': showKpiCardsSection,
      'showJoinFamilyBanner': showJoinFamilyBanner,
      'allowedBusinessTypes': allowedBusinessTypes,
      'featuredBusinessIds': featuredBusinessIds,
      'featuredOfferIds': featuredOfferIds,
      'featuredProductIds': featuredProductIds,
      'kpiCards': kpiCards.map((e) => e.toMap()).toList(),
      'joinFamilySubtitle': joinFamilySubtitle.toMap(),
      'youtubeVideoUrl': youtubeVideoUrl,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'address': address.toMap(),
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'twitterUrl': twitterUrl,
      'linkedinUrl': linkedinUrl,
      'aboutUsContent': aboutUsContent.toMap(),
      'termsContent': termsContent.toMap(),
      'privacyContent': privacyContent.toMap(),
      'authBannerHeadline': authBannerHeadline.toMap(),
      'authBannerSubtext': authBannerSubtext.toMap(),
    };
  }

  PlatformSettings copyWith({
    bool? enableLikes,
    bool? enableReviews,
    bool? enableFollows,
    bool? showCategoriesSection,
    bool? showFeaturedBusinessesSection,
    bool? showFeaturedOffersSection,
    bool? showFeaturedProductsSection,
    bool? showKpiCardsSection,
    bool? showJoinFamilyBanner,
    List<String>? allowedBusinessTypes,
    List<String>? featuredBusinessIds,
    List<String>? featuredOfferIds,
    List<String>? featuredProductIds,
    List<KpiCardConfig>? kpiCards,
    LocalizedString? joinFamilySubtitle,
    String? youtubeVideoUrl,
    String? phone,
    String? whatsapp,
    String? email,
    LocalizedString? address,
    String? facebookUrl,
    String? instagramUrl,
    String? twitterUrl,
    String? linkedinUrl,
    LocalizedString? aboutUsContent,
    LocalizedString? termsContent,
    LocalizedString? privacyContent,
    LocalizedString? authBannerHeadline,
    LocalizedString? authBannerSubtext,
  }) {
    return PlatformSettings(
      enableLikes: enableLikes ?? this.enableLikes,
      enableReviews: enableReviews ?? this.enableReviews,
      enableFollows: enableFollows ?? this.enableFollows,
      showCategoriesSection: showCategoriesSection ?? this.showCategoriesSection,
      showFeaturedBusinessesSection: showFeaturedBusinessesSection ?? this.showFeaturedBusinessesSection,
      showFeaturedOffersSection: showFeaturedOffersSection ?? this.showFeaturedOffersSection,
      showFeaturedProductsSection: showFeaturedProductsSection ?? this.showFeaturedProductsSection,
      showKpiCardsSection: showKpiCardsSection ?? this.showKpiCardsSection,
      showJoinFamilyBanner: showJoinFamilyBanner ?? this.showJoinFamilyBanner,
      allowedBusinessTypes: allowedBusinessTypes ?? this.allowedBusinessTypes,
      featuredBusinessIds: featuredBusinessIds ?? this.featuredBusinessIds,
      featuredOfferIds: featuredOfferIds ?? this.featuredOfferIds,
      featuredProductIds: featuredProductIds ?? this.featuredProductIds,
      kpiCards: kpiCards ?? this.kpiCards,
      joinFamilySubtitle: joinFamilySubtitle ?? this.joinFamilySubtitle,
      youtubeVideoUrl: youtubeVideoUrl ?? this.youtubeVideoUrl,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      address: address ?? this.address,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      aboutUsContent: aboutUsContent ?? this.aboutUsContent,
      termsContent: termsContent ?? this.termsContent,
      privacyContent: privacyContent ?? this.privacyContent,
      authBannerHeadline: authBannerHeadline ?? this.authBannerHeadline,
      authBannerSubtext: authBannerSubtext ?? this.authBannerSubtext,
    );
  }

  factory PlatformSettings.empty() {
    return PlatformSettings(
      kpiCards: KpiCardConfig.defaultCards(),
    );
  }
}
