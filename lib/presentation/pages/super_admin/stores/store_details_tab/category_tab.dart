import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/company_settings_model.dart';

class CategoryTab extends StatelessWidget {
  final CompanySettingsModel store;

  const CategoryTab({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brands = store.brands;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الأقسام والعلامات التجارية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: ListTile(
              leading: const Icon(Icons.category_rounded, color: Colors.blue),
              title: const Text('القسم الرئيسي'),
              subtitle: Text(store.category.name.get(context)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'العلامات التجارية التابعة (Brands)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (brands.isEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('لا توجد علامات تجارية مسجلة للمتجر حالياً'),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: brands.map((brand) {
                return Chip(
                  avatar: const Icon(Icons.branding_watermark_rounded, size: 18),
                  label: Text(brand.name),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}