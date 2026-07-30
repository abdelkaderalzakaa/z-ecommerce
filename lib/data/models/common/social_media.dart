import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import '../../../presentation/global/translate/localized_string.dart';


class SocialModel {
  final LocalizedString title;
  final String url;
  final String icon;
  final Color color;
  final SocialPlatform platform;
  final bool isVisible;          // هل تظهر للعملاء
  
  const SocialModel({
    required this.title,
    required this.url,
    required this.icon,
    required this.color,
    required this.platform,
    this.isVisible = true,
  });

  factory SocialModel.fromMap(Map<String, dynamic> map) {
    return SocialModel(
      title: map['title'] is Map<String, dynamic>
          ? LocalizedString.fromJson(map['title'])
          : LocalizedString(ar: map['title']?.toString() ?? '', en: map['title']?.toString() ?? ''),
      url: map['url'] ?? map['link'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] != null
          ? Color(map['color'] is int ? map['color'] : int.parse(map['color'].toString()))
          : const Color(0xFF000000),
      platform: map['platform'] != null
          ? SocialPlatform.values.firstWhere(
              (e) => e.name == map['platform'],
              orElse: () => SocialPlatform.instagram,
            )
          : SocialPlatform.instagram,
      isVisible: map['isVisible'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title.toJson(),
      'url': url,
      'icon': icon,
      'color': color.value,
      'platform': platform.name,
      'isVisible': isVisible,
    };
  }
}
