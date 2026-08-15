import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../../data/models/product/product_model.dart';
import '../../../data/models/product/product_variant.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../pages/customer/cart/cart_page.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/global/core/constants/product_enums.dart';

class ProductInfo extends StatefulWidget {
  final ProductModel product;
  const ProductInfo({super.key, required this.product});

  @override
  State<ProductInfo> createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  int _selectedVariantIndex = 0;
  int? _localQuantity;

  void _selectAttribute({
    ProductSize? size,
    ProductColor? color,
    ProductMaterial? material,
    ProductType? type,
    double? weight,
    WeightUnit? weightUnit,
    bool changeWeight = false,
    String? name,
  }) {
    final product = widget.product;
    final current = product.variants.isNotEmpty
        ? product.variants[_selectedVariantIndex.clamp(0, product.variants.length - 1)]
        : product.defaultVariant;

    final targetSize = size ?? current.size;
    final targetColor = color ?? current.color;
    final targetMaterial = material ?? current.material;
    final targetType = type ?? current.type;
    final targetWeight = changeWeight ? weight : current.weight;
    final targetWeightUnit = changeWeight ? weightUnit : current.weightUnit;
    final targetName = name ?? current.name;

    int bestIndex = _selectedVariantIndex;
    int maxScore = -1;

    for (int i = 0; i < product.variants.length; i++) {
      final v = product.variants[i];
      int score = 0;

      // Check if it matches the changed attribute (the one passed as parameter)
      if (size != null && v.size != size) continue;
      if (color != null && v.color != color) continue;
      if (material != null && v.material != material) continue;
      if (type != null && v.type != type) continue;
      if (changeWeight && (v.weight != weight || v.weightUnit != weightUnit)) continue;
      if (name != null && v.name != name) continue;

      // Scoring how well it matches other current/target attributes
      if (v.size == targetSize) score++;
      if (v.color == targetColor) score++;
      if (v.material == targetMaterial) score++;
      if (v.type == targetType) score++;
      if (v.weight == targetWeight && v.weightUnit == targetWeightUnit) score++;
      if (v.name == targetName) score++;

      if (score > maxScore) {
        maxScore = score;
        bestIndex = i;
      }
    }

    setState(() {
      _selectedVariantIndex = bestIndex;
      _localQuantity = null;
    });
  }

  List<Widget> _buildVariantSelectors(
    BuildContext context,
    ProductModel product,
    ProductVariant selectedVariant,
  ) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final List<Widget> selectors = [];

    final sizes = product.variants.map((v) => v.size).whereType<ProductSize>().toSet().toList();
    final colors = product.variants.map((v) => v.color).whereType<ProductColor>().toSet().toList();
    final materials = product.variants.map((v) => v.material).whereType<ProductMaterial>().toSet().toList();
    final types = product.variants.map((v) => v.type).whereType<ProductType>().toSet().toList();
    
    final weights = product.variants
        .where((v) => v.weight != null)
        .map((v) => MapEntry(v.weight!, v.weightUnit))
        .toSet()
        .toList();

