import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class ProductInventoryTab extends StatelessWidget {
  final Product product;

  const ProductInventoryTab({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المخزون والخيارات المتاحة',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Available Colors Card
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
                  Row(
                    children: [
                      const Icon(Icons.palette_rounded, size: 20, color: Colors.indigo),
                      const SizedBox(width: 10),
                      Text(
                        TranslationKeys.colors.tr(context),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (product.colors.isEmpty)
                    Text(
                      TranslationKeys.noColorsAvailable.tr(context),
                      style: TextStyle(color: theme.textTheme.bodySmall?.color),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: product.colors.map((c) {
                        return Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Available Sizes Card
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
                  Row(
                    children: [
                      const Icon(Icons.straighten_rounded, size: 20, color: Colors.orange),
                      const SizedBox(width: 10),
                      Text(
                        TranslationKeys.size.tr(context),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (product.sizes.isEmpty)
                    Text(
                      TranslationKeys.noSizesAvailable.tr(context),
                      style: TextStyle(color: theme.textTheme.bodySmall?.color),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: product.sizes.map((s) {
                        return Chip(
                          label: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: theme.primaryColor.withOpacity(0.08),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
