import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';

enum GeoProximityTier {
  sameTown,       // في نفس البلدة / الحي (الأولوية القصوى)
  sameDistrict,   // في نفس القضاء
  sameGovernorate,// في نفس المحافظة
  allLebanon;     // في مناطق أخرى داخل لبنان

  String labelAr({String? townName, String? districtName, String? govName}) {
    switch (this) {
      case GeoProximityTier.sameTown:
        return townName?.isNotEmpty == true ? 'في $townName' : 'في بلدتك';
      case GeoProximityTier.sameDistrict:
        return districtName?.isNotEmpty == true ? 'في قضاء $districtName' : 'في قضائك';
      case GeoProximityTier.sameGovernorate:
        return govName?.isNotEmpty == true ? 'في محافظة $govName' : 'في محافظتك';
      case GeoProximityTier.allLebanon:
        return 'على مستوى لبنان';
    }
  }

  String labelEn({String? townName, String? districtName, String? govName}) {
    switch (this) {
      case GeoProximityTier.sameTown:
        return townName?.isNotEmpty == true ? 'In $townName' : 'In your town';
      case GeoProximityTier.sameDistrict:
        return districtName?.isNotEmpty == true ? 'In $districtName district' : 'In your district';
      case GeoProximityTier.sameGovernorate:
        return govName?.isNotEmpty == true ? 'In $govName governorate' : 'In your governorate';
      case GeoProximityTier.allLebanon:
        return 'All Lebanon';
    }
  }

