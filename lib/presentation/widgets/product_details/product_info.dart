import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/company_provider.dart';
import '../../pages/cart_page.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class ProductInfo extends StatefulWidget {
  final Product product;
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
    final colors = product.colors.isEmpty
        ? const [Color(0xFF4F4631), Color(0xFF314F4A), Color(0xFF31344F)]
        : product.colors;
    final sizes = product.sizes.isEmpty
        ? const ['Small', 'Medium', 'Large', 'X-Large']
        : product.sizes;

    final selectedColor = colors[_selectedColorIndex];
    final selectedSize = sizes[_selectedSizeIndex];

    final cartProvider = context.watch<CartProvider>();
    final companyData = context.watch<CompanyProvider>().companySettings;
    final currency = companyData?.currency ?? '\$';
    final companyId = companyData?.id ?? 'cmp_001';

    final cartItemIndex = cartProvider.items(companyId).indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedColor?.value == selectedColor.value &&
          item.selectedSize == selectedSize,
    );
    final cartItem = cartItemIndex >= 0
        ? cartProvider.items(companyId)[cartItemIndex]
        : null;
    final isInCart = cartItem != null;

    final displayQuantity = isInCart
        ? cartItem.quantity
        : (_localQuantity ?? 1);

    String buttonText = isInCart
        ? TranslationKeys.viewInCart.tr(context)
        : TranslationKeys.addToCart.tr(context);
    bool showCheckmark = isInCart;

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
              '$currency${product.price.toStringAsFixed(0)}',
              style: AppTextStyles.priceStyle(context).copyWith(
                fontSize: isMobile ? 24 : 32,
              ),
            ),
            if (product.originalPrice != null) ...[
              const SizedBox(width: 12),
              Text(
                '$currency${product.originalPrice!.toStringAsFixed(0)}',
                style: AppTextStyles.priceStrike(context).copyWith(
                  fontSize: isMobile ? 24 : 32,
                ),
              ),
            ],
            if (product.discountPercent != null) ...[
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
                  '-${product.discountPercent}%',
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
        const SizedBox(height: 20),
        Text(
          product.description,
          style: AppTextStyles.bodyText(context).copyWith(fontSize: isMobile ? 14 : 16),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Divider(color: Theme.of(context).dividerColor, height: 1),
        ),
        _ColorSelector(
          colors: colors,
          selectedIndex: _selectedColorIndex,
          onChanged: (val) => setState(() {
            _selectedColorIndex = val;
            _localQuantity = null;
          }),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Divider(color: Theme.of(context).dividerColor, height: 1),
        ),
        _SizeSelector(
          sizes: sizes,
          selectedIndex: _selectedSizeIndex,
          onChanged: (val) => setState(() {
            _selectedSizeIndex = val;
            _localQuantity = null;
          }),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Divider(color: Theme.of(context).dividerColor, height: 1),
        ),
        _ActionRow(
          quantity: displayQuantity,
          isInCart: showCheckmark,
          buttonText: buttonText,
          onQuantityChanged: (val) {
            if (isInCart) {
              cartProvider.updateQuantity(companyId, cartItem.id, val);
            } else {
              setState(() => _localQuantity = val);
            }
          },
          onPrimaryAction: () {
            if (isInCart) {
              changeScreen(context, const CartPage());
            } else {
              cartProvider.addToCart(
                companyId,
                product,
                quantity: displayQuantity,
                selectedColor: selectedColor,
                selectedSize: selectedSize,
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
            (index) => GestureDetector(
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
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
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
                child: GestureDetector(
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
                child: GestureDetector(
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
            child: GestureDetector(
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
                      Text(widget.buttonText, style: AppTextStyles.buttonText(context)),
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
