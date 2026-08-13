import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/data/providers/cart_provider.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

class ProductOffersSection extends StatelessWidget {
  final ProductModel product;

  const ProductOffersSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    
    // Filter active/valid offers
    final activeOffers = product.offers.where((o) => o.isActive).toList();

    if (activeOffers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'العروض والخصومات المتاحة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeOffers.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: isWide ? 110 : 160,
                ),
                itemBuilder: (context, index) {
                  final offer = activeOffers[index];
                  return Card(
                    elevation: 0,
                    color: theme.primaryColor.withOpacity(0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.primaryColor.withOpacity(0.15), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_offer_rounded,
                              color: theme.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  offer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  offer.description ?? 'احصل على هذا العرض المميز عند الشراء الآن!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (offer.couponCode != null && offer.couponCode!.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                                  ),
                                  child: SelectableText(
                                    offer.couponCode!,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  final generalOffer = OfferModel(
                                    id: offer.id,
                                    businessId: product.businessId,
                                    name: LocalizedString(ar: offer.name, en: offer.name),
                                    description: offer.description != null
                                        ? LocalizedString(ar: offer.description!, en: offer.description!)
                                        : null,
                                    type: offer.type,
                                    productId: product.id,
                                    startDate: offer.startDate ?? DateTime.now(),
                                    endDate: offer.endDate ?? DateTime.now().add(const Duration(days: 7)),
                                    isActive: offer.isActive,
                                    buyQuantity: offer.buyQuantity,
                                    getQuantity: offer.getQuantity,
                                    giftProductId: offer.giftProductId,
                                    giftName: offer.giftName,
                                    couponCode: offer.couponCode,
                                    minOrderAmount: offer.minOrderAmount,
                                  );

                                  context.read<CartProvider>().addOfferToCart(
                                    businessId: product.businessId,
                                    offer: generalOffer,
                                    product: product,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم إضافة العرض إلى السلة بنجاح!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                                label: const Text(
                                  'أضف للسلة',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
