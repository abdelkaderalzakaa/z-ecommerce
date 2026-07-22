import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../fake_data/products.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, List<CartItemModel>> _companyCarts = {};
  Map<String, String> _companyCoupons = {};

  CartProvider() {
    _loadCartFromPrefs();
  }

  List<CartItemModel> items(String companyId) => _companyCarts[companyId] ?? [];
  String? couponCode(String companyId) => _companyCoupons[companyId];

  void addToCart(String companyId, Product product, {int quantity = 1, Color? selectedColor, String? selectedSize, bool isGift = false, bool isBundle = false}) {
    final cart = List<CartItemModel>.from(items(companyId));
    final index = cart.indexWhere((item) => 
      item.product.id == product.id && 
      item.selectedColor?.value == selectedColor?.value && 
      item.selectedSize == selectedSize &&
      item.isGift == isGift &&
      item.isBundle == isBundle
    );

    if (index >= 0) {
      cart[index].quantity += quantity;
    } else {
      cart.add(
        CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: product,
          quantity: quantity,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
          isGift: isGift,
          isBundle: isBundle,
        )
      );
    }
    _companyCarts[companyId] = cart;
    _saveCartToPrefs();
    notifyListeners();
  }

  void removeFromCart(String companyId, String id) {
    if (_companyCarts.containsKey(companyId)) {
      _companyCarts[companyId]!.removeWhere((item) => item.id == id);
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  void updateQuantity(String companyId, String id, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(companyId, id);
      return;
    }
    if (_companyCarts.containsKey(companyId)) {
      final cart = _companyCarts[companyId]!;
      final index = cart.indexWhere((item) => item.id == id);
      if (index >= 0) {
        cart[index].quantity = newQuantity;
        _saveCartToPrefs();
        notifyListeners();
      }
    }
  }

  void clearCart(String companyId) {
    _companyCarts[companyId]?.clear();
    _companyCoupons.remove(companyId);
    _saveCartToPrefs();
    notifyListeners();
  }

  void applyCoupon(String companyId, String? code) {
    if (code == null || code.isEmpty) {
      _companyCoupons.remove(companyId);
    } else {
      _companyCoupons[companyId] = code;
    }
    notifyListeners();
  }

  double subTotal(String companyId) {
    return items(companyId).fold(0, (sum, item) => sum + ((item.isGift ? 0.0 : item.product.price) * item.quantity));
  }

  int cartCount(String companyId) {
    return items(companyId).fold(0, (sum, item) => sum + item.quantity);
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save carts
    final Map<String, dynamic> cartJsonMap = {};
    _companyCarts.forEach((key, value) {
      cartJsonMap[key] = value.map((e) => e.toJson()).toList();
    });
    await prefs.setString('company_carts', jsonEncode(cartJsonMap));
    
    // Save coupons
    await prefs.setString('company_coupons', jsonEncode(_companyCoupons));
  }

  Future<void> _loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load carts
    final String? cartJson = prefs.getString('company_carts');
    if (cartJson != null) {
      try {
        final Map<String, dynamic> decodedMap = jsonDecode(cartJson);
        decodedMap.forEach((companyId, list) {
          if (list is List) {
            _companyCarts[companyId] = list.map((itemMap) {
              final isGiftOrBundle = itemMap['isGift'] == true || itemMap['isBundle'] == true;
              Product? product;
              
              if (!isGiftOrBundle) {
                 product = fakeProducts.firstWhere(
                   (p) => p.id == itemMap['productId'],
                   orElse: () => fakeProducts.first,
                 );
              }
              
              return CartItemModel.fromJson(itemMap as Map<String, dynamic>, product: product);
            }).toList();
          }
        });
      } catch (e) {
        debugPrint('Error loading carts: $e');
      }
    }

    // Load coupons
    final String? couponJson = prefs.getString('company_coupons');
    if (couponJson != null) {
      try {
        final Map<String, dynamic> decodedCoupons = jsonDecode(couponJson);
        _companyCoupons = decodedCoupons.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        debugPrint('Error loading coupons: $e');
      }
    }
    
    notifyListeners();
  }
}