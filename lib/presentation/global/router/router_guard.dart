import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/company_provider.dart';
import 'app_routes.dart';

/// Central guard logic for the router.
/// Called on every navigation event via [GoRouter.redirect].
class RouterGuard {
  RouterGuard._();

  /// List of path segments that require authentication.
  /// List of path segments that require authentication.
  static const _authRequired = {'profile', 'order'};

  /// Evaluates redirect for the current navigation state.
  /// Returns a redirect path [String], or [null] to allow navigation.
  static String? evaluate(GoRouterState state, BuildContext context) {
    final location = state.uri.toString();
    final segments = state.uri.pathSegments; // e.g. ['cmp_001', 'checkout']

    // ── 1. Root route — no companyId ─────────────────────────────────────
    if (segments.isEmpty || location == '/') return null;

    final companyId = segments[0];
    final pagePath  = segments.length > 1 ? segments[1] : '';

    if (companyId == 'auth') return null; // let auth paths through

    // If companyId is 'profile', it's the global profile path
    if (companyId == 'profile') {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.isAuthenticated) {
        return AppRoutes.toLogin(redirectTo: location);
      }
      return null;
    }

    // ── 2. Company guard — validate companyId ────────────────────────────
    final companyProvider = Provider.of<CompanyProvider>(context, listen: false);
    if (!_isValidCompany(companyProvider, companyId)) {
      // Unknown company → back to entry
      return AppRoutes.entry;
    }

    // ── 3. Load company if not loaded or different ─────────────────────
    final currentId = companyProvider.companySettings?.id;
    if (currentId != companyId) {
      Future.microtask(() => companyProvider.loadCompanySettings(companyId));
    }

    // ── 4. Auth guard — protect certain routes ────────────────────────
    // ── 4. Auth guard — protect certain routes ────────────────────────
    bool needsAuth = _authRequired.contains(pagePath);
    if (pagePath == 'cart' && segments.length > 2 && segments[2] == 'checkout') {
      needsAuth = true;
    }
    
    if (needsAuth) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.isAuthenticated) {
        return AppRoutes.toLogin(redirectTo: location);
      }
    }

    return null; // Allow navigation
  }

  /// Checks whether the given companyId exists.
  static bool _isValidCompany(CompanyProvider provider, String companyId) {
    // If provider already loaded this company it is valid.
    if (provider.companySettings?.id == companyId) return true;
    // Otherwise accept any non-empty id and let the provider handle 404.
    return companyId.isNotEmpty;
  }
}
