import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:z_ecommerce/data/models/order/cart_model.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/data/models/product/product_variant.dart';

class CartProvider with ChangeNotifier {
  // Key: businessId (storeId), Value: List of CartItemModel
  final Map<String, List<CartItemModel>> _cartItemsByStore = {};
  static const String _cartStorageKey = 'local_cart_data';

  Map<String, List<CartItemModel>> get cartItemsByStore => _cartItemsByStore;

  CartProvider() {
    _loadCartFromLocal();
  }

  // ==========================================
  // 💾 Local Persistence
  // ==========================================

  Future<void> _loadCartFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartJson = prefs.getString(_cartStorageKey);
      
      if (cartJson != null && cartJson.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(cartJson);
        
        _cartItemsByStore.clear();
        decoded.forEach((storeId, itemsList) {
          final List<dynamic> items = itemsList as List<dynamic>;
          _cartItemsByStore[storeId] = items
              .map((item) => CartItemModel.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList();
        });
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading cart from local storage: $e");
    }
  }

  Future<void> _saveCartToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final Map<String, dynamic> encoded = {};
      _cartItemsByStore.forEach((storeId, itemsList) {
        encoded[storeId] = itemsList.map((item) => item.toMap()).toList();
      });
      
      await prefs.setString(_cartStorageKey, json.encode(encoded));
    } catch (e) {
      debugPrint("Error saving cart to local storage: $e");
    }
  }

  // ==========================================
  // 🛒 Cart Operations
  // ==========================================

  List<CartItemModel> getItems(String? businessId) {
    if (businessId == null) return [];
    return _cartItemsByStore[businessId] ?? [];
  }

  List<CartItemModel> items(String? businessId) => getItems(businessId);

  int cartCount(String? businessId) {
    if (businessId == null) return 0;
    final storeItems = getItems(businessId);
    return storeItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double getSubtotal(String? businessId) {
    if (businessId == null) return 0.0;
    final storeItems = getItems(businessId);
    return storeItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double subTotal(String? businessId) {
    return getSubtotal(businessId);
  }

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
          item.productId == product.id &&
          item.selectedVariant == selectedVariant,
    );

    if (existingIndex >= 0) {
      storeList[existingIndex].quantity += quantity;
    } else {
      storeList.add(
        CartItemModel(
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
          type: CartItemType.product,
          productId: product.id,
          productName: product.name,
          productImage: product.displayImage,
          businessId: product.businessId,
          displayPrice: selectedVariant != null 
              ? product.getPriceForVariant(selectedVariant) 
              : product.basePrice,
          quantity: quantity,
          selectedVariant: selectedVariant,
        ),
      );
    }
    notifyListeners();
    _saveCartToLocal();
  }

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
          item.type == CartItemType.offer && item.offerId == offer.id,
    );

    if (existingIndex >= 0) {
      storeList[existingIndex].quantity += quantity;
    } else {
      storeList.add(
        CartItemModel(
          id: 'cart_offer_${DateTime.now().millisecondsSinceEpoch}',
          type: CartItemType.offer,
          offerId: offer.id,
          offerName: offer.name.en, // Snapshot name
          productId: product?.id,
          productName: product?.name, // Snapshot name
          productImage: product?.displayImage,
          businessId: businessId,
          displayPrice: offer.price ?? 0.0,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
    _saveCartToLocal();
  }

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
      _saveCartToLocal();
    }
  }

  void removeItem({
    required String businessId,
    required String itemId,
  }) {
    final storeList = _cartItemsByStore[businessId];
    if (storeList == null) return;

    storeList.removeWhere((item) => item.id == itemId);
    if (storeList.isEmpty) {
      _cartItemsByStore.remove(businessId);
    }
    notifyListeners();
    _saveCartToLocal();
  }

  void clearStoreCart(String businessId) {
    _cartItemsByStore.remove(businessId);
    notifyListeners();
    _saveCartToLocal();
  }

  void clearAll() {
    _cartItemsByStore.clear();
    notifyListeners();
    _saveCartToLocal();
  }

  // ==========================================
  // 🎁 Offers Engine
  // ==========================================

  /// Runs the offers engine locally to calculate gifts/discounts automatically
  /// based on the current cart contents and active offers.
  void runOffersEngine(List<OfferModel> activeOffers) {
    bool hasChanges = false;
    for (final businessId in _cartItemsByStore.keys) {
      final storeList = _cartItemsByStore[businessId]!;
      
      // 1. Remove all current auto-added gifts to re-evaluate
      final originalLength = storeList.length;
      storeList.removeWhere((item) => item.type == CartItemType.gift);
      if (storeList.length != originalLength) hasChanges = true;

      final storeOffers = activeOffers.where((o) => o.businessId == businessId && o.isActive).toList();
      
      // 2. Evaluate 'buy_x_get_y' offers
      for (final offer in storeOffers.where((o) => o.type == 'buy_x_get_y')) {
         final buyPid = offer.productId;
         if (buyPid == null) continue;
         
         // Calculate total quantity of this buyProductId in the cart
         final totalBuyQtyInCart = storeList
              .where((item) => item.productId == buyPid && item.type != CartItemType.gift)
              .fold(0, (sum, item) => sum + item.quantity);
         
         final requiredQty = offer.buyQuantity ?? 1;
         final getQty = offer.getQuantity ?? 1;
         
         if (totalBuyQtyInCart >= requiredQty) {
           final timesToApply = totalBuyQtyInCart ~/ requiredQty;
           final totalGiftQty = timesToApply * getQty;
           
           // Add gift item to cart
           storeList.add(
             CartItemModel(
               id: 'cart_gift_${DateTime.now().millisecondsSinceEpoch}_${offer.id}',
               type: CartItemType.gift,
               offerId: offer.id,
               offerName: offer.name.en, // Snapshot name
               productId: offer.giftProductId,
               productName: offer.giftName ?? 'Free Gift',
               productImage: offer.giftImageUrl,
               businessId: businessId,
               displayPrice: 0.0, // Gifts are free
               quantity: totalGiftQty,
             ),
           );
           hasChanges = true;
         }
      }
    }
    
    if (hasChanges) {
      notifyListeners();
      _saveCartToLocal();
    }
  }

  void clearCart(String? businessId) {
    if (businessId != null) {
      clearStoreCart(businessId);
    } else {
      clearAll();
    }
  }
}
