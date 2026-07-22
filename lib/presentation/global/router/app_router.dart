import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Pages — auth
import '../../pages/auth/login_page.dart';
import '../../pages/auth/register_page.dart';
import '../../pages/auth/forgot_password_page.dart';
import '../../pages/auth/reset_password_page.dart';
import '../../pages/auth/auth_success_page.dart';

// Pages — main
import '../../pages/home_page.dart';
import '../../pages/categories_page.dart';
import '../../pages/offers_page.dart';
import '../../pages/product_details_page.dart';
import '../../pages/cart_page.dart';
import '../../pages/checkout_page.dart';
import '../../pages/profile_page.dart';
import '../../pages/order_details_page.dart';
import '../../pages/product_empty_page.dart';
import '../../pages/cart_empty_page.dart';
import '../../pages/confirm_order_page.dart';
import '../../pages/offer_details_page.dart';

// Pages — static
import '../../pages/static/about_page.dart';
import '../../pages/static/contact_us_page.dart';
import '../../pages/static/privacy_policy_page.dart';
import '../../pages/static/terms_page.dart';

// Entry page
import '../../pages/store_entry_page.dart';
import '../../pages/stores_page.dart';

// Models
import '../../../data/models/product_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/brand_model.dart';

// Providers
import '../../../data/providers/company_provider.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/providers/invoice_provider.dart';
import '../../../data/providers/user_visits_provider.dart';
import '../../../data/providers/auth_provider.dart';

