/// Central route constants and path helpers for the app.
/// All navigation must go through these helpers — no raw strings allowed.
class AppRoutes {
  AppRoutes._();

  // ─── Route name constants ─────────────────────────────────────────────────
  static const String entry    = '/';
  static const String stores   = '/stores';
  static const String home     = '/:companyId';
  static const String shop     = '/:companyId/shop';
  static const String product  = '/:companyId/product/:productId';
  static const String shopProduct = '/:companyId/shop/product/:productId';
  static const String productEmpty = '/:companyId/product-empty';
  static const String offers   = '/:companyId/offers';
  static const String offerDetails = '/:companyId/offer/:offerId';
  static const String cart     = '/:companyId/cart';
  static const String cartEmpty = '/:companyId/cart-empty';
  static const String checkout = '/:companyId/cart/checkout';
  static const String confirmOrder = '/:companyId/cart/checkout/confirm';
  static const String order    = '/:companyId/order/:orderId';
  static const String settings = '/:companyId/settings';

  // Auth
  static const String login          = '/auth/login';
  static const String register       = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword  = '/auth/reset-password';
  static const String authSuccess    = '/auth/success';

  // Global Profile
  static const String profile = '/profile';
  static const String profileTab = '/profile/:tabId';

  // Static pages
  static const String about   = '/:companyId/about';
  static const String contact = '/:companyId/contact';
  static const String privacy = '/:companyId/privacy';
  static const String terms   = '/:companyId/terms';

  // ─── Path builders ────────────────────────────────────────────────────────
  static String toStores() => '/stores';

  /// Home / store root
  static String toHome(String cid) => '/$cid';

  /// Offers Page
  static String toOffers(String cid, {String? type}) {
    final base = '/$cid/offers';
    return type != null ? '$base?type=${Uri.encodeComponent(type)}' : base;
  }

  /// Offer Details
  static String toOfferDetails(String cid, String offerId) => '/$cid/offer/$offerId';

  /// Products / shop listing
  static String toShop(String cid, {String? category, String? brand, bool onSale = false}) {
    final base = '/$cid/shop';
    final queryParams = <String>[];
    if (category != null && category.isNotEmpty) {
      queryParams.add('category=${Uri.encodeComponent(category)}');
    }
    if (brand != null && brand.isNotEmpty) {
      queryParams.add('brand=${Uri.encodeComponent(brand)}');
    }
    if (onSale) {
      queryParams.add('on_sale=true');
    }
    return queryParams.isNotEmpty ? '$base?${queryParams.join('&')}' : base;
  }

  /// Product details
  static String toProduct(String cid, String productId) =>
      '/$cid/product/$productId';

  /// Product empty
  static String toProductEmpty(String cid) => '/$cid/product-empty';

  /// Cart
  static String toCart(String cid) => '/$cid/cart';

  /// Cart empty
  static String toCartEmpty(String cid) => '/$cid/cart-empty';

  /// Checkout
  static String toCheckout(String cid) => '/$cid/cart/checkout';

  /// Confirm Order
  static String toConfirmOrder(String cid) => '/$cid/cart/checkout/confirm';

  /// Global Profile
  static String toProfile({String? tabId}) => 
      tabId != null ? '/profile/$tabId' : '/profile';

  /// Order details
  static String toOrder(String cid, String orderId) =>
      '/$cid/order/$orderId';

  /// Settings
  static String toSettings(String cid) => '/$cid/settings';

  // Auth
  static String toLogin({String? redirectTo}) {
    final base = '/auth/login';
    return redirectTo != null
        ? '$base?redirect=${Uri.encodeComponent(redirectTo)}'
        : base;
  }

  static String toRegister({String? redirectTo}) {
    final base = '/auth/register';
    return redirectTo != null
        ? '$base?redirect=${Uri.encodeComponent(redirectTo)}'
        : base;
  }
  static String toForgotPassword() => '/auth/forgot-password';
  static String toResetPassword()  => '/auth/reset-password';
  static String toAuthSuccess()    => '/auth/success';

  // Static pages
  static String toAbout(String cid)   => '/$cid/about';
  static String toContact(String cid) => '/$cid/contact';
  static String toPrivacy(String cid) => '/$cid/privacy';
  static String toTerms(String cid)   => '/$cid/terms';
}
