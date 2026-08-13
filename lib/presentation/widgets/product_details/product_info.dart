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
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  int? _localQuantity;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final product = widget.product;
    final cartProvider = context.watch<CartProvider>();
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final currency = selectedBusiness?.currency.symbol ?? '\$';
    final businessId = selectedBusiness?.id;

    final cartItemIndex = cartProvider
        .items(businessId)
        .indexWhere((item) => item.product?.id == product.id);
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

    final sizes = product.variants
        .map((v) => v.size?.name)
        .where((s) => s != null && s.isNotEmpty)
        .map((s) => s!)
        .toSet()
        .toList();

    final activeSizeName = sizes.isNotEmpty ? sizes[_selectedSizeIndex.clamp(0, sizes.length - 1)] : null;

    final variantsForSize = product.variants.where((v) {
      if (activeSizeName == null) return true;
      return v.size?.name == activeSizeName;
    }).toList();

    final colors = variantsForSize
        .map((v) {
          switch (v.color) {
            case ProductColor.red: return Colors.red;
            case ProductColor.blue: return Colors.blue;
            case ProductColor.black: return Colors.black;
            case ProductColor.white: return Colors.white;
            case ProductColor.green: return Colors.green;
            case ProductColor.yellow: return Colors.yellow;
            default: return null;
          }
        })
        .whereType<Color>()
        .toSet()
        .toList();

    final activeColorIndex = colors.isNotEmpty ? _selectedColorIndex.clamp(0, colors.length - 1) : 0;
    final selectedColor = colors.isNotEmpty ? colors[activeColorIndex] : null;

    ProductColor? getEnumFromColor(Color? c) {
      if (c == null) return null;
      if (c == Colors.red) return ProductColor.red;
      if (c == Colors.blue) return ProductColor.blue;
      if (c == Colors.black) return ProductColor.black;
      if (c == Colors.white) return ProductColor.white;
      if (c == Colors.green) return ProductColor.green;
      if (c == Colors.yellow) return ProductColor.yellow;
      return null;
    }
    
    final matchingColorEnum = getEnumFromColor(selectedColor);
    
    ProductVariant selectedVariant = product.defaultVariant;
    try {
      selectedVariant = product.variants.firstWhere((v) {
        final matchesColor = matchingColorEnum == null || v.color == matchingColorEnum;
        final matchesSize = activeSizeName == null || v.size?.name == activeSizeName;
        return matchesColor && matchesSize;
      });
    } catch (_) {
      selectedVariant = product.defaultVariant;
    }

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
        if (colors.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Theme.of(context).dividerColor, height: 1),
          ),
          _ColorSelector(
            colors: colors,
            selectedIndex: activeColorIndex,
            onChanged: (val) => setState(() {
              _selectedColorIndex = val;
              _localQuantity = null;
            }),
          ),
        ],
        if (sizes.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Theme.of(context).dividerColor, height: 1),
          ),
          _SizeSelector(
            sizes: sizes,
            selectedIndex: _selectedSizeIndex.clamp(0, sizes.length - 1),
            onChanged: (val) => setState(() {
              _selectedSizeIndex = val;
              _selectedColorIndex = 0; // Reset color index when size changes to avoid out-of-bounds
              _localQuantity = null;
            }),
          ),
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
              );
              setState(() => _localQuantity = null);
            }
          },
        ),
      ],
    );
  }
}

class _ColorSelector extends StatelessWidget {
  final List<Color> colors;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _ColorSelector({
    required this.colors,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.selectColors.tr(context),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            colors.length,
            (index) => InkWell(
              onTap: () => onChanged(index),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 37,
                  height: 37,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                  ),
                  child: selectedIndex == index
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SizeSelector extends StatelessWidget {
  final List<String> sizes;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SizeSelector({
    required this.sizes,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.chooseSize.tr(context),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(sizes.length, (index) {
            final isSelected = selectedIndex == index;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: Text(
                    sizes[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
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
