import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/providers/product_provider.dart';
import 'data/providers/category_provider.dart';
import 'data/providers/cart_provider.dart';
import 'data/providers/invoice_provider.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/settings_provider.dart';
import 'data/providers/company_provider.dart';
import 'data/providers/locale_provider.dart';
import 'data/providers/user_visits_provider.dart';
import 'data/providers/offer_provider.dart';
import 'data/providers/super_admin_stores_provider.dart';
import 'presentation/global/translate/app_localizations.dart';
import 'presentation/global/theme/app_colors.dart';
import 'presentation/global/theme/app_theme.dart';
import 'presentation/pages/store_entry_page.dart';
void main() {
  runApp(const ZEcommerceApp());
}

class ZEcommerceApp extends StatelessWidget {
  const ZEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => UserVisitsProvider()),
        ChangeNotifierProvider(create: (_) => OfferProvider()),
        ChangeNotifierProvider(create: (_) => SuperAdminStoresProvider()),
      ],
      child: Consumer3<SettingsProvider, LocaleProvider, CompanyProvider>(
        builder: (context, settings, localeProvider, companyProvider, child) {
          final themeInfo = companyProvider.companySettings?.theme;
          final primaryColor = themeInfo?.primaryColor != null 
              ? HexColor.fromHex(themeInfo!.primaryColor) 
              : null;
          final secondaryColor = themeInfo?.secondaryColor != null 
              ? HexColor.fromHex(themeInfo!.secondaryColor) 
              : null;
          final backgroundColor = themeInfo?.backgroundColor != null
              ? HexColor.fromHex(themeInfo!.backgroundColor)
              : null;
          final surfaceColor = themeInfo?.surfaceColor != null
              ? HexColor.fromHex(themeInfo!.surfaceColor)
              : null;

          return MaterialApp(
            title: 'Shop.co – Find Clothes That Matches Your Style',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('ar', ''),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.getLightTheme(
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              backgroundColor: backgroundColor,
              surfaceColor: surfaceColor,
              fontFamily: themeInfo?.fontFamily,
              buttonRadius: themeInfo?.buttonRadius,
              cardRadius: themeInfo?.cardRadius,
              inputRadius: themeInfo?.inputRadius,
            ),
            darkTheme: AppTheme.getDarkTheme(
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
            ),
            home: const StoreEntryPage(),
          );
        },
      ),
    );
  }
}

