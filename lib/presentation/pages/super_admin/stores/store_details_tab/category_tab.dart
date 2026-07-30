import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/company/company_settings_model.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';

class CategoryTab extends StatelessWidget {
  final CompanySettingsModel store;

  const CategoryTab({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final brandProvider = Provider.of<BrandProvider>(context);

    final storeCategories = categoryProvider.categories
        .where((c) => c.businessId == null || c.businessId == store.id)
        .toList();

    final storeBrands = brandProvider.brands
        .where((b) => b.businessId == null || b.businessId == store.id)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأقسام والعلامات التجارية للمتجر: ${store.name.get(context)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Platform Category
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.storefront_rounded,
                color: Colors.indigo,
              ),
              title: const Text('تصنيف المنصة الرئيسي للمتجر'),
              subtitle: Text(store.category.name.get(context)),
            ),
          ),
          const SizedBox(height: 24),

          // Sub Categories / Departments
          const Text(
            'أقسام وفئات المتجر الخاصة (Categories & Departments)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (storeCategories.isEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'لا توجد أقسام فرعية مضافة خصيصاً لهذا المتجر بعد',
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: storeCategories.map((cat) {
                return Chip(
                  avatar: Icon(cat.icon ?? Icons.category_rounded, size: 18),
                  label: Text(cat.label),
                  backgroundColor: cat.bgColor.withOpacity(0.15),
                  side: BorderSide(color: cat.bgColor.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 28),

          // Store Brands
          const Text(
            'العلامات التجارية المسجلة للمتجر (Store Brands)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (storeBrands.isEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text('لا توجد علامات تجارية مسجلة للمتجر حالياً'),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: storeBrands.map((brand) {
                return Chip(
                  avatar: const Icon(
                    Icons.branding_watermark_rounded,
                    size: 18,
                    color: Colors.blue,
                  ),
                  label: Text(brand.name),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
