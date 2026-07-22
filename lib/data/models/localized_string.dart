import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

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
}