// Guard + routes
import 'router_guard.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.entry,
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) {
      return RouterGuard.evaluate(state, context);
    },

    routes: [
      // ── Entry ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.entry,
        builder: (context, state) => const StoreEntryPage(),
      ),
      GoRoute(
        path: AppRoutes.stores,
        builder: (context, state) => const StoresPage(),
      ),

      // ── Profile route (Global) ────────────────────────────────────────
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/profile/:tabId',
        builder: (context, state) {
          final tabId = state.pathParameters['tabId'];
          return ProfilePage(tabId: tabId);
        },
      ),

      // ── Auth routes (Global) ──────────────────────────────────────────
      GoRoute(
        path: '/auth/login',
        builder: (context, state) {
          final redirectTo = state.uri.queryParameters['redirect'];
          return LoginPage(redirectTo: redirectTo);
        },
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) {
          final redirectTo = state.uri.queryParameters['redirect'];
          return RegisterPage(redirectTo: redirectTo);
        },
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/auth/success',
        builder: (context, state) {
          final args = state.extra as Map<String, String>?;
          return AuthSuccessPage(
            title: args?['title'] ?? '',
            message: args?['message'] ?? '',
            buttonLabel: args?['buttonLabel'] ?? '',
          );
        },
      ),

      // ── Shell: everything under /:companyId ──────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          // Load company settings whenever companyId changes.
          final companyId = state.pathParameters['companyId'] ?? '';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final provider =
                Provider.of<CompanyProvider>(context, listen: false);
            if (provider.companySettings?.id != companyId &&
                companyId.isNotEmpty) {
              provider.loadCompanySettings(companyId);
            }

            if (companyId.isNotEmpty) {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (auth.isAuthenticated) {
                final visitsProvider = Provider.of<UserVisitsProvider>(context, listen: false);
                visitsProvider.recordVisit(companyId);
              }
            }
          });
          return child;
        },
        routes: [
          // ── Home ─────────────────────────────────────────────────────────
          GoRoute(
            path: '/:companyId',
            builder: (context, state) => const HomePage(),
          ),

          // ── Offers ───────────────────────────────────────────────────────
          GoRoute(
            path: '/:companyId/offers',
            builder: (context, state) {
              final type = state.uri.queryParameters['type'];
              return OffersPage(offerType: type);
            },
          ),
          GoRoute(
            path: '/:companyId/offer/:offerId',
            builder: (context, state) {
              final offerId = state.pathParameters['offerId']!;
              return OfferDetailsPage(offerId: offerId);
            },
          ),

          // ── Shop / Categories ─────────────────────────────────────────────
          GoRoute(
            path: '/:companyId/shop',
            builder: (context, state) {
              CategoryModel? category = state.extra as CategoryModel?;
              if (category == null) {
                final categoryName = state.uri.queryParameters['category'];
                if (categoryName != null) {
                   final provider = Provider.of<CategoryProvider>(context, listen: false);
                   category = provider.categories.where((c) => c.label == categoryName).firstOrNull;
                }
              }

              BrandModel? brand = state.extra is BrandModel ? state.extra as BrandModel : null;
              if (brand == null) {
                final brandName = state.uri.queryParameters['brand'];
                if (brandName != null) {
                   final provider = Provider.of<CompanyProvider>(context, listen: false);
                   brand = provider.companySettings?.brands.where((b) => b.name == brandName).firstOrNull;
                }
              }
              
              final onSale = state.uri.queryParameters['on_sale'] == 'true';
              
              return CategoriesPage(category: category, brand: brand, onSale: onSale);
            },
          ),

          // ── Product Details ───────────────────────────────────────────────
          GoRoute(
            path: '/:companyId/product/:productId',
            builder: (context, state) {
              Product? productOpt = state.extra as Product?;
              final Product product;
              if (productOpt == null) {
                final productId = state.pathParameters['productId']!;
                final provider = Provider.of<ProductProvider>(context, listen: false);
                product = provider.allProducts.firstWhere(
                  (p) => p.id == productId,
                  orElse: () => provider.allProducts.first,
                );
              } else {
                product = productOpt;
              }
              return ProductDetailsPage(product: product);
            },
          ),
          GoRoute(
            path: '/:companyId/shop/product/:productId',
            builder: (context, state) {
              Product? productOpt = state.extra as Product?;
              final Product product;
              if (productOpt == null) {
                final productId = state.pathParameters['productId']!;
                final provider = Provider.of<ProductProvider>(context, listen: false);
                product = provider.allProducts.firstWhere(
                  (p) => p.id == productId,
                  orElse: () => provider.allProducts.first,
                );
              } else {
                product = productOpt;
              }
              return ProductDetailsPage(product: product);
            },
          ),
          GoRoute(
            path: '/:companyId/product-empty',
            builder: (context, state) => const ProductEmptyPage(),
          ),

          // ── Cart ──────────────────────────────────────────────────────────
          GoRoute(
            path: '/:companyId/cart',
            builder: (context, state) => const CartPage(),
          ),
          GoRoute(
            path: '/:companyId/cart-empty',
            builder: (context, state) => const CartEmptyPage(),
          ),

          // ── Checkout (Auth required — handled by RouterGuard) ─────────────
          GoRoute(
            path: '/:companyId/cart/checkout',
            builder: (context, state) => const CheckoutPage(),
          ),
          GoRoute(
            path: '/:companyId/cart/checkout/confirm',
            builder: (context, state) => const ConfirmOrderPage(),
          ),


          // ── Order Details (Auth required) ─────────────────────────────────
          GoRoute(
            path: '/:companyId/order/:orderId',
            builder: (context, state) {
              InvoiceModel? invoice = state.extra as InvoiceModel?;
              if (invoice == null) {
                final orderId = state.pathParameters['orderId']!;
                final provider = Provider.of<InvoiceProvider>(context, listen: false);
                invoice = provider.invoices.firstWhere(
                  (i) => i.invoiceId == orderId,
                  orElse: () => provider.invoices.first,
                );
              }
              return OrderDetailsPage(invoice: invoice);
            },
          ),

        


          // ── Static pages ──────────────────────────────────────────────────
          GoRoute(
            path: '/:companyId/about',
            builder: (context, state) => const AboutPage(),
          ),
          GoRoute(
            path: '/:companyId/contact',
            builder: (context, state) => const ContactUsPage(),
          ),
          GoRoute(
            path: '/:companyId/privacy',
            builder: (context, state) => const PrivacyPolicyPage(),
          ),
          GoRoute(
            path: '/:companyId/terms',
            builder: (context, state) => const TermsPage(),
          ),
        ],
      ),

    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
