import 'package:flutter/material.dart';
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
import 'package:z_ecommerce/presentation/pages/home_page.dart';

class HeaderAuth extends StatefulWidget implements PreferredSizeWidget {
  final String? title;

  const HeaderAuth({super.key, this.title});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  State<HeaderAuth> createState() => _HeaderAuthState();
}

class _HeaderAuthState extends State<HeaderAuth> {
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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              children: [
                /// back button
                IconButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      changeScreen(context, const HomePage());
                    }
                  },
                  icon: Icon(Icons.arrow_back_ios_outlined),
                ),
                const SizedBox(width: 8),

                /// title page
                if (widget.title != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    widget.title!,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
                
                Spacer(),

                /// Theme
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    return IconButton(
                      icon: Icon(
                        settings.themeMode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      onPressed: () {
                        settings.setThemeMode(
                          settings.themeMode == ThemeMode.dark
                              ? ThemeMode.light
                              : ThemeMode.dark,
                        );
                      },
                      tooltip: TranslationKeys.theme.tr(context),
                    );
                  },
                ),
                const SizedBox(width: 4),
                /// Language
                Consumer2<SettingsProvider, LocaleProvider>(
                  builder: (context, settings, localeProvider, _) {
                    final currentLang = localeProvider.locale.languageCode;
                    return IconButton(
                      icon: Icon(
                        Icons.language,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      onPressed: () {
                        final newLang = currentLang == 'en' ? 'ar' : 'en';
                        settings.setLanguage(newLang);
                        localeProvider.setLocale(Locale(newLang));
                      },
                      tooltip: TranslationKeys.language.tr(context),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(height: 1, color: Theme.of(context).dividerColor),
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
//           GestureDetector(
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
      child: GestureDetector(
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
