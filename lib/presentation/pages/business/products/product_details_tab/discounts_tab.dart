import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/discount_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/pages/business/products/pages_create_edit_product/create_edit_discount_page.dart';

class ProductDiscountsTab extends StatelessWidget {
  final ProductModel product;

  const ProductDiscountsTab({super.key, required this.product});

  void _deleteDiscount(BuildContext context, String discountId) async {
    final provider = context.read<ProductProvider>();
    final updatedList = product.discounts.where((d) => d.id != discountId).toList();
    final updatedProduct = product.copyWith(discounts: updatedList);
    await provider.updateProduct(updatedProduct);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الخصم بنجاز!'), backgroundColor: Colors.red),
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
          // Header with Add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إدارة خصومات المنتج والعروض النشطة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ButtonApp(
                format: FormatButtonApp.outline,
                icon: Icons.add_circle_outline_rounded,
                label: 'إضافة خصم جديد',
                onPressed: () {
                  changeScreen(context, CreateEditDiscountPage(product: product));
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Discounts List
          if (product.discounts.isEmpty)
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
                  'لا توجد خصومات مخصصة مضافة حالياً لهذا المنتج.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: product.discounts.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final d = product.discounts[index];
                final isValid = d.isValid;

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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isValid ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.percent_rounded,
                          color: isValid ? Colors.red : Colors.grey,
                          size: 20,
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
                                  d.name,
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
                                    isValid ? 'نشط' : 'غير نشط / منتهي',
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
                              'القيمة: ${d.value}${d.isPercentage ? "%" : "\$"} • النوع: ${d.type}',
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                            if (d.startDate != null && d.endDate != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'صلاحية الخصم: من ${d.startDate!.toString().substring(0, 10)} إلى ${d.endDate!.toString().substring(0, 10)}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_note_rounded),
                        onPressed: () {
                          changeScreen(context, CreateEditDiscountPage(product: product, discount: d));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        onPressed: () => _deleteDiscount(context, d.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 32),

          // Badges / Promotion States
          const Text('شارات الترويج والظهور', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBadgeStatusCard(
                  context,
                  title: 'وصل حديثاً (New Arrival)',
                  isActive: product.isFeatured,
                  activeIcon: Icons.star_rounded,
                  inactiveIcon: Icons.star_outline_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBadgeStatusCard(
                  context,
                  title: 'الأكثر مبيعاً (Top Selling)',
                  isActive: product.isTopSelling,
                  activeIcon: Icons.trending_up_rounded,
                  inactiveIcon: Icons.trending_flat_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeStatusCard(
    BuildContext context, {
    required String title,
    required bool isActive,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? theme.primaryColor.withOpacity(0.06) : theme.dividerColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? theme.primaryColor.withOpacity(0.2) : theme.dividerColor.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? activeIcon : inactiveIcon,
            color: isActive ? theme.primaryColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive ? 'نشط ويظهر للمستهلك' : 'غير مفعل حالياً',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
