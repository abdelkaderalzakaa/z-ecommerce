import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/company_provider.dart';
import '../../global/router/app_routes.dart';

class OfferCard extends StatefulWidget {
  final OfferModel offer;
  final bool fullWidth;

  const OfferCard({super.key, required this.offer, this.fullWidth = false});

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    if (widget.offer.endDate.isAfter(now)) {
      setState(() {
        _timeLeft = widget.offer.endDate.difference(now);
      });
    } else {
      setState(() {
        _timeLeft = Duration.zero;
      });
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  String _getTagText(String type) {
    switch (type) {
      case 'bundle': return 'Bundle Deal';
      case 'coupon': return 'Coupon';
      case 'clearance': return 'Clearance';
      case 'percentage_discount':
      case 'fixed_discount': return 'Discount';
      case 'free_shipping': return 'Free Shipping';
      case 'product_gift': return 'Free Gift';
      case 'buy_x_get_y': return 'BOGO';
      case 'loyalty_points': return 'Rewards';
      default: return 'Special Offer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offer = widget.offer;
    
    // Format time
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_timeLeft.inHours);
    final minutes = twoDigits(_timeLeft.inMinutes.remainder(60));
    final seconds = twoDigits(_timeLeft.inSeconds.remainder(60));

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.fullWidth ? double.infinity : 380, // Made wider to match the provided layout proportions
            margin: EdgeInsets.only(right: widget.fullWidth ? 0 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? theme.primaryColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  if (offer.imageUrl != null)
                    Image.network(
                      offer.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackBackground(theme),
                    )
                  else
                    _buildFallbackBackground(theme),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.primaryColor.withOpacity(0.4),
                          theme.primaryColor.withOpacity(0.9),
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // Content Layout
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Side (Tag, Title, Button)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Top Tag (Pill shape)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.local_offer, color: Colors.amber, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getTagText(offer.type),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Title
                              Text(
                                offer.name.get(context),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              
                              // Description
                              Text(
                                offer.description?.get(context) ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Action Button (White Pill)
                              Consumer<CartProvider>(builder: (context, cart, child) {
                                if (offer.type == 'bundle' || offer.type == 'product_gift' || offer.type == 'buy_x_get_y') {
                                  String? mainIdToCheck;
                                  if (offer.type == 'bundle') {
                                    mainIdToCheck = offer.id;
                                  } else if (offer.type == 'product_gift') {
                                    mainIdToCheck = offer.productId;
                                  } else if (offer.type == 'buy_x_get_y') {
                                    mainIdToCheck = offer.productIds?.first;
                                  }

                                  final companyId = context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001';
                                  final isInCart = mainIdToCheck != null && 
                                                   cart.items(companyId).any((item) => item.product.id == mainIdToCheck);

                                  return _buildActionBtn(
                                    text: isInCart ? 'In Cart' : 'Add to Cart',
                                    icon: isInCart ? Icons.check_circle : Icons.shopping_cart,
                                    onTap: () {
                                      if (isInCart) {
                                        final cid = context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001';
                                        context.go(AppRoutes.toCart(cid));
                                      } else {
                                        _addToCart(context);
                                      }
                                    },
                                  );
                                } else if (offer.type == 'coupon' && offer.couponCode != null) {
                                  return _buildActionBtn(
                                    text: 'Copy: ${offer.couponCode}',
                                    icon: Icons.copy,
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: offer.couponCode!));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Coupon code copied!')),
                                      );
                                    },
                                  );
                                } else {
                                  return _buildActionBtn(
                                    text: 'Shop Now',
                                    icon: Icons.visibility,
                                    onTap: () {
                                      final cid = context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001';
                                      context.go(AppRoutes.toOfferDetails(cid, offer.id));
                                    },
                                  );
                                }
                              }),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Right Side (Glassmorphism Timer)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ends in:',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildTimeSection(hours, 'Hours'),
                                      _buildTimeColon(),
                                      _buildTimeSection(minutes, 'Minutes'),
                                      _buildTimeColon(),
                                      _buildTimeSection(seconds, 'Seconds'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSection(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeColon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: theme.primaryColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBackground(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.5),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final companyId = context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001';
    final cart = context.read<CartProvider>();
    final products = context.read<ProductProvider>().allProducts;
    
    if (widget.offer.type == 'bundle') {
      final bundleProduct = Product(
        id: widget.offer.id,
        name: widget.offer.name.get(context),
        price: widget.offer.price ?? 0.0,
        description: widget.offer.description?.get(context) ?? '',
        category: 'Bundle',
        colors: [],
        sizes: [],
        images: widget.offer.imageUrl != null ? [widget.offer.imageUrl!] : [], 
        rating: 0,
        reviewsCount: 0,
        isNewArrival: false,
        isTopSelling: false,
        cardBgColor: Colors.white,
      );
      
      cart.addToCart(companyId, bundleProduct, isBundle: true);
      
    } else if (widget.offer.type == 'product_gift') {
      final mainProduct = products.firstWhere(
        (p) => p.id == widget.offer.productId,
        orElse: () => products.first,
      );
      
      Product? giftProduct;
      try {
        giftProduct = products.firstWhere((p) => p.id == widget.offer.giftProductId);
      } catch (_) {
        giftProduct = Product(
          id: widget.offer.giftProductId ?? 'gift_1',
          name: widget.offer.giftName ?? 'Free Gift',
          price: 0,
          description: '',
          category: 'Gift',
          colors: [],
          sizes: [],
          images: widget.offer.giftImageUrl != null ? [widget.offer.giftImageUrl!] : [],
          rating: 0,
          reviewsCount: 0,
          isNewArrival: false,
          isTopSelling: false,
          cardBgColor: Colors.white,
        );
      }
      
      cart.addToCart(companyId, mainProduct);
      cart.addToCart(companyId, giftProduct, isGift: true);
    } else if (widget.offer.type == 'buy_x_get_y' && widget.offer.productIds != null && widget.offer.productIds!.isNotEmpty) {
      final mainProduct = products.firstWhere(
        (p) => p.id == widget.offer.productIds!.first,
        orElse: () => products.first,
      );
      cart.addToCart(companyId, mainProduct, quantity: widget.offer.buyQuantity ?? 1);
      cart.addToCart(companyId, mainProduct, quantity: widget.offer.getQuantity ?? 1, isGift: true);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.offer.name} added to cart!')),
    );
  }
}
