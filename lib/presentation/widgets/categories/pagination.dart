import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/product_provider.dart';

class Pagination extends StatelessWidget {
  final String? categoryLabel;
  final String? brandName;
  final bool onSale;

  const Pagination({
    super.key,
    this.categoryLabel,
    this.brandName,
    this.onSale = false,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
