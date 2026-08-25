import '../../../presentation/global/translate/localized_string.dart';

/// نوع وتصنيف العنوان
enum AddressType {
  home,    // 🏠 المنزل
  office,  // 🏢 المكتب أو مقر العمل
  main,    // 🏪 الفرع الرئيسي (للمتاجر والشركات)
  other;   // 📍 آخر / عنوان مخصص

  String displayName({bool isAr = true}) {
    switch (this) {
      case AddressType.home:
        return isAr ? 'المنزل' : 'Home';
      case AddressType.office:
        return isAr ? 'المكتب / العمل' : 'Office';
      case AddressType.main:
        return isAr ? 'الفرع الرئيسي' : 'Main Branch';
      case AddressType.other:
        return isAr ? 'آخر' : 'Other';
    }
  }

  static AddressType fromString(String? val) {
    if (val == null) return AddressType.other;
    return AddressType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => AddressType.other,
    );
  }
}

/// 📍 AddressModel - النموذج الموحد والشامل لكافة العناوين والمواقع في المنصة
class AddressModel {
  // ---------------------------------------------------------------------------
  // 1️⃣ المعرفات وهوية المستخدم (System & User Ownership)
  // ---------------------------------------------------------------------------

  /// 🔹 معرف فريد للعنوان يتم توليده تلقائياً عبر النظام (System Generated ID)
  final String id;

  /// 🔹 معرف المستخدم المالك للعنوان (User ID / Customer ID / Business ID / Driver ID)
  final String userId;

  /// 🔹 دور ونوع المستخدم المالك (customer, business, delivery, superAdmin)
  final String userType;

  /// 🔹 نوع وتصنيف العنوان (منزل، مكتب، فرع رئيسي، آخر)
  final AddressType type;

  /// 🔹 الاسم المرجعي للعنوان (مثلاً: "الفرع الرئيسي"، "منزل بيروت"، "مكتب بعبدا")
  final String title;

  // ---------------------------------------------------------------------------
  // 2️⃣ التدرج الجغرافي اللبناني (Sourced from assets/json/country_lebanon.json)
  // ---------------------------------------------------------------------------

  /// 🔹 الدولة (افتراضياً: لبنان / Lebanon)
  final LocalizedString country;

  /// 🔹 المحافظة (Governorate)
  final LocalizedString governorate;

  /// 🔹 القضاء (District)
  final LocalizedString district;

  /// 🔹 البلدة / المدينة / الحي (Town / City / Village)
  final LocalizedString town;

  // ---------------------------------------------------------------------------
  // 3️⃣ التفاصيل الدقيقة للموقع (User Input Text Fields)
  // ---------------------------------------------------------------------------

  /// 🔹 اسم الشارع (Street Name)
  final String street;

  /// 🔹 المبنى / المجمع / الطابق / رقم الشقة (Building / Floor / Unit)
  final String? building;

  /// 🔹 تفاصيل إضافية / علامة فارقة (Landmark / Delivery Notes)
  final String? details;

  /// 🔹 الرمز البريدي (Postal Code)
  final String? postalCode;

  // ---------------------------------------------------------------------------
  // 4️⃣ الإحداثيات الجغرافية والخريطة (GPS & Map Coordinates)
  // ---------------------------------------------------------------------------

  /// 🔹 خط العرض على الخريطة (Latitude)
  final double? latitude;

  /// 🔹 خط الطول على الخريطة (Longitude)
  final double? longitude;

  // ---------------------------------------------------------------------------
  // 5️⃣ التفضيلات والتواريخ (Preferences & Timestamps)
  // ---------------------------------------------------------------------------

  /// 🔹 هل هو العنوان الافتراضي للمستخدم؟
  final bool isDefault;

  /// 🔹 تاريخ إنشاء العنوان
  final DateTime? createdAt;

