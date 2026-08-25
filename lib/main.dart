import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/pages/business/home/admin_business_home.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/super_admin_home.dart';
import 'data/providers/product_provider.dart';
import 'data/providers/category_provider.dart';
import 'data/providers/cart_provider.dart';
import 'data/providers/order_provider.dart';
import 'data/providers/auth_provider.dart';
import 'presentation/global/settings_provider.dart';
import 'data/providers/business_provider.dart';
import 'presentation/global/locale_provider.dart';
import 'data/providers/offer_provider.dart';
import 'data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'data/providers/delivery_provider.dart';
import 'data/providers/address_provider.dart';
import 'data/providers/review_provider.dart';
import 'data/providers/like_provider.dart';
import 'data/providers/follower_provider.dart';
import 'data/providers/customer_provider.dart';
import 'data/providers/product_filter_provider.dart';
import 'presentation/global/translate/app_localizations.dart';
import 'presentation/global/theme/app_theme.dart';
import 'presentation/pages/auth/banned_page.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/super_admin/setup/platform_setup_page.dart';
import 'package:z_ecommerce/presentation/pages/delivery/delivery_home.dart';

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
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child:
          Consumer4<
            SettingsProvider,
            LocaleProvider,
            BusinessProvider,
            SuperAdminProvider
          >(
            builder:
                (
                  context,
                  settings,
                  localeProvider,
                  businessProvider,
                  superAdminProvider,
                  child,
                ) {
                  return MaterialApp(
                    onGenerateTitle: (context) {
                      final platformName = superAdminProvider
                          .platformLocalization
                          .name
                          .get(context);
                      final fallbackName = platformName.isNotEmpty
                          ? platformName
                          : 'z-matajer';

                      final bName = businessProvider
                          .selectedBusiness
                          .localization
                          .name
                          .get(context);
                      return (bName.isNotEmpty) ? bName : fallbackName;
                    },
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
                    theme: AppTheme.getThemeFromAdmin(superAdminProvider.platformTheme, false),
                    darkTheme: AppTheme.getThemeFromAdmin(superAdminProvider.platformTheme, true),
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SuperAdminProvider>(
      builder: (context, authProvider, superAdminProvider, _) {
        if (superAdminProvider.isCheckingPlatform) {
          return const SplashScreen();
        }

        // إذا لم تكن المنصة مهيأة بعد، عرض معالج التأسيس لمرة واحدة
        if (!superAdminProvider.isPlatformInitialized) {
          return const PlatformSetupPage();
        }

        if (!authProvider.isInitialized || authProvider.isLoading) {
          return const SplashScreen();
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
            final businessProvider = context.watch<BusinessProvider>();
            if (user.businessId != null && user.businessId!.isNotEmpty) {
              if (businessProvider.selectedBusiness.id != user.businessId) {
                if (!businessProvider.isLoading) {
                  Future.microtask(() {
                    context.read<BusinessProvider>().selectBusiness(
                      user.businessId!,
                    );
                  });
                }
                return const SplashScreen();
              }
            }
            return const AdminStore();
          case UserRole.customer:
            return const BusinessEntry();
          case UserRole.delivery:
            return const DeliveryPortalHome();
        }
      },
    );
  }
}
