import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final String description;
  final String category;
  final String? brand;
  final List<Color> colors;
  final List<String> sizes;
  final List<String> images;
  final double rating;
  final int reviewsCount;
  final bool isNewArrival;
  final bool isTopSelling;
  final Color cardBgColor;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.description,
    required this.category,
    this.brand,
    this.colors = const [],
    this.sizes = const [],
    this.images = const [],
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.isNewArrival = false,
    this.isTopSelling = false,
    this.cardBgColor = const Color(0xFFFFFFFF),
  });
}
