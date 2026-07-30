import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class ProductReviewsTab extends StatelessWidget {
  final Product product;

  const ProductReviewsTab({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'التقييمات والمراجعات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Chip(
                avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
                label: Text('${product.rating.toStringAsFixed(1)} / 5.0 (${product.reviewsCount})'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: theme.primaryColor.withOpacity(0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'إجمالي المراجعات المسجلة: ${product.reviewsCount}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'متوسط تقييم العملاء للمنتج: ${product.rating.toStringAsFixed(1)} من 5 نجوم',
                      style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
