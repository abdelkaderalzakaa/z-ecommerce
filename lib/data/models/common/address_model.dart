import '../../../presentation/global/translate/localized_string.dart';

class AddressModel {
  final String id;
  final String title;               // اسم مرجعي للعنوان (مثلاً: "الفرع الرئيسي"، "المنزل"، "المكتب")
  final LocalizedString country;    // الدولة (دعم عربي / إنجليزي)
  final LocalizedString city;       // المدينة / المحافظة
  final LocalizedString region;     // المنطقة / قضاء / بلدة
  final String street;              // الشارع
  final String? building;           // المبنى / اسم مجمع / طابق
  final String? details;            // تفاصيل إضافية / علامات فارقة (مثلاً: قرب صيدلية كذا)
  final String? postalCode;         // الرمز البريدي
  final double? latitude;           // خط العرض على الخريطة
  final double? longitude;          // خط الطول على الخريطة
  final bool isDefault;             // هل هو العنوان الافتراضي

  const AddressModel({
    required this.id,
    required this.title,
    required this.country,
    required this.city,
    required this.region,
    required this.street,
    this.building,
    this.details,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  // ==========================================
  // 🧮 Dynamic Getters (حسابات مفيدة)
  // ==========================================

  /// هل يحتوي العنوان على إحداثيات خريطة صالحة؟
  bool get hasCoordinates => latitude != null && longitude != null;

  /// إرجاع النص الكامل للعنوان ملخصاً بلغة محددة (مفيد للعرض السريع في الـ UI)
  String getFormattedAddress({String langCode = 'ar'}) {
    final countryStr = country.getByLanguage(langCode).trim();
    final cityStr = city.getByLanguage(langCode).trim();
    final regionStr = region.getByLanguage(langCode).trim();
    final streetStr = street.trim();
    final buildingStr = (building ?? '').trim();

    final List<String> parts = [];
    void addUnique(String val) {
      if (val.isNotEmpty && !parts.contains(val)) {
        parts.add(val);
      }
    }

    addUnique(countryStr);
    addUnique(cityStr);
    addUnique(regionStr);
    addUnique(streetStr);
    addUnique(buildingStr);

    return parts.join(' - ');
  }

  // ==========================================
  // 🔄 Serialization (fromMap, toMap & copyWith)
  // ==========================================

  factory AddressModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AddressModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      country: LocalizedString.fromMap(map['country'] ?? {}),
      city: LocalizedString.fromMap(map['city'] ?? {}),
      region: LocalizedString.fromMap(map['region'] ?? {}),
      street: map['street'] ?? '',
      building: map['building'],
      details: map['details'],
      postalCode: map['postalCode'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'country': country.toMap(),
      'city': city.toMap(),
      'region': region.toMap(),
      'street': street,
      'building': building,
      'details': details,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? title,
    LocalizedString? country,
    LocalizedString? city,
    LocalizedString? region,
    String? street,
    String? building,
    String? details,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      title: title ?? this.title,
      country: country ?? this.country,
      city: city ?? this.city,
      region: region ?? this.region,
      street: street ?? this.street,
      building: building ?? this.building,
      details: details ?? this.details,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// إنشاء كائن AddressModel فارغ بقيم افتراضية
  factory AddressModel.empty() {
    return AddressModel(
      id: '',
      title: '',
      country: const LocalizedString(ar: '', en: ''),
      city: const LocalizedString(ar: '', en: ''),
      region: const LocalizedString(ar: '', en: ''),
      street: '',
      building: '',
    );
  }
}
