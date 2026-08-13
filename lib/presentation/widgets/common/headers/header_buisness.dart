import 'package:z_ecommerce/presentation/pages/customer/offer/offers_page.dart';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/buttons.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/logo.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/cart_header_icon.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/account_header_icon.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../../data/providers/business_provider.dart';
import '../../../global/core/constants/app_constants.dart';
import '../../../global/core/responsive/responsive_layout.dart';
import '../../../global/settings_provider.dart';
import '../../../global/locale_provider.dart';
import '../../../global/translate/app_localizations.dart';
import '../../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/categories_page.dart';

class HeaderBuisness extends StatefulWidget implements PreferredSizeWidget {
  final bool isTransparent;
  const HeaderBuisness({super.key, this.isTransparent = false});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  State<HeaderBuisness> createState() => _HeaderBuisnessState();
}

class _HeaderBuisnessState extends State<HeaderBuisness> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    return ColoredBox(
      color: widget.isTransparent
          ? Colors.transparent
          : Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              children: [
                const Logo(),
                Spacer(),
                if (!isMobile) ...[
                  // Language Toggle
                  Consumer2<SettingsProvider, LocaleProvider>(
                    builder: (context, settings, localeProvider, _) {
                      final currentLang = localeProvider.locale.languageCode;
                      final isDark =
                          settings.themeMode == ThemeMode.dark ||
                          (settings.themeMode == ThemeMode.system &&
                              MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Theme Toggle
                          ButtonApp(
                            format: FormatButtonApp.icon,
                            icon: isDark ? Icons.light_mode : Icons.dark_mode,
                            color: widget.isTransparent
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            label: isDark ? 'Light Mode' : 'Dark Mode',
                            onPressed: () {
                              settings.setThemeMode(
                                isDark ? ThemeMode.light : ThemeMode.dark,
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          // Language Toggle
                          ButtonApp(
                            format: FormatButtonApp.icon,
                            icon: Icons.language,
                            color: widget.isTransparent
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            label: TranslationKeys.language.tr(context),
                            onPressed: () {
                              final newLang = currentLang == 'en' ? 'ar' : 'en';
                              settings.setLanguage(newLang);
                              localeProvider.setLocale(Locale(newLang));
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                ],
                const SizedBox(width: 4),
                const AccountHeaderIcon(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class _TopBanner extends StatelessWidget {
//   const _TopBanner();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.primary,
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             'Sign up and get 20% off to your first order. ',
//             style: TextStyle(color: Colors.white, fontSize: 13),
//           ),
//           InkWell(
//             onTap: () {},
//             child: const Text(
//               'Sign Up Now',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 decoration: TextDecoration.underline,
//                 decorationColor: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _hovered
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}
