import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';

class CartItemModel {
  final String id;

  final CartItemType type;

  final ProductModel? product;

  final OfferModel? offer;

  int quantity;

  final Color? selectedColor;
  final String? selectedSize;


  CartItemModel({
    required this.id,
    required this.type,
    this.product,
    this.offer,
    this.quantity = 1,
    this.selectedColor,
    this.selectedSize,
  }) : assert(
    product != null || offer != null,
    'Cart item must have product or offer'
  );


  double get unitPrice {

    if (type == CartItemType.product) {
      return product!.price;
    }

    if (type == CartItemType.offer) {

      switch(offer!.type) {

        case 'bundle':
          return offer!.price ?? 0;

        case 'percentage_discount':
          return calculateDiscountPrice();

        case 'fixed_discount':
          return (product?.price ?? 0) - (offer!.discountAmount ?? 0);

        case 'product_gift':
          return 0;

        default:
          return offer!.price ?? 0;
      }
    }

    return 0;
  }


  double calculateDiscountPrice() {

    final basePrice = product?.price ?? 0;

    final discount = offer?.discountPercent ?? 0;

    return basePrice - (basePrice * discount / 100);
  }


  double get totalPrice => unitPrice * quantity;
}

enum CartItemType {
  product,
  offer,
}