import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/business/products/pages_create_edit_product/info_product.dart';
import 'package:z_ecommerce/presentation/pages/business/products/product_details_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/product_details_page.dart' hide ProductDetailsPage;

class StoreProductsManagementPage extends StatefulWidget {
  const StoreProductsManagementPage({super.key});

  @override
  State<StoreProductsManagementPage> createState() =>
      _StoreProductsManagementPageState();
}

class _StoreProductsManagementPageState
    extends State<StoreProductsManagementPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStoreId =
        context.watch<BusinessProvider>().selectedBusiness.id;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final filteredProducts = provider.allProducts.where((product) {
            return product.businessId == currentStoreId;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationKeys.productsManagement.tr(context),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),

                // AppDataTable for Store Products
                Expanded(
                  child: AppDataTable<ProductModel>(
                    items: filteredProducts,
                    selectable: true,
                    showIndexColumn: true,
                    primaryActionButton: ButtonApp(
                      onPressed: () => changeScreen(
                        context,
                        InfoProductPage(businessId: currentStoreId),
                      ),
                      icon: Icons.add,
                      label: TranslationKeys.addNewProduct.tr(context),
                    ),
                    onBulkDelete: (selected) {
                      for (var p in selected) {
                        provider.deleteProduct(p.id);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${TranslationKeys.deleteSelected.tr(context)} (${selected.length})',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    searchMatcher: (p, q) =>
                        p.name.toLowerCase().contains(q.toLowerCase()) ||
                        p.id.toLowerCase().contains(q.toLowerCase()),
                    emptyMessage: TranslationKeys.noDataAvailable.tr(context),
                    onRowTap: (product) => changeScreen(
                      context,
                      ProductDetailsPage(productId: product.id),
                    ),
                    columns: [
                      AppTableColumn<ProductModel>(
                        title: TranslationKeys.product.tr(context),
                        flex: 2,
                        sortable: true,
                        sortKey: (p) => p.name,
                        cellBuilder: (p) => TableImageTextCell(
                          title: p.name,
                          subtitle: p.id,
                          imageUrl: (p.images.isNotEmpty)
                              ? p.images.first
                              : null,
                          fallbackIcon: Icons.inventory_2_rounded,
                        ),
                      ),
                      AppTableColumn<ProductModel>(
                        title: TranslationKeys.category.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (p) => p.category,
                        cellBuilder: (p) => Text(
                          p.category,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      AppTableColumn<ProductModel>(
                        title: TranslationKeys.price.tr(context),
                        flex: 1,
                        sortable: true,
                        cellBuilder: (p) => TableTextCell(
                          title: '⭐ ${p.rating.toStringAsFixed(1)}',
                          subtitle:
                              '${p.reviewsCount} ${TranslationKeys.reviews.tr(context)}',
                        ),
                      ),
                      AppTableColumn<ProductModel>(
                        title: TranslationKeys.statusActive.tr(context),
                        flex: 1,
                        cellBuilder: (p) => TableStatusBadge.fromStatus(
                          TranslationKeys.statusActive.tr(context),
                        ),
                      ),
                      AppTableColumn<ProductModel>(
                        title: TranslationKeys.actions.tr(context),
                        width: 70,
                        alignment: Alignment.center,
                        cellBuilder: (p) => TablePopupMenuActions(
                          onView: () => changeScreen(
                            context,
                            ProductDetailsPage(productId: p.id),
                          ),
                          onEdit: () => changeScreen(
                            context,
                            InfoProductPage(product: p),
                          ),
                          onDelete: () {
                            provider.deleteProduct(p.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم حذف المنتج "${p.name}" بنجاح',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
