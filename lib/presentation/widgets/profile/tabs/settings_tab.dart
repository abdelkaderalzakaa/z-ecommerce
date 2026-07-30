import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../global/settings_provider.dart';
import '../../../global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationKeys.settings.tr(context),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Appearance Section
            _buildSectionHeader(context, TranslationKeys.appearance.tr(context)),
            Card(
              color: Theme.of(context).cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(TranslationKeys.theme.tr(context)),
                    subtitle: Text(TranslationKeys.selectApplicationTheme.tr(context)),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<ThemeMode>(
                        value: settings.themeMode,
                        onChanged: (ThemeMode? newMode) {
                          if (newMode != null) {
                            settings.setThemeMode(newMode);
                          }
                        },
                        items: [
                          DropdownMenuItem(value: ThemeMode.system, child: Text(TranslationKeys.systemDefault.tr(context))),
                          DropdownMenuItem(value: ThemeMode.light, child: Text(TranslationKeys.light.tr(context))),
                          DropdownMenuItem(value: ThemeMode.dark, child: Text(TranslationKeys.dark.tr(context))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Localization Section
            _buildSectionHeader(context, TranslationKeys.localization.tr(context)),
            Card(
              color: Theme.of(context).cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(TranslationKeys.language.tr(context)),
                    subtitle: Text(TranslationKeys.selectApplicationLanguage.tr(context)),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: context.watch<LocaleProvider>().locale.languageCode,
                        onChanged: (String? newLang) {
                          if (newLang != null) {
                            settings.setLanguage(newLang);
                            context.read<LocaleProvider>().setLocale(Locale(newLang));
                          }
                        },
                        items: [
                          DropdownMenuItem(value: 'en', child: Text(TranslationKeys.english.tr(context))),
                          DropdownMenuItem(value: 'ar', child: Text(TranslationKeys.arabic.tr(context))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Regional Section
            _buildSectionHeader(context, TranslationKeys.regional.tr(context)),
            Card(
              color: Theme.of(context).cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.attach_money_outlined),
                    title: Text(TranslationKeys.currency.tr(context)),
                    subtitle: Text(TranslationKeys.selectPreferredCurrency.tr(context)),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: settings.currency,
                        onChanged: (String? newCurrency) {
                          if (newCurrency != null) {
                            settings.setCurrency(newCurrency);
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'USD', child: Text('USD (\$)', style: TextStyle(fontWeight: FontWeight.w600))),
                          DropdownMenuItem(value: 'EUR', child: Text('EUR (€)', style: TextStyle(fontWeight: FontWeight.w600))),
                          DropdownMenuItem(value: 'AED', child: Text('AED (د.إ)', style: TextStyle(fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
