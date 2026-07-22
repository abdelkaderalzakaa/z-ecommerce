import 'package:flutter/material.dart';
import 'product_model.dart';

class CartItemModel {
  final String id;
  final Product product;
  int quantity;
  final Color? selectedColor;
  final String? selectedSize;
  final bool isGift;
  final bool isBundle;

  CartItemModel({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.selectedColor,
    this.selectedSize,
    this.isGift = false,
    this.isBundle = false,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> map, {Product? product}) {
    Product resolvedProduct = product ?? Product(
      id: map['productId'],
      name: map['productName'] ?? 'Unknown Bundle/Gift',
      price: map['productPrice']?.toDouble() ?? 0.0,
      description: '',
      category: '',
      colors: [],
      sizes: [],
      images: map['productImage'] != null ? [map['productImage']] : [],
      rating: 0,
      reviewsCount: 0,
      isNewArrival: false,
      isTopSelling: false,
      cardBgColor: Colors.white,
    );

    return CartItemModel(
      id: map['id'],
      product: resolvedProduct,
      quantity: map['quantity'],
      selectedColor: map['selectedColor'] != null ? Color(map['selectedColor']) : null,
      selectedSize: map['selectedSize'],
      isGift: map['isGift'] ?? false,
      isBundle: map['isBundle'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': product.id,
      'productName': isBundle || isGift ? product.name : null,
      'productPrice': isBundle || isGift ? product.price : null,
      'productImage': (isBundle || isGift) && product.images.isNotEmpty ? product.images.first : null,
      'quantity': quantity,
      'selectedColor': selectedColor?.value,
      'selectedSize': selectedSize,
      'isGift': isGift,
      'isBundle': isBundle,
    };
  }

  double get totalPrice => product.price * quantity;
}