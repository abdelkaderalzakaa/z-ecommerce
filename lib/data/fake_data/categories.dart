import 'package:flutter/material.dart';
import '../models/category_model.dart';

final List<CategoryModel> fakeCategories = [
  const CategoryModel(
    id: 'c1',
    label: 'Shirts',
    bgColor: Color(0xFFD8E4D8),
    icon: Icons.checkroom,
  ),
  const CategoryModel(
    id: 'c2',
    label: 'Pants',
    bgColor: Color(0xFF3D4A5C),
    icon: Icons.accessibility_new,
  ),
  const CategoryModel(
    id: 'c3',
    label: 'Shoes',
    bgColor: Color(0xFFE8D4C8),
    icon: Icons.snowshoeing,
  ),
  const CategoryModel(
    id: 'c4',
    label: 'Accessories',
    bgColor: Color(0xFF5C6B7C),
    icon: Icons.watch,
  ),
];
