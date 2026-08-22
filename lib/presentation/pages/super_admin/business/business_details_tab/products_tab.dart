import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/business/products/pages_create_edit_product/info_product.dart';

class ProductsTab extends StatefulWidget {
  final BusinessModel store;

  const ProductsTab({super.key, required this.store});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().listenToAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final storeProducts = provider.allProducts.where((p) {
          return p.businessId == widget.store.id;
        }).toList();

        final isAr = Localizations.localeOf(context).languageCode == 'ar';

        return Expanded(
                child: AppDataTable<ProductModel>(
                  items: storeProducts,
                  selectable: true,
                  showIndexColumn: true,
                  onBulkDelete: (selected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${TranslationKeys.deleteSelected.tr(context)} (${selected.length})',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  primaryActionButton: ButtonApp(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              InfoProductPage(businessId: widget.store.id),
                        ),
                      );
                    },
                    icon: Icons.add,
                    label: isAr ? 'إضافة منتج' : 'Add Product',
                  ),
                  searchMatcher: (p, q) =>
                      p.name.toLowerCase().contains(q.toLowerCase()) ||
                      p.id.toLowerCase().contains(q.toLowerCase()),
                  emptyMessage: TranslationKeys.noDataAvailable.tr(context),
                  columns: [
                    AppTableColumn<ProductModel>(
                      title: TranslationKeys.product.tr(context),
                      flex: 2,
                      sortable: true,
                      sortKey: (p) => p.name,
                      cellBuilder: (p) => TableTextCell(
                        title: p.name,
                        subtitle: p.id,
                      ),
                    ),
                    AppTableColumn<ProductModel>(
                      title: TranslationKeys.category.tr(context),
                      flex: 1,
                      sortable: true,
                      sortKey: (p) => p.categoryId,
                      cellBuilder: (p) => TableTextCell(
                        title: p.categoryId,
                      ),
                    ),
                    AppTableColumn<ProductModel>(
                      title: TranslationKeys.price.tr(context),
                      flex: 1,
                      sortable: true,
                      sortKey: (p) => p.basePrice,
                      cellBuilder: (p) => TablePriceCell(amount: p.basePrice),
                    ),
                    AppTableColumn<ProductModel>(
                      title: TranslationKeys.rating.tr(context),
                      flex: 1,
                      sortable: true,
                      sortKey: (p) => p.rating,
                      cellBuilder: (p) => TableTextCell(
                        title: '⭐ ${p.rating.toStringAsFixed(1)}',
                        subtitle: '${p.reviewsCount}',
                      ),
                    ),
                    AppTableColumn<ProductModel>(
                      title: TranslationKeys.recommendedProducts.tr(context),
                      flex: 1,
                      sortable: true,
                      sortKey: (p) => p.isRecommended ? 1 : 0,
                      cellBuilder: (p) => Switch(
                        value: p.isRecommended,
                        onChanged: (val) {
                          if (val && p.basePrice == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('لا يمكن تعيين منتج سعره صفر كمنتج موصى به'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          final updated = p.copyWith(isRecommended: val);
                          Provider.of<ProductProvider>(
                            context,
                            listen: false,
                          ).updateProduct(updated);
                        },
                      ),
                    ),
                    AppTableColumn<ProductModel>(
                      title: TranslationKeys.actions.tr(context),
                      width: 70,
                      alignment: Alignment.center,
                      cellBuilder: (p) => TablePopupMenuActions(
                        onView: () {},
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InfoProductPage(
                                product: p,
                                businessId: widget.store.id,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          Provider.of<ProductProvider>(
                            context,
                            listen: false,
                          ).deleteProduct(p.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم حذف المنتج بنجاح'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
           ;
      },
    );
  }
}
