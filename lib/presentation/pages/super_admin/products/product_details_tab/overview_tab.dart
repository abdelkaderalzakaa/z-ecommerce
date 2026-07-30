import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class ProductOverviewTab extends StatelessWidget {
  final Product product;

  const ProductOverviewTab({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pricing & Tags Summary Header Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TranslationKeys.price.tr(context),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (product.originalPrice != null) ...[
                              const SizedBox(width: 10),
                              Text(
                                '\$${product.originalPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                            if (product.discountPercent != null) ...[
                              const SizedBox(width: 10),
                              Chip(
                                label: Text(
                                  '${product.discountPercent}% ${TranslationKeys.discount.tr(context)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.redAccent,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (product.isNewArrival)
                        Chip(
                          avatar: const Icon(Icons.fiber_new_rounded, size: 16, color: Colors.white),
                          label: const Text('جديد', style: TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: Colors.blueAccent,
                        ),
                      if (product.isTopSelling)
                        Chip(
                          avatar: const Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.white),
                          label: const Text('الأكثر مبيعاً', style: TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: Colors.deepOrangeAccent,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Images Gallery Preview Card
          if (product.images.isNotEmpty) ...[
            Text(
              'معاينة الصور',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: product.images.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final img = product.images[index];
                  return Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
                      image: img.startsWith('http')
                          ? DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)
                          : null,
                    ),
                    child: !img.startsWith('http')
                        ? const Center(child: Icon(Icons.image_not_supported_rounded, color: Colors.grey))
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Product Details Info Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TranslationKeys.productDetails.tr(context),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailItem(context, TranslationKeys.category.tr(context), product.category),
                  if (product.brand != null) ...[
                    const Divider(),
                    _buildDetailItem(context, 'العلامة التجارية', product.brand!),
                  ],
                  const Divider(),
                  _buildDetailItem(context, 'معرف المنتج (ID)', product.id),
                  const Divider(),
                  const SizedBox(height: 6),
                  Text(
                    'الوصف:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
