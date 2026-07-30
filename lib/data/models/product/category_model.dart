import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String? businessId;
  final String label;
  final Color bgColor;
  final IconData? icon;

  const CategoryModel({
    required this.id,
    this.businessId,
    required this.label,
    required this.bgColor,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'label': label,
      'bgColor': bgColor.value,
      'iconCodePoint': icon?.codePoint,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      businessId: json['businessId'],
      label: json['label'] ?? '',
      bgColor: json['bgColor'] != null
          ? Color(
              json['bgColor'] is int
                  ? json['bgColor']
                  : int.parse(json['bgColor'].toString()),
            )
          : const Color(0xFFF3F4F6),
      icon: json['iconCodePoint'] != null
          ? IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons')
          : null,
    );
  }
}
