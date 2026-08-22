import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/pages/business/home/admin_business_home.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry.dart';
 import 'package:z_ecommerce/presentation/pages/super_admin/super_admin_home.dart';
import 'data/providers/product_provider.dart';
import 'data/providers/category_provider.dart';
import 'data/providers/cart_provider.dart';
import 'data/providers/invoice_provider.dart';
import 'data/providers/order_provider.dart';
import 'data/providers/auth_provider.dart';
import 'presentation/global/settings_provider.dart';
import 'data/providers/business_provider.dart';
import 'presentation/global/locale_provider.dart';
import 'data/providers/offer_provider.dart';
import 'data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';

import 'data/providers/review_provider.dart';
import 'data/providers/like_provider.dart';
import 'data/providers/follower_provider.dart';
import 'data/providers/customer_provider.dart';
import 'data/providers/product_filter_provider.dart';
import 'presentation/global/translate/app_localizations.dart';
import 'presentation/global/theme/app_theme.dart';
import 'presentation/pages/customer/business_page.dart'; 
import 'data/models/auth/user_model.dart';
import 'presentation/pages/auth/banned_page.dart';
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
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => OfferProvider()),
        ChangeNotifierProvider(create: (_) => BrandProvider()),
        ChangeNotifierProvider(create: (_) => SuperAdminProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => FollowerProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ProductFilterProvider()),
      ],
      child: Consumer3<SettingsProvider, LocaleProvider, BusinessProvider>(
        builder: (context, settings, localeProvider, businessProvider, child) {
          final themeInfo = businessProvider.selectedBusiness.theme;
          final primaryColor = themeInfo.primaryColorValue;
          final secondaryColor = themeInfo.secondaryColorValue;
          final backgroundColor = themeInfo.backgroundColorValue;
          final surfaceColor = themeInfo.surfaceColorValue;

          return MaterialApp(
            onGenerateTitle: (context) {
              final superAdmin = context
                  .watch<SuperAdminProvider>()
                  .currentSuperAdmin;
              final saName = superAdmin?.localizationAdmin.name.get(context);
              final platformName = (saName != null && saName.isNotEmpty)
                  ? saName
                  : 'z-matajer';

              final bName = businessProvider.selectedBusiness.localization.name
                  .get(context);
              return (bName.isNotEmpty) ? bName : platformName;
            },
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
              fontFamily: themeInfo.fontFamily,
              buttonRadius: themeInfo.buttonRadius,
              cardRadius: themeInfo.cardRadius,
              inputRadius: themeInfo.inputRadius,
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

class AppRootRouter extends StatefulWidget {
  const AppRootRouter({super.key});

  @override
  State<AppRootRouter> createState() => _AppRootRouterState();
}

class _AppRootRouterState extends State<AppRootRouter> {
  String? _lastUserId;

  // @override
  // void initState() {
  //   super.initState();
  //   Future.microtask(() {
  //     if (mounted) {
  //       context.read<SuperAdminProvider>().saveSuperAdminOnce();
  //     }
  //   });
  // }

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

        if (user?.id != _lastUserId) {
          _lastUserId = user?.id;
          if (user != null) {
            Future.microtask(() {
              if (mounted) {
                context.read<LikeProvider>().listenToUserLikes(user.id);
                context.read<FollowerProvider>().listenToUserFollowing(user.id);
              }
            });
          }
        }

        if (user == null) {
          return const BusinessEntry();
        }

        if (!user.isActive) {
          return const BannedPage();
        }

        switch (user.role) {
          case UserRole.superAdmin:
            return const SuperAdminHome();
          case UserRole.businessOwner:
            if (user.businessId != null) {
              Future.microtask(() {
                if (context.read<BusinessProvider>().selectedBusiness.id !=
                    user.businessId) {
                  context.read<BusinessProvider>().selectBusiness(
                    user.businessId!,
                  );
                }
              });
            }
            return const AdminStore();
          case UserRole.customer:
            return const BusinessEntry();
        }
      },
    );
  }
}