  /// 🔹 تاريخ آخر تحديث للعنوان
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    this.userId = '',
    this.userType = 'customer',
    this.type = AddressType.other,
    required this.title,
    this.country = const LocalizedString(ar: 'لبنان', en: 'Lebanon'),
    LocalizedString? governorate,
    LocalizedString? district,
    LocalizedString? town,
    LocalizedString? city,
    LocalizedString? region,
    required this.street,
    this.building,
    this.details,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  })  : governorate = governorate ?? const LocalizedString(ar: '', en: ''),
        district = district ?? (region ?? const LocalizedString(ar: '', en: '')),
        town = town ?? (city ?? const LocalizedString(ar: '', en: ''));

  const AddressModel.raw({
    required this.id,
    this.userId = '',
    this.userType = 'customer',
    this.type = AddressType.other,
    required this.title,
    this.country = const LocalizedString(ar: 'لبنان', en: 'Lebanon'),
    this.governorate = const LocalizedString(ar: '', en: ''),
    this.district = const LocalizedString(ar: '', en: ''),
    this.town = const LocalizedString(ar: '', en: ''),
    required this.street,
    this.building,
    this.details,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // 🧮 Backward Compatibility & Helper Getters
  // ==========================================

  /// التوافق العكسي مع الحقول القديمة (city = town)
  LocalizedString get city => town;

  /// التوافق العكسي مع الحقول القديمة (region = district)
  LocalizedString get region => district;

  /// هل يحتوي العنوان على إحداثيات GPS صالحة؟
  bool get hasCoordinates => latitude != null && longitude != null;

  /// إرجاع النص الكامل للعنوان ملخصاً ومرتباً لعرضه السريع في الواجهات وبطاقات الطلب
  String getFormattedAddress({String langCode = 'ar'}) {
    final countryStr = country.getByLanguage(langCode).trim();
    final govStr = governorate.getByLanguage(langCode).trim();
    final distStr = district.getByLanguage(langCode).trim();
    final townStr = town.getByLanguage(langCode).trim();
    final streetStr = street.trim();
    final buildingStr = (building ?? '').trim();

    final List<String> parts = [];
    void addUnique(String val) {
      if (val.isNotEmpty && !parts.contains(val)) {
        parts.add(val);
      }
    }

    addUnique(countryStr);
    addUnique(govStr);
    addUnique(distStr);
    addUnique(townStr);
    addUnique(streetStr);
    addUnique(buildingStr);

    return parts.join(' - ');
  }

  // ==========================================
  // 🔄 Serialization (fromMap & toMap)
  // ==========================================

  factory AddressModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is DateTime) return date;
      return DateTime.tryParse(date.toString());
    }

    return AddressModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      userType: map['userType'] ?? 'customer',
      type: AddressType.fromString(map['type']),
      title: map['title'] ?? '',
      country: map['country'] != null
          ? LocalizedString.fromMap(map['country'] is Map ? map['country'] : {})
          : const LocalizedString(ar: 'لبنان', en: 'Lebanon'),
      governorate: map['governorate'] != null
          ? LocalizedString.fromMap(map['governorate'] is Map ? map['governorate'] : {})
          : LocalizedString.fromMap(map['region'] is Map ? map['region'] : {}),
      district: map['district'] != null
          ? LocalizedString.fromMap(map['district'] is Map ? map['district'] : {})
          : LocalizedString.fromMap(map['region'] is Map ? map['region'] : {}),
      town: map['town'] != null
          ? LocalizedString.fromMap(map['town'] is Map ? map['town'] : {})
          : LocalizedString.fromMap(map['city'] is Map ? map['city'] : {}),
      street: map['street'] ?? '',
      building: map['building'],
      details: map['details'],
      postalCode: map['postalCode'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isDefault: map['isDefault'] ?? false,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userType': userType,
      'type': type.name,
      'title': title,
      'country': country.toMap(),
      'governorate': governorate.toMap(),
      'district': district.toMap(),
      'town': town.toMap(),
      'city': town.toMap(),
      'region': district.toMap(),
      'street': street,
      'building': building,
      'details': details,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? userType,
    AddressType? type,
    String? title,
    LocalizedString? country,
    LocalizedString? governorate,
    LocalizedString? district,
    LocalizedString? town,
    String? street,
    String? building,
    String? details,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      type: type ?? this.type,
      title: title ?? this.title,
      country: country ?? this.country,
      governorate: governorate ?? this.governorate,
      district: district ?? this.district,
      town: town ?? this.town,
      street: street ?? this.street,
      building: building ?? this.building,
      details: details ?? this.details,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// إنشاء كائن AddressModel فارغ بقيم افتراضية
  factory AddressModel.empty() {
    return const AddressModel.raw(
      id: '',
      userId: '',
      userType: 'customer',
      type: AddressType.other,
      title: '',
      country: LocalizedString(ar: 'لبنان', en: 'Lebanon'),
      governorate: LocalizedString(ar: '', en: ''),
      district: LocalizedString(ar: '', en: ''),
      town: LocalizedString(ar: '', en: ''),
      street: '',
      building: '',
    );
  }
}
