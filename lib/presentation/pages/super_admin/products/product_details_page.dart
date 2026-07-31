import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/details_template.dart';

import 'product_details_tab/overview_tab.dart';
import 'product_details_tab/inventory_tab.dart';
import 'product_details_tab/orders_tab.dart';
import 'product_details_tab/reviews_tab.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final product = provider.allProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => provider.allProducts.first,
        );

        return DetailsTemplate(
          title: TranslationKeys.productDetails.tr(context),
          name: product.name,
          subtitle: '${TranslationKeys.category.tr(context)}: ${product.category} • ${product.id}',
          avatarUrl: product.images.isNotEmpty ? product.images.first : null,
          fallbackIcon: Icons.inventory_2_rounded,
          statusBadge: TableStatusBadge.fromStatus(
            TranslationKeys.statusActive.tr(context),
          ),
          headerMetrics: [
            Chip(
              avatar: const Icon(Icons.attach_money_rounded, size: 16, color: Colors.green),
              label: Text('\$${product.basePrice.toStringAsFixed(2)}'),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Chip(
              avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
              label: Text('⭐ ${product.ratings.isNotEmpty ? (product.ratings.map((e) => e.rating).reduce((a, b) => a + b) / product.ratings.length).toStringAsFixed(1) : '0.0'}'),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            if (product.brand != null)
              Chip(
                avatar: const Icon(Icons.branding_watermark_rounded, size: 16, color: Colors.blue),
                label: Text(product.brand!),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
          onRefresh: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث بيانات المنتج')),
            );
          },
          onEdit: () {
            changeScreen(
              context,
              CreateEditProductPage(product: product),
            );
          },
          onDelete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${TranslationKeys.deleteSelected.tr(context)} "${product.name}"'),
                backgroundColor: Colors.red,
              ),
            );
          },
          tabs: [
            Tab(text: TranslationKeys.overviewTab.tr(context)),
            const Tab(text: 'المخزون والخيارات'),
            Tab(text: TranslationKeys.ordersTab.tr(context)),
            const Tab(text: 'التقييمات والمراجعات'),
          ],
          tabViews: [
            ProductOverviewTab(product: product),
            ProductInventoryTab(product: product),
            ProductOrdersTab(product: product),
            ProductReviewsTab(product: product),
          ],
        );
      },
    );
  }
}
