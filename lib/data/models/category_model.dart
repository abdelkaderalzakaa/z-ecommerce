import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String label;
  final Color bgColor;
  final IconData? icon;

  const CategoryModel({
    required this.id,
    required this.label,
    required this.bgColor,
    this.icon,
  });
}
