import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'en';
  String _currency = 'USD';

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  String get currency => _currency;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Theme
      final themeIndex = prefs.getInt('theme_mode');
      if (themeIndex != null) {
        _themeMode = ThemeMode.values[themeIndex];
      }

      // Load Language
      final lang = prefs.getString('language_code');
      if (lang != null) {
        _languageCode = lang;
      }

      // Load Currency
      final curr = prefs.getString('currency');
      if (curr != null) {
        _currency = curr;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
  }

  Future<void> setCurrency(String currencyCode) async {
    _currency = currencyCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currencyCode);
  }
}
