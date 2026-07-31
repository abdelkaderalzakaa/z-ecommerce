import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/order/cart_model.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

import 'package:z_ecommerce/data/models/product/product_variant.dart';

class CartProvider with ChangeNotifier {
  // Key: businessId (storeId), Value: List of CartItemModel
  final Map<String, List<CartItemModel>> _cartItemsByStore = {};

  Map<String, List<CartItemModel>> get cartItemsByStore => _cartItemsByStore;

  /// Get list of items in cart for a specific store/business
  List<CartItemModel> getItems(String? businessId) {
    if (businessId == null) return [];
    return _cartItemsByStore[businessId] ?? [];
  }

  /// Alias for `getItems` to maintain compatibility with existing callers
  List<CartItemModel> items(String? businessId) => getItems(businessId);

  /// Get total item count in cart for a specific store
  int cartCount(String? businessId) {
    if (businessId == null) return 0;
    final storeItems = getItems(businessId);
    return storeItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get subtotal price for a store's cart
  double getSubtotal(String? businessId) {
    if (businessId == null) return 0.0;
    final storeItems = getItems(businessId);
    return storeItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Add a Product to cart for a specific store
  void addProductToCart({
    required String businessId,
    required ProductModel product,
    int quantity = 1,
    ProductVariant? selectedVariant,
  }) {
    if (!_cartItemsByStore.containsKey(businessId)) {
      _cartItemsByStore[businessId] = [];
    }

    final storeList = _cartItemsByStore[businessId]!;
    final existingIndex = storeList.indexWhere(
      (item) =>
          item.type == CartItemType.product &&
          item.product?.id == product.id &&
          item.selectedVariant == selectedVariant,
    );

    if (existingIndex >= 0) {
      storeList[existingIndex].quantity += quantity;
    } else {
      storeList.add(
        CartItemModel(
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
          type: CartItemType.product,
          product: product,
          quantity: quantity,
          selectedVariant: selectedVariant,
        ),
      );
    }
    notifyListeners();
  }

  /// Add an Offer (e.g. Bundle or Gift) to cart for a specific store
  void addOfferToCart({
    required String businessId,
    required OfferModel offer,
    ProductModel? product,
    int quantity = 1,
  }) {
    if (!_cartItemsByStore.containsKey(businessId)) {
      _cartItemsByStore[businessId] = [];
    }

    final storeList = _cartItemsByStore[businessId]!;
    final existingIndex = storeList.indexWhere(
      (item) =>
          item.type == CartItemType.offer && item.offer?.id == offer.id,
    );

    if (existingIndex >= 0) {
      storeList[existingIndex].quantity += quantity;
    } else {
      storeList.add(
        CartItemModel(
          id: 'cart_offer_${DateTime.now().millisecondsSinceEpoch}',
          type: CartItemType.offer,
          offer: offer,
          product: product,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  /// Update item quantity
  void updateQuantity({
    required String businessId,
    required String itemId,
    required int newQuantity,
  }) {
    final storeList = _cartItemsByStore[businessId];
    if (storeList == null) return;

    final index = storeList.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        storeList.removeAt(index);
      } else {
        storeList[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  /// Remove single item from cart
  void removeItem({
    required String businessId,
    required String itemId,
  }) {
    final storeList = _cartItemsByStore[businessId];
    if (storeList == null) return;

    storeList.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  /// Clear entire cart for a specific store
  void clearStoreCart(String businessId) {
    _cartItemsByStore.remove(businessId);
    notifyListeners();
  }

  /// Clear all carts across all stores
  void clearAll() {
    _cartItemsByStore.clear();
    notifyListeners();
  }
/// TODO 
  subTotal(String? businessId) {}

  void clearCart(String? businessId) {}
}
