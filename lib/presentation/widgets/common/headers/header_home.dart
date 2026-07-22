import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/buttons.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/logo.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/cart_header_icon.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/account_header_icon.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../../data/providers/company_provider.dart';
import '../../../global/core/constants/app_constants.dart';
import '../../../global/core/responsive/responsive_layout.dart';
import '../../../../data/providers/settings_provider.dart';
import '../../../../data/providers/locale_provider.dart';
import '../../../global/translate/app_localizations.dart';
import '../../../global/translate/translation_keys.dart';
import '../../../global/router/app_routes.dart';

class HeaderHome extends StatefulWidget implements PreferredSizeWidget {
  final void Function(String section) onNavTap;
  const HeaderHome({super.key, required this.onNavTap});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  State<HeaderHome> createState() => _HeaderHomeState();
}

class _HeaderHomeState extends State<HeaderHome> {
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
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      final cid =
                          context.read<CompanyProvider>().companySettings?.id ??
                          'cmp_001';
                      if (ModalRoute.of(context)?.isFirst == true) {
                        widget.onNavTap('hero');
                      } else {
                        context.go(AppRoutes.toHome(cid));
                      }
                    },
                    child: const Logo(),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 24),
                  _NavLink(
                    label: TranslationKeys.home.tr(context),
                    onTap: () {
                      final cid =
                          context.read<CompanyProvider>().companySettings?.id ??
                          'cmp_001';
                      if (ModalRoute.of(context)?.isFirst == true) {
                        widget.onNavTap('hero');
                      } else {
                        context.go(AppRoutes.toHome(cid));
                      }
                    },
                  ),

                  _NavLink(
                    label: TranslationKeys.newArrivals.tr(context),
                    onTap: () {
                      final cid =
                          context.read<CompanyProvider>().companySettings?.id ??
                          'cmp_001';
                      if (ModalRoute.of(context)?.isFirst == true) {
                        widget.onNavTap('newArrivals');
                      } else {
                        context.go(AppRoutes.toHome(cid));
                      }
                    },
                  ),
                  _NavLink(
                    label: TranslationKeys.topSelling.tr(context),
                    onTap: () {
                      final cid =
                          context.read<CompanyProvider>().companySettings?.id ??
                          'cmp_001';
                      if (ModalRoute.of(context)?.isFirst == true) {
                        widget.onNavTap('topSelling');
                      } else {
                        context.go(AppRoutes.toHome(cid));
                      }
                    },
                  ),
                  _NavLink(
                    label: TranslationKeys.offers.tr(context),
                    onTap: () {
                      final cid =
                          context.read<CompanyProvider>().companySettings?.id ??
                          'cmp_001';
                      context.go(AppRoutes.toOffers(cid));
                    },
                  ),
                  _NavLink(
                    label: TranslationKeys.categories.tr(context),
                    onTap: () {
                      final cid =
                          context.read<CompanyProvider>().companySettings?.id ??
                          'cmp_001';
                      if (ModalRoute.of(context)?.isFirst == true) {
                        widget.onNavTap('browseCategories');
                      } else {
                        context.go(AppRoutes.toShop(cid));
                      }
                    },
                  ),
                ],
                Spacer(),
                if (!isMobile) ...[
                  // Theme Toggle
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
                  // Language Toggle
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
                  const SizedBox(width: 4),
                ],
                const CartHeaderIcon(isActive: true),
                const SizedBox(width: 4),
                const AccountHeaderIcon(),
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
