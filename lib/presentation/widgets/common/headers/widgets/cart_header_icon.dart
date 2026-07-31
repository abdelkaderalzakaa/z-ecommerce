import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/widgets/buttons.dart';
import '../../../../../../data/providers/cart_provider.dart';
import '../../../../../data/providers/business_provider.dart';
import '../../../../global/translate/app_localizations.dart';
import '../../../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/cart/cart_page.dart';

class CartHeaderIcon extends StatefulWidget {
  final bool isActive;

  const CartHeaderIcon({super.key, this.isActive = true});

  @override
  State<CartHeaderIcon> createState() => _CartHeaderIconState();
}

class _CartHeaderIconState extends State<CartHeaderIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessId =
        context.read<BusinessProvider>().selectedBusiness?.id;
    final cartCount = context.watch<CartProvider>().cartCount(businessId);

    if (!_isFirstBuild && cartCount > _previousCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.forward(from: 0.0);
        }
      });
    }

    _isFirstBuild = false;
    _previousCount = cartCount;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButtonHeader(
        icon: Icons.shopping_cart_outlined,
        label: cartCount > 0
            ? '$cartCount ${TranslationKeys.items.tr(context)}'
            : "",
        onTap: !widget.isActive
            ? null
            : cartCount > 0
            ? () {
                changeScreen(context, const CartPage());
              }
            : null,
      ),
    );
  }
}
