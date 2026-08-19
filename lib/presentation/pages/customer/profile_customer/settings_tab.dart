import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/locale_provider.dart';
import 'package:z_ecommerce/presentation/global/settings_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationKeys.settings.tr(context),
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isAr
                  ? 'تخصيص لغة المنصة والمظهر البصري'
                  : 'Customize platform language and application theme',
              style: AppTextStyles.bodyText(context).copyWith(fontSize: 13),
            ),
            const SizedBox(height: 28),

            // 1. Language Setting Card (اللغة)
            _buildSettingsCard(
              context: context,
              icon: Icons.language_outlined,
              title: TranslationKeys.language.tr(context),
              subtitle: isAr ? 'اختر لغة العرض المناسبة لك' : 'Select your preferred application language',
              trailingWidget: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: context.watch<LocaleProvider>().locale.languageCode,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  onChanged: (String? newLang) {
                    if (newLang != null) {
                      settings.setLanguage(newLang);
                      context.read<LocaleProvider>().setLocale(Locale(newLang));
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'ar',
                      child: Row(
                        children: const [
                          Icon(Icons.flag_outlined, size: 16),
                          SizedBox(width: 8),
                          Text('العربية (Arabic)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Row(
                        children: const [
                          Icon(Icons.language, size: 16),
                          SizedBox(width: 8),
                          Text('English'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Theme Setting Card (الثيم)
            _buildSettingsCard(
              context: context,
              icon: Icons.palette_outlined,
              title: TranslationKeys.theme.tr(context),
              subtitle: isAr ? 'اختر المظهر البصري (الوضع الداكن/الفاتح)' : 'Select visual appearance (Dark/Light mode)',
              trailingWidget: DropdownButtonHideUnderline(
                child: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  dropdownColor: theme.cardColor,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) {
                      settings.setThemeMode(newMode);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Row(
                        children: [
                          const Icon(Icons.brightness_auto, size: 16),
                          const SizedBox(width: 8),
                          Text(TranslationKeys.systemDefault.tr(context)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Row(
                        children: [
                          const Icon(Icons.light_mode_outlined, size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(TranslationKeys.light.tr(context)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Row(
                        children: [
                          const Icon(Icons.dark_mode_outlined, size: 16, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text(TranslationKeys.dark.tr(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailingWidget,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyText(context).copyWith(fontSize: 12),
        ),
        trailing: trailingWidget,
      ),
    );
  }
}
