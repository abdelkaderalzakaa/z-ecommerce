import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';

class LocalizedString {
  final String ar;
  final String en;

  const LocalizedString({required this.ar, required this.en});

  String get(BuildContext context) {
    try {
      final locale = context.watch<LocaleProvider>().locale.languageCode;
      return locale == 'ar' ? ar : en;
    } catch (_) {
      // Fallback if context is not valid or doesn't have Provider
      return en; 
    }
  }

  String getByLanguage(String langCode) {
    return langCode == 'ar' ? ar : en;
  }

  Map<String, String> toJson() => {'ar': ar, 'en': en};

  Map<String, String> toMap() => toJson();

  factory LocalizedString.fromJson(Map<String, dynamic> json) {
    return LocalizedString(
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
    );
  }

  factory LocalizedString.fromMap(Map<String, dynamic> map) => LocalizedString.fromJson(map);
}
