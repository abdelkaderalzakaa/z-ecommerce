import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/company_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/categories_page.dart';

class FilterSidebar extends StatefulWidget {
  final bool isMobile;
  final String? categoryLabel;
  final String? brandName;
  const FilterSidebar({super.key, this.isMobile = false, this.categoryLabel, this.brandName});

  @override
  State<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends State<FilterSidebar> {
  late double _minPrice;
  late double _maxPrice;
  late List<Color> _selectedColors;
  late List<String> _selectedSizes;
  late List<String> _selectedBrands;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProductProvider>(context, listen: false);
    _minPrice = provider.minPrice;
    _maxPrice = provider.maxPrice;
    _selectedColors = List.from(provider.selectedColors);
    _selectedSizes = List.from(provider.selectedSizes);
    _selectedBrands = List.from(provider.selectedBrands);
    
    if (widget.brandName != null && !_selectedBrands.contains(widget.brandName!)) {
      _selectedBrands.add(widget.brandName!);
    }
  }

  void _applyFilters() {
    Provider.of<ProductProvider>(context, listen: false).applyFilters(
      minP: _minPrice,
      maxP: _maxPrice,
      colors: _selectedColors,
      sizes: _selectedSizes,
      styles: [],
      brands: _selectedBrands,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: widget.isMobile
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TranslationKeys.filters.tr(context),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _minPrice = 0;
                        _maxPrice = 500;
                        _selectedColors.clear();
                        _selectedSizes.clear();
                        _selectedBrands.clear();
                      });
                      _applyFilters();
                    },
                    child: Text(TranslationKeys.clear.tr(context)),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: widget.isMobile ? () => Navigator.pop(context) : null,
                    child: Icon(
                      widget.isMobile ? Icons.close : Icons.tune,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Theme.of(context).dividerColor, height: 1),
          ),
          
          // Categories Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TranslationKeys.categories.tr(context), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Icon(Icons.expand_less, color: Theme.of(context).textTheme.bodyLarge?.color),
            ],
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final categoryProvider = Provider.of<CategoryProvider>(context);
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(categoryProvider.categories.length + 1, (index) {
                  final isAll = index == 0;
                  final cat = isAll ? null : categoryProvider.categories[index - 1];
                  final label = isAll ? TranslationKeys.allProducts.tr(context) : cat!.label;
                  final isSelected = isAll ? (widget.categoryLabel == null) : (widget.categoryLabel?.toLowerCase() == cat!.label.toLowerCase());

                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (isAll) {
                        changeScreen(context, const CategoriesPage());
                      } else {
                        changeScreen(context, const CategoriesPage());
                      }
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  );
                }),
              );
            }
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Theme.of(context).dividerColor, height: 1),
          ),

          // Sort Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TranslationKeys.sortBy.tr(context), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Icon(Icons.expand_less, color: Theme.of(context).textTheme.bodyLarge?.color),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              return DropdownButton<String>(
                isExpanded: true,
                value: provider.sortBy,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                elevation: 16,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                underline: Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
                onChanged: (String? value) {
                  if (value != null) provider.setSortBy(value);
                },
                items: [
                  DropdownMenuItem(
                    value: 'Most Popular',
                    child: Text(TranslationKeys.mostPopular.tr(context)),
                  ),
                  DropdownMenuItem(
                    value: 'Newest',
                    child: Text(TranslationKeys.newest.tr(context)),
                  ),
                  DropdownMenuItem(
                    value: 'Price: Low to High',
                    child: Text(TranslationKeys.priceLowToHigh.tr(context)),
                  ),
                  DropdownMenuItem(
                    value: 'Price: High to Low',
                    child: Text(TranslationKeys.priceHighToLow.tr(context)),
                  ),
                ],
              );
            },
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Theme.of(context).dividerColor, height: 1),
          ),
          
          // Price Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TranslationKeys.price.tr(context), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Icon(Icons.expand_less, color: Theme.of(context).textTheme.bodyLarge?.color),
            ],
          ),
          const SizedBox(height: 16),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 500,
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Theme.of(context).cardColor,
            onChanged: (values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
            onChangeEnd: (values) {
              _applyFilters();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Consumer<CompanyProvider>(
                builder: (context, companyProvider, child) {
                  final currency = companyProvider.companySettings?.currency ?? '\$';
                  return Text('$currency${_minPrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.w500));
                },
              ),
              Consumer<CompanyProvider>(
                builder: (context, companyProvider, child) {
                  final currency = companyProvider.companySettings?.currency ?? '\$';
                  return Text('$currency${_maxPrice.toInt()}', style: TextStyle(fontWeight: FontWeight.w500));
                },
              ),
            ],
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Theme.of(context).dividerColor, height: 1),
          ),

          // Colors Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TranslationKeys.colors.tr(context), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Icon(Icons.expand_less, color: Theme.of(context).textTheme.bodyLarge?.color),
            ],
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final colors = Provider.of<ProductProvider>(context).getAvailableColors(widget.categoryLabel);
              if (colors.isEmpty) return Text(TranslationKeys.noColorsAvailable.tr(context), style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(colors.length, (index) {
                  final color = colors[index];
                  final isSelected = _selectedColors.contains(color);
                  final isWhite = color == const Color(0xFFFFFFFF);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedColors.remove(color);
                        } else {
                          _selectedColors.add(color);
                        }
                      });
                      _applyFilters();
                    },
                    child: Container(
                      width: 37,
                      height: 37,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isWhite ? Border.all(color: Theme.of(context).dividerColor) : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: isWhite ? Colors.black : Colors.white, size: 16)
                          : null,
                    ),
                  );
                }),
              );
            }
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Theme.of(context).dividerColor, height: 1),
          ),

          // Size Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TranslationKeys.size.tr(context), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Icon(Icons.expand_less, color: Theme.of(context).textTheme.bodyLarge?.color),
            ],
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final sizes = Provider.of<ProductProvider>(context).getAvailableSizes(widget.categoryLabel);
              if (sizes.isEmpty) return Text(TranslationKeys.noSizesAvailable.tr(context), style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sizes.map((size) {
                  final isSelected = _selectedSizes.contains(size);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSizes.remove(size);
                        } else {
                          _selectedSizes.add(size);
                        }
                      });
                      _applyFilters();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Theme.of(context).dividerColor, height: 1),
          ),

          // Brand Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Brands', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Icon(Icons.expand_less, color: Theme.of(context).textTheme.bodyLarge?.color),
            ],
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final companyBrands = Provider.of<CompanyProvider>(context).companySettings?.brands ?? [];
              if (companyBrands.isEmpty) return Text('No brands available', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
              return Column(
                children: companyBrands.map((brand) {
                  final isSelected = _selectedBrands.contains(brand.name);
                  return CheckboxListTile(
                    title: Text(brand.name, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                    value: isSelected,
                    activeColor: Theme.of(context).primaryColor,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedBrands.add(brand.name);
                        } else {
                          _selectedBrands.remove(brand.name);
                        }
                      });
                      _applyFilters();
                    },
                  );
                }).toList(),
              );
            }
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
