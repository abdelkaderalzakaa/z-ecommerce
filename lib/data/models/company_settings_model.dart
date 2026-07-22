import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/core/constants/payment_methods_constant.dart';
import 'localized_string.dart';
import 'brand_model.dart';
export '../../presentation/global/core/constants/payment_methods_constant.dart';
class CompanySettingsModel {
  final String id;

  final StoreCategoryModel category;
  final LocalizedString name;
  final List<CompanyAddressModel>? addresses;

  final LocalizedString slogan;
  final LocalizedString description;
  final LocalizedString footerDescription;

  final int? orders;
  final int? followers;
  final List<FollowersStore>? followersUsers;

  final int? visitor;

  final List<StoreStatistic>? heroCards;

 
  final List<RatingStore>? ratingStore;

  final StoreTheme theme;
  final List<BrandModel> brands;

  final String currency;
  final double deliveryFee;

  final LocalizedString aboutUs;
  final LocalizedString termsAndConditions;
  final LocalizedString privacyPolicy;
  final List<SocialModel> socials;

  final List<PaymentMethodType> paymentMethods;

  const CompanySettingsModel({
    required this.id,
    required this.category,
    required this.name,
    this.addresses,
    required this.slogan,
    required this.description,
    required this.footerDescription,
    this.orders,
    this.followers,
    this.followersUsers,
    this.visitor,
    this.heroCards,
    this.ratingStore,
    required this.theme,
    required this.brands,
    required this.currency,
    required this.deliveryFee,
    required this.aboutUs,
    required this.termsAndConditions,
    required this.privacyPolicy,
    required this.socials,
    this.paymentMethods = const [PaymentMethodType.cod],
  });
   /// تم تحويلها إلى دالة getter تحسب التقييم بناءً على التقييمات، الطلبات، المتابعين، والزيارات
  double get rate {
    double avgUserRating = 0.0;
    if (ratingStore != null && ratingStore!.isNotEmpty) {
      final totalRating = ratingStore!.map((r) => r.rating).fold(0, (a, b) => a + b);
      avgUserRating = totalRating / ratingStore!.length;
    } else {
      avgUserRating = 3.5; // Default base rating if no reviews
    }

    // Calculate engagement bonus
    final double ordersScore = (orders ?? 0) / 1000.0; 
    final double followersScore = (followers ?? 0) / 5000.0; 
    final double visitorsScore = (visitor ?? 0) / 10000.0; 

    double engagementBonus = (ordersScore * 0.5) + (followersScore * 0.3) + (visitorsScore * 0.2);
    if (engagementBonus > 1.5) engagementBonus = 1.5;

    final double finalRate = avgUserRating + engagementBonus;
    return finalRate > 5.0 ? 5.0 : finalRate;
  }
}

class StoreStatistic {
  final LocalizedString value;
  final LocalizedString label;
  final String? icon;
  final String? imageUrl;

  const StoreStatistic({
    required this.value,
    required this.label,
    this.icon,
    this.imageUrl,
  });
}

class StoreTheme {
  final String primaryColor;
  final String secondaryColor;
  final bool isDarkModeEnabled;

  const StoreTheme({
    required this.primaryColor,
    required this.secondaryColor,
    this.isDarkModeEnabled = false,
  });
}

enum SocialType {
  instagram,
  facebook,
  whatsapp,
  twitter,
  tiktok,
  linkedin,
  youtube,
  contactPhoneFirst,
  contactPhoneSecond,
  contactEmail,
}


class SocialModel {
  final LocalizedString title;
  final String link;
  final String icon;
  final Color color;
  final SocialType socialType;

  const SocialModel({
    required this.title,
    required this.link,
    required this.icon,
    required this.color,
    required this.socialType,
  });
}

class CompanyAddressModel {
  final LocalizedString address;
  final bool isTHIS;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String linkMap;

  CompanyAddressModel({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.linkMap,
    required this.imageUrl,
    required this.isTHIS,
  });
}



class RatingStore {
  final String idUser;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final int like;

  const RatingStore({
    required this.idUser,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.like,
  });
}

class FollowersStore {
  final String idUser;
  final DateTime createdAt;

  FollowersStore({required this.idUser, required this.createdAt});
}

class StoreCategoryModel {
  final String id;
  final LocalizedString name;
  final String? icon;
  final String? imageUrl;

  const StoreCategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.imageUrl,
  });
}

