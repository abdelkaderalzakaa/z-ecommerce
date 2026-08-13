import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/product_offer_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/pages/business/products/pages_create_edit_product/create_edit_product_offer_page.dart';

class ProductOffersTab extends StatelessWidget {
  final ProductModel product;

  const ProductOffersTab({super.key, required this.product});

  void _deleteOffer(BuildContext context, String offerId) async {
    final provider = context.read<ProductProvider>();
    final updatedList = product.offers.where((o) => o.id != offerId).toList();
    final updatedProduct = product.copyWith(offers: updatedList);
    await provider.updateProduct(updatedProduct);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف العرض بنجاح!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'العروض والاوفرات النشطة للمنتج',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ButtonApp(
                format: FormatButtonApp.outline,
                icon: Icons.add_circle_outline_rounded,
                label: 'إضافة عرض جديد للمنتج',
                onPressed: () {
                  changeScreen(context, CreateEditProductOfferPage(product: product));
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (product.offers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: const Center(
                child: Text(
                  'لا توجد عروض مخصصة أو كوبونات نشطة حالياً لهذا المنتج.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: product.offers.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final offer = product.offers[index];
                final isValid = offer.isValid;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isValid ? theme.primaryColor.withOpacity(0.2) : theme.dividerColor.withOpacity(0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isValid ? theme.primaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_offer_rounded,
                          color: isValid ? theme.primaryColor : Colors.grey,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  offer.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isValid ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isValid ? 'نشط' : 'منتهي / غير نشط',
                                    style: TextStyle(
                                      color: isValid ? Colors.green : Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'نوع العرض: ${offer.type} • الكوبون: ${offer.couponCode ?? "بدون"}',
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                            if (offer.startDate != null && offer.endDate != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'صلاحية العرض: من ${offer.startDate!.toString().substring(0, 10)} إلى ${offer.endDate!.toString().substring(0, 10)}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_note_rounded),
                        onPressed: () {
                          changeScreen(context, CreateEditProductOfferPage(product: product, offer: offer));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        onPressed: () => _deleteOffer(context, offer.id),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