    final names = product.variants
        .map((v) => v.name)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    // Size Selector
    if (sizes.isNotEmpty) {
      selectors.add(_buildSelectorSection(
        title: isAr ? 'المقاس:' : 'Size:',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sizes.map((size) {
            final isSelected = selectedVariant.size == size;
            return ChoiceChip(
              label: Text(size.displayName),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              onSelected: (selected) {
                if (selected) {
                  _selectAttribute(size: size);
                }
              },
            );
          }).toList(),
        ),
      ));
    }

    // Color Selector
    if (colors.isNotEmpty) {
      selectors.add(_buildSelectorSection(
        title: isAr ? 'اللون:' : 'Color:',
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            final isSelected = selectedVariant.color == color;
            final flutterColor = color.flutterColor;
            return InkWell(
              onTap: () => _selectAttribute(color: color),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: flutterColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.4),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: flutterColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                        size: 18,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ));
    }

    // Material Selector
    if (materials.isNotEmpty) {
      selectors.add(_buildSelectorSection(
        title: isAr ? 'المادة:' : 'Material:',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: materials.map((material) {
            final isSelected = selectedVariant.material == material;
            return ChoiceChip(
              label: Text(material.displayName(context)),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              onSelected: (selected) {
                if (selected) {
                  _selectAttribute(material: material);
                }
              },
            );
          }).toList(),
        ),
      ));
    }

    // Type Selector
    if (types.isNotEmpty) {
      selectors.add(_buildSelectorSection(
        title: isAr ? 'النوع:' : 'Type:',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) {
            final isSelected = selectedVariant.type == type;
            return ChoiceChip(
              label: Text(type.displayName(context)),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              onSelected: (selected) {
                if (selected) {
                  _selectAttribute(type: type);
                }
              },
            );
          }).toList(),
        ),
      ));
    }

    // Weight Selector
    if (weights.isNotEmpty) {
      selectors.add(_buildSelectorSection(
        title: isAr ? 'الوزن:' : 'Weight:',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: weights.map((entry) {
            final weight = entry.key;
            final unit = entry.value;
            final isSelected = selectedVariant.weight == weight && selectedVariant.weightUnit == unit;
            final labelText = '${weight.toStringAsFixed(weight == weight.toInt() ? 0 : 1)} ${unit?.displayName(context) ?? ''}';
            return ChoiceChip(
              label: Text(labelText.trim()),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              onSelected: (selected) {
                if (selected) {
                  _selectAttribute(weight: weight, weightUnit: unit, changeWeight: true);
                }
              },
            );
          }).toList(),
        ),
      ));
    }

    // Custom Names / Other Options
    if (names.isNotEmpty) {
      selectors.add(_buildSelectorSection(
        title: isAr ? 'الخيارات المتاحة:' : 'Available Options:',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: names.map((name) {
            final isSelected = selectedVariant.name == name;
            return ChoiceChip(
              label: Text(name),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              onSelected: (selected) {
                if (selected) {
                  _selectAttribute(name: name);
                }
              },
            );
          }).toList(),
        ),
      ));
    }

    return selectors;
  }

  Widget _buildSelectorSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final product = widget.product;
    final cartProvider = context.watch<CartProvider>();
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final currency = selectedBusiness?.currency.symbol ?? '\$';
    final businessId = selectedBusiness?.id;

    final hasVariants = product.variants.isNotEmpty && product.variants.length > 1;
    final selectedVariant = product.variants.isNotEmpty
        ? product.variants[_selectedVariantIndex.clamp(0, product.variants.length - 1)]
        : product.defaultVariant;

    final cartItemIndex = cartProvider
        .items(businessId)
        .indexWhere((item) => item.product?.id == product.id && item.selectedVariant == selectedVariant);
    final cartItem = cartItemIndex >= 0
        ? cartProvider.items(businessId)[cartItemIndex]
        : null;
    final isInCart = cartItem != null;

    final displayQuantity = isInCart
        ? cartItem.quantity
        : (_localQuantity ?? 1);

    String buttonText = isInCart
        ? TranslationKeys.viewInCart.tr(context)
        : TranslationKeys.addToCart.tr(context);
    bool showCheckmark = isInCart;

    final double activePrice = product.getPriceForVariant(selectedVariant);
    final double activeOriginalPrice = selectedVariant.originalPrice ?? selectedVariant.price;
    final bool hasDisc = product.hasDiscount || (selectedVariant.originalPrice != null && selectedVariant.originalPrice! > selectedVariant.price);
    final int? activeDiscountPercent = product.discountPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: AppTextStyles.heroTitle(context, isMobile).copyWith(
            fontSize: isMobile ? 24 : 40,
            letterSpacing: 0,
            height: 1.2,
          ),
        ),
        Row(
          children: [
            Text(
              '$currency${activePrice.toStringAsFixed(2)}',
              style: AppTextStyles.priceStyle(
                context,
              ).copyWith(fontSize: isMobile ? 24 : 32),
            ),
            if (hasDisc) ...[
              const SizedBox(width: 12),
              Text(
                '$currency${activeOriginalPrice.toStringAsFixed(2)}',
                style: AppTextStyles.priceStrike(
                  context,
                ).copyWith(fontSize: isMobile ? 24 : 32),
              ),
            ],
            if (hasDisc && activeDiscountPercent != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.discountBadge,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Text(
                  '-$activeDiscountPercent%',
                  style: const TextStyle(
                    color: AppColors.discountText,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Stock quantity display
        Row(
          children: [
            Icon(
              selectedVariant.stock > 0 ? Icons.check_circle_outline : Icons.remove_circle_outline,
              color: selectedVariant.stock > 0 ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              selectedVariant.stock > 0 ? 'الكمية المتوفرة: ${selectedVariant.stock}' : 'غير متوفر في المخزون',
              style: TextStyle(
                color: selectedVariant.stock > 0 ? Colors.green : Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          product.description,
          style: AppTextStyles.bodyText(
            context,
          ).copyWith(fontSize: isMobile ? 14 : 16),
        ),
        if (hasVariants) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Theme.of(context).dividerColor, height: 1),
          ),
          ..._buildVariantSelectors(context, product, selectedVariant),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Divider(color: Theme.of(context).dividerColor, height: 1),
        ),
        _ActionRow(
          quantity: displayQuantity,
          isInCart: showCheckmark,
          buttonText: buttonText,
          onQuantityChanged: (val) {
            if (isInCart && businessId != null) {
              cartProvider.updateQuantity(
                businessId: businessId,
                itemId: cartItem.id,
                newQuantity: val,
              );
            } else if (!isInCart) {
              setState(() => _localQuantity = val);
            }
          },
          onPrimaryAction: () {
            if (isInCart) {
              changeScreen(context, const CartPage());
            } else if (businessId != null) {
              cartProvider.addProductToCart(
                businessId: businessId,
                product: product,
                quantity: displayQuantity,
                selectedVariant: selectedVariant,
              );
              setState(() => _localQuantity = null);
            }
          },
        ),
      ],
    );
  }
}

Color _getFlutterColor(ProductColor color) {
  switch (color) {
    case ProductColor.red:
      return Colors.red;
    case ProductColor.blue:
      return Colors.blue;
    case ProductColor.black:
      return Colors.black;
    case ProductColor.white:
      return Colors.white;
    case ProductColor.green:
      return Colors.green;
    case ProductColor.yellow:
      return Colors.yellow;
  }
}

extension ProductColorExt on ProductColor {
  Color get flutterColor => _getFlutterColor(this);
}

extension ProductSizeExt on ProductSize {
  String get displayName {
    switch (this) {
      case ProductSize.small: return 'S';
      case ProductSize.medium: return 'M';
      case ProductSize.large: return 'L';
      case ProductSize.xlarge: return 'XL';
      case ProductSize.xxlarge: return 'XXL';
    }
  }
}

extension ProductMaterialExt on ProductMaterial {
  String displayName(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (this) {
      case ProductMaterial.cotton: return isAr ? 'قطن' : 'Cotton';
      case ProductMaterial.leather: return isAr ? 'جلد' : 'Leather';
      case ProductMaterial.silk: return isAr ? 'حرير' : 'Silk';
      case ProductMaterial.wool: return isAr ? 'صوف' : 'Wool';
      case ProductMaterial.polyester: return isAr ? 'بوليستر' : 'Polyester';
      case ProductMaterial.wood: return isAr ? 'خشب' : 'Wood';
      case ProductMaterial.metal: return isAr ? 'معدن' : 'Metal';
      case ProductMaterial.plastic: return isAr ? 'بلاستيك' : 'Plastic';
    }
  }
}

extension ProductTypeExt on ProductType {
  String displayName(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (this) {
      case ProductType.casual: return isAr ? 'كاجوال' : 'Casual';
      case ProductType.formal: return isAr ? 'رسمي' : 'Formal';
      case ProductType.sport: return isAr ? 'رياضي' : 'Sport';
      case ProductType.classic: return isAr ? 'كلاسيك' : 'Classic';
    }
  }
}

extension WeightUnitExt on WeightUnit {
  String displayName(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (this) {
      case WeightUnit.gram: return isAr ? 'جرام' : 'g';
      case WeightUnit.kilogram: return isAr ? 'كيلوجرام' : 'kg';
      case WeightUnit.pound: return isAr ? 'رطل' : 'lb';
    }
  }
}

class _ActionRow extends StatefulWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onPrimaryAction;
  final bool isInCart;
  final String buttonText;

  const _ActionRow({
    required this.quantity,
    required this.onQuantityChanged,
    required this.onPrimaryAction,
    required this.buttonText,
    this.isInCart = false,
  });

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () {
                    if (widget.quantity > 1) {
                      widget.onQuantityChanged(widget.quantity - 1);
                    }
                  },
                  child: Icon(Icons.remove, size: 20),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                '${widget.quantity}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 24),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () => widget.onQuantityChanged(widget.quantity + 1),
                  child: const Icon(Icons.add, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: widget.onPrimaryAction,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: widget.isInCart
                      ? (_hovered
                            ? const Color(0xFF222222)
                            : const Color(0xFF333333))
                      : (_hovered
                            ? const Color(0xFF333333)
                            : Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  boxShadow: _hovered
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isInCart) ...[
                        const Icon(Icons.check, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.buttonText,
                        style: AppTextStyles.buttonText(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