  Color get badgeColor {
    switch (this) {
      case GeoProximityTier.sameTown:
        return const Color(0xFF10B981); // Emerald Green
      case GeoProximityTier.sameDistrict:
        return const Color(0xFF0284C7); // Sky Blue
      case GeoProximityTier.sameGovernorate:
        return const Color(0xFF6366F1); // Indigo
      case GeoProximityTier.allLebanon:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData get icon {
    switch (this) {
      case GeoProximityTier.sameTown:
        return Icons.near_me_rounded;
      case GeoProximityTier.sameDistrict:
        return Icons.location_city_rounded;
      case GeoProximityTier.sameGovernorate:
        return Icons.map_rounded;
      case GeoProximityTier.allLebanon:
        return Icons.public_rounded;
    }
  }
}

class BusinessGeoAnalysis {
  final BusinessModel business;
  final GeoProximityTier proximityTier;
  final bool canDeliver;
  final AddressModel? closestAddress;
  final String locationSnippet;

  const BusinessGeoAnalysis({
    required this.business,
    required this.proximityTier,
    required this.canDeliver,
    this.closestAddress,
    required this.locationSnippet,
  });
}

class GeoProximityService {
  static final GeoProximityService _instance = GeoProximityService._internal();
  factory GeoProximityService() => _instance;
  GeoProximityService._internal();

  /// دالة مساعدة لتنظيف ومطابقة الأسماء الجغرافية (إزالة الفراغات والهمزات والأحرف الخاصة)
  static String _normalizeGeoString(String text) {
    if (text.isEmpty) return '';
    return text
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// تحليل مدى القرب الجغرافي لمتجر محدد بالنسبة لموقع العميل
  BusinessGeoAnalysis analyzeBusinessProximity({
    required BusinessModel business,
    required List<AddressModel> businessAddresses,
    AddressModel? customerAddress,
    bool isAr = true,
  }) {
    if (customerAddress == null || customerAddress.town.isEmpty) {
      // في حال عدم تحديد عنوان للعميل: تظهر كـ عموم لبنان
      final firstAddr = businessAddresses.isNotEmpty ? businessAddresses.first : null;
      final snippet = firstAddr != null
          ? firstAddr.getFormattedAddress(langCode: isAr ? 'ar' : 'en')
          : '';

      return BusinessGeoAnalysis(
        business: business,
        proximityTier: GeoProximityTier.allLebanon,
        canDeliver: business.deliveryHandling.name != 'none',
        closestAddress: firstAddr,
        locationSnippet: snippet,
      );
    }

    final custTown = _normalizeGeoString(customerAddress.town.ar);
    final custDist = _normalizeGeoString(customerAddress.district.ar);
    final custGov = _normalizeGeoString(customerAddress.governorate.ar);

    GeoProximityTier bestTier = GeoProximityTier.allLebanon;
    AddressModel? closestAddress;

    for (final bAddr in businessAddresses) {
      final bTown = _normalizeGeoString(bAddr.town.ar);
      final bDist = _normalizeGeoString(bAddr.district.ar);
      final bGov = _normalizeGeoString(bAddr.governorate.ar);

      if (custTown.isNotEmpty && bTown.isNotEmpty && (custTown == bTown || custTown.contains(bTown) || bTown.contains(custTown))) {
        bestTier = GeoProximityTier.sameTown;
        closestAddress = bAddr;
        break; // أفضل مطابقة ممكنة
      } else if (custDist.isNotEmpty && bDist.isNotEmpty && (custDist == bDist || custDist.contains(bDist) || bDist.contains(custDist))) {
        if (bestTier.index > GeoProximityTier.sameDistrict.index) {
          bestTier = GeoProximityTier.sameDistrict;
          closestAddress = bAddr;
        }
      } else if (custGov.isNotEmpty && bGov.isNotEmpty && (custGov == bGov || custGov.contains(bGov) || bGov.contains(custGov))) {
        if (bestTier.index > GeoProximityTier.sameGovernorate.index) {
          bestTier = GeoProximityTier.sameGovernorate;
          closestAddress = bAddr;
        }
      }
    }

    closestAddress ??= businessAddresses.isNotEmpty ? businessAddresses.first : null;

    final snippet = closestAddress != null
        ? closestAddress.getFormattedAddress(langCode: isAr ? 'ar' : 'en')
        : '';

    // تحليل إمكانية التوصيل (متاح التوصيل إذا كان المتجر يدعم التوصيل وله تغطية جغرافية)
    final bool canDeliver = business.deliveryHandling.name != 'none';

    return BusinessGeoAnalysis(
      business: business,
      proximityTier: bestTier,
      canDeliver: canDeliver,
      closestAddress: closestAddress,
      locationSnippet: snippet,
    );
  }

  /// إعادة ترتيب قائمة المتاجر بذكاء وفقاً للأقرب جغرافياً وتوفر التوصيل للزبون
  List<BusinessGeoAnalysis> sortBusinessesByCustomerLocation({
    required List<BusinessModel> businesses,
    required Map<String, List<AddressModel>> businessAddressesMap,
    AddressModel? customerAddress,
    bool isAr = true,
  }) {
    final List<BusinessGeoAnalysis> analyzedList = [];

    for (final business in businesses) {
      final addresses = businessAddressesMap[business.id] ?? [];
      final analysis = analyzeBusinessProximity(
        business: business,
        businessAddresses: addresses,
        customerAddress: customerAddress,
        isAr: isAr,
      );
      analyzedList.add(analysis);
    }

    // خوارزمية الترتيب متعددة المستويات:
    analyzedList.sort((a, b) {
      // 1. القرب الجغرافي (sameTown -> sameDistrict -> sameGovernorate -> allLebanon)
      final proximityCompare = a.proximityTier.index.compareTo(b.proximityTier.index);
      if (proximityCompare != 0) return proximityCompare;

      // 2. توفر التوصيل للعميل (المتاجر التي توصل أولاً)
      if (a.canDeliver && !b.canDeliver) return -1;
      if (!a.canDeliver && b.canDeliver) return 1;

      // 3. المتاجر المعتمدة والموثقة (Verified Stores)
      if (a.business.isVerified && !b.business.isVerified) return -1;
      if (!a.business.isVerified && b.business.isVerified) return 1;

      // 4. تقييم المتجر الذكي (Smart Store Score)
      final ratingCompare = b.business.smartStoreScore.compareTo(a.business.smartStoreScore);
      if (ratingCompare != 0) return ratingCompare;

      // 5. عدد الطلبات والنشاط
      return b.business.orders.compareTo(a.business.orders);
    });

    return analyzedList;
  }
}
