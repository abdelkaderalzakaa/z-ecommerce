import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final List<String> businessIds; // قائمة معرفات المتاجر التي فعلت الفئة
  final String label;
  final Color bgColor;
  final IconData? icon;
  final bool isGlobal; // هل الفئة عامة ومضافة من الإدارة؟
  String? get businessId => businessIds.isNotEmpty ? businessIds.first : null;

  const CategoryModel({
    required this.id,
    this.businessIds = const [],
    required this.label,
    required this.bgColor,
    this.icon,
    this.isGlobal = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessIds': businessIds,
      'label': label,
      'bgColor': bgColor.value,
      'iconCodePoint': icon?.codePoint,
      'isGlobal': isGlobal,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      businessIds: List<String>.from(json['businessIds'] ?? []),
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
      isGlobal: json['isGlobal'] ?? false,
    );
  }

  CategoryModel copyWith({
    String? id,
    List<String>? businessIds,
    String? label,
    Color? bgColor,
    IconData? icon,
    bool? isGlobal,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      businessIds: businessIds ?? this.businessIds,
      label: label ?? this.label,
      bgColor: bgColor ?? this.bgColor,
      icon: icon ?? this.icon,
      isGlobal: isGlobal ?? this.isGlobal,
    );
  }

  /// إنشاء كائن CategoryModel فارغ بقيم افتراضية
  factory CategoryModel.empty() {
    return const CategoryModel(
      id: '',
      label: '',
      bgColor: Color(0xFFF3F4F6),
    );
  }
}
