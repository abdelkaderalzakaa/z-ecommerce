import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product/brand_model.dart';
import '../../../data/providers/brand_provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../../data/providers/product_provider.dart';

class FilterSidebar extends StatefulWidget {
  final String? categoryLabel;
  final String? brandName;

  const FilterSidebar({
    super.key,
    this.categoryLabel,
    this.brandName,
  });

  @override
  State<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends State<FilterSidebar> {


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Consumer<BrandProvider>(
            builder: (context, brandProvider, child) {
              final brands = brandProvider.brands;
              if (brands.isEmpty) return const SizedBox.shrink();
              return Column(
                children: brands.map((brand) {
                  return CheckboxListTile(
                    title: Text(brand.name),
                    value: false,
                    onChanged: (val) {},
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
