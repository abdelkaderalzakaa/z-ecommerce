import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product/brand_model.dart';
import '../../../data/models/product/category_model.dart';
import '../../../data/models/product/product_model.dart';
import '../../../data/providers/brand_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/providers/product_filter_provider.dart';
import '../../../data/providers/product_provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/constants/product_enums.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class FilterSidebar extends StatelessWidget {
  final String? categoryLabel;
  final String? brandName;
  final VoidCallback? onApply; // for mobile drawer/modal

  const FilterSidebar({
    super.key,
    this.categoryLabel,
    this.brandName,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filterProvider = context.watch<ProductFilterProvider>();
    final productProvider = context.watch<ProductProvider>();
    final brandProvider = context.watch<BrandProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final allProducts = productProvider.allProducts;
    final activeCount = filterProvider.activeFiltersCount;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Clear Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: theme.primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    TranslationKeys.filters.tr(context),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (activeCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$activeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (filterProvider.hasActiveFilters)
                TextButton.icon(
                  onPressed: () => filterProvider.clearAllFilters(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    TranslationKeys.clearFilters.tr(context),
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 1. Quick Filters & Highlights
          _SectionTitle(
            title: TranslationKeys.quickFilters.tr(context),
            icon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: 10),
          _QuickFiltersSection(filterProvider: filterProvider),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 2. Brands List
          _BrandsSection(
            brands: brandProvider.brands,
            allProducts: allProducts,
            filterProvider: filterProvider,
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 3. Categories List
          _CategoriesSection(
            categories: categoryProvider.categories,
            allProducts: allProducts,
            filterProvider: filterProvider,
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 4. Product Details (Sizes, Colors, Material, Type)
          _SectionTitle(
            title: TranslationKeys.productDetailsFilter.tr(context),
            icon: Icons.dashboard_customize_outlined,
          ),
          const SizedBox(height: 12),
          _ProductAttributesSection(
            filterProvider: filterProvider,
          ),

          if (onApply != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.check, color: Colors.white),
                label: Text(
                  TranslationKeys.applyFilters.tr(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _QuickFiltersSection extends StatelessWidget {
  final ProductFilterProvider filterProvider;

  const _QuickFiltersSection({required this.filterProvider});

  @override
  Widget build(BuildContext context) {
    final current = filterProvider.quickFilter;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QuickFilterChip(
          label: TranslationKeys.recommended.tr(context),
          icon: Icons.star_rounded,
          isSelected: current == QuickFilter.recommended,
          onTap: () => filterProvider.setQuickFilter(QuickFilter.recommended),
        ),
        _QuickFilterChip(
          label: TranslationKeys.bestSellers.tr(context),
          icon: Icons.local_fire_department_rounded,
          isSelected: current == QuickFilter.bestSellers,
          onTap: () => filterProvider.setQuickFilter(QuickFilter.bestSellers),
        ),
        _QuickFilterChip(
          label: TranslationKeys.newArrivals.tr(context),
          icon: Icons.fiber_new_rounded,
          isSelected: current == QuickFilter.newArrivals,
          onTap: () => filterProvider.setQuickFilter(QuickFilter.newArrivals),
        ),
        _QuickFilterChip(
          label: TranslationKeys.mostLiked.tr(context),
          icon: Icons.favorite_rounded,
          isSelected: current == QuickFilter.mostLiked,
          onTap: () => filterProvider.setQuickFilter(QuickFilter.mostLiked),
        ),
        _QuickFilterChip(
          label: TranslationKeys.onSale.tr(context),
          icon: Icons.local_offer_rounded,
          isSelected: current == QuickFilter.onSale,
          onTap: () => filterProvider.setQuickFilter(QuickFilter.onSale),
        ),
      ],
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor
              : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandsSection extends StatelessWidget {
  final List<BrandModel> brands;
  final List<ProductModel> allProducts;
  final ProductFilterProvider filterProvider;

  const _BrandsSection({
    required this.brands,
    required this.allProducts,
    required this.filterProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (brands.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: TranslationKeys.brands.tr(context),
          icon: Icons.branding_watermark_outlined,
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              final isSelected = filterProvider.selectedBrandIds.contains(brand.id) ||
                  filterProvider.selectedBrandIds.contains(brand.name);
              final count = allProducts
                  .where((p) => p.brandId == brand.id || p.brand == brand.name)
                  .length;

              return InkWell(
                onTap: () => filterProvider.toggleBrand(brand.id.isNotEmpty ? brand.id : brand.name),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (val) => filterProvider.toggleBrand(
                            brand.id.isNotEmpty ? brand.id : brand.name,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          activeColor: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (brand.logoUrl != null && brand.logoUrl!.isNotEmpty) ...[
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          backgroundImage: NetworkImage(brand.logoUrl!),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          brand.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? theme.primaryColor
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final List<CategoryModel> categories;
  final List<ProductModel> allProducts;
  final ProductFilterProvider filterProvider;

  const _CategoriesSection({
    required this.categories,
    required this.allProducts,
    required this.filterProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: TranslationKeys.categories.tr(context),
          icon: Icons.category_outlined,
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = filterProvider.selectedCategoryIds.contains(cat.id) ||
                  filterProvider.selectedCategoryIds.contains(cat.label);
              final count = allProducts
                  .where((p) => p.categoryId == cat.id || p.category == cat.label)
                  .length;

              return InkWell(
                onTap: () => filterProvider.toggleCategory(cat.id.isNotEmpty ? cat.id : cat.label),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (val) => filterProvider.toggleCategory(
                            cat.id.isNotEmpty ? cat.id : cat.label,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          activeColor: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: cat.bgColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? theme.primaryColor
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductAttributesSection extends StatelessWidget {
  final ProductFilterProvider filterProvider;

  const _ProductAttributesSection({required this.filterProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Sizes (المقاسات)
        Text(
          TranslationKeys.size.tr(context),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProductSize.values.map((size) {
            final isSelected = filterProvider.selectedSizes.contains(size);
            final label = size.name.toUpperCase();

            return InkWell(
              onTap: () => filterProvider.toggleSize(size),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryColor
                      : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? theme.primaryColor
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // 2. Colors (الألوان)
        Text(
          TranslationKeys.colors.tr(context),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ProductColor.values.map((pColor) {
            final isSelected = filterProvider.selectedColors.contains(pColor);
            final colorValue = _getDisplayColor(pColor);

            return Tooltip(
              message: pColor.name,
              child: InkWell(
                onTap: () => filterProvider.toggleColor(pColor),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorValue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : Colors.grey.withValues(alpha: 0.4),
                      width: isSelected ? 3 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: (pColor == ProductColor.white || pColor == ProductColor.yellow)
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // 3. Materials (المادة)
        Text(
          TranslationKeys.material.tr(context),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProductMaterial.values.map((mat) {
            final isSelected = filterProvider.selectedMaterials.contains(mat);
            final label = _getMaterialLabel(context, mat);

            return FilterChip(
              label: Text(label, style: const TextStyle(fontSize: 11)),
              selected: isSelected,
              onSelected: (_) => filterProvider.toggleMaterial(mat),
              selectedColor: theme.primaryColor.withValues(alpha: 0.15),
              checkmarkColor: theme.primaryColor,
              backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? theme.primaryColor
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // 4. Type (النوع)
        Text(
          TranslationKeys.type.tr(context),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProductType.values.map((type) {
            final isSelected = filterProvider.selectedTypes.contains(type);
            final label = _getTypeLabel(context, type);

            return FilterChip(
              label: Text(label, style: const TextStyle(fontSize: 11)),
              selected: isSelected,
              onSelected: (_) => filterProvider.toggleType(type),
              selectedColor: theme.primaryColor.withValues(alpha: 0.15),
              checkmarkColor: theme.primaryColor,
              backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? theme.primaryColor
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getDisplayColor(ProductColor color) {
    switch (color) {
      case ProductColor.red:
        return Colors.red.shade600;
      case ProductColor.blue:
        return Colors.blue.shade600;
      case ProductColor.black:
        return Colors.black;
      case ProductColor.white:
        return Colors.white;
      case ProductColor.green:
        return Colors.green.shade600;
      case ProductColor.yellow:
        return Colors.amber.shade500;
    }
  }

  String _getMaterialLabel(BuildContext context, ProductMaterial mat) {
    switch (mat) {
      case ProductMaterial.cotton:
        return TranslationKeys.cotton.tr(context);
      case ProductMaterial.leather:
        return TranslationKeys.leather.tr(context);
      case ProductMaterial.silk:
        return TranslationKeys.silk.tr(context);
      case ProductMaterial.wool:
        return TranslationKeys.wool.tr(context);
      case ProductMaterial.polyester:
        return TranslationKeys.polyester.tr(context);
      case ProductMaterial.wood:
        return TranslationKeys.wood.tr(context);
      case ProductMaterial.metal:
        return TranslationKeys.metal.tr(context);
      case ProductMaterial.plastic:
        return TranslationKeys.plastic.tr(context);
    }
  }

  String _getTypeLabel(BuildContext context, ProductType type) {
    switch (type) {
      case ProductType.casual:
        return TranslationKeys.casual.tr(context);
      case ProductType.formal:
        return TranslationKeys.formal.tr(context);
      case ProductType.sport:
        return TranslationKeys.sport.tr(context);
      case ProductType.classic:
        return TranslationKeys.classic.tr(context);
    }
  }
}
