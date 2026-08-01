import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'data/providers/product_provider.dart';
import 'data/providers/category_provider.dart';
import 'data/providers/cart_provider.dart';
import 'data/providers/invoice_provider.dart';
import 'data/providers/auth_provider.dart';
import 'presentation/global/settings_provider.dart';
import 'data/providers/business_provider.dart';
import 'presentation/global/locale_provider.dart';
import 'data/providers/offer_provider.dart';
import 'data/providers/brand_provider.dart';
import 'presentation/global/translate/app_localizations.dart';
import 'presentation/global/theme/app_theme.dart';
import 'presentation/pages/customer/business_entry_page.dart';
import 'presentation/pages/super_admin/super_admin_home.dart';
import 'presentation/pages/business/admin_business_home.dart';
import 'data/models/auth/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }
  runApp(const ZEcommerceApp());
}

class ZEcommerceApp extends StatelessWidget {
  const ZEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => OfferProvider()),
        ChangeNotifierProvider(create: (_) => BrandProvider()),
      ],
      child: Consumer3<SettingsProvider, LocaleProvider, BusinessProvider>(
        builder: (context, settings, localeProvider, businessProvider, child) {
          final themeInfo = businessProvider.selectedBusiness?.theme;
          final primaryColor = themeInfo?.primaryColorValue;
          final secondaryColor = themeInfo?.secondaryColorValue;
          final backgroundColor = themeInfo?.backgroundColorValue;
          final surfaceColor = themeInfo?.surfaceColorValue;

          return MaterialApp(
            title: 'Shop.co – Find Clothes That Matches Your Style',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            locale: localeProvider.locale,
            supportedLocales: const [Locale('en', ''), Locale('ar', '')],
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
            home: const AppRootRouter(),
          );
        },
      ),
    );
  }
}

class AppRootRouter extends StatelessWidget {
  const AppRootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authProvider.currentUser;
        if (user == null) {
          return const BusinessEntryPage();
        }

        switch (user.role) {
          case UserRole.superAdmin:
            return const SuperAdminHome();
          case UserRole.businessOwner:
            return const AdminStore();
          case UserRole.customer:
            return const BusinessEntryPage();
        }
      },
    );
  }
}
