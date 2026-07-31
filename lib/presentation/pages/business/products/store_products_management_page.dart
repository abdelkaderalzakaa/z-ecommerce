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
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/products/create_edit_product_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/products/product_details_page.dart';

class StoreProductsManagementPage extends StatefulWidget {
  const StoreProductsManagementPage({super.key});

  @override
  State<StoreProductsManagementPage> createState() =>
      _StoreProductsManagementPageState();
}

class _StoreProductsManagementPageState
    extends State<StoreProductsManagementPage> {
  String _searchQuery = '';
  List<ProductModel> _selectedProducts = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStoreId =
        context.watch<BusinessProvider>().selectedBusiness?.id ??
        context.read<AuthProvider>().currentUser?.businessId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final filteredProducts = provider.allProducts.where((product) {
            final belongsToStore =
                currentStoreId == null || product.businessId == currentStoreId;
            final titleStr = product.name.toLowerCase();
            final matchesQuery =
                _searchQuery.isEmpty ||
                titleStr.contains(_searchQuery.toLowerCase()) ||
                product.id.toLowerCase().contains(_searchQuery.toLowerCase());
            return belongsToStore && matchesQuery;
          }).toList();

          final totalItems = filteredProducts.length;
          final totalPages = (totalItems / _itemsPerPage).ceil();
          final startIndex = (_currentPage - 1) * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
          final paginatedProducts = (startIndex < totalItems)
              ? filteredProducts.sublist(startIndex, endIndex)
              : <ProductModel>[];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TranslationKeys.productsManagement.tr(context),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          TranslationKeys.productsSubtitle.tr(context),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => changeScreen(
                        context,
                        CreateEditProductPage(businessId: currentStoreId),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(TranslationKeys.addNewProduct.tr(context)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // AppDataTable for Store Products
                Expanded(
                  child: AppDataTable<ProductModel>(
                    items: paginatedProducts,
                    selectable: true,
                    showIndexColumn: true,
                    selectedItems: _selectedProducts,
                    onSelectionChanged: (selected) {
                      setState(() {
                        _selectedProducts = selected;
                      });
                    },
                    onBulkDelete: () {
                      for (var p in _selectedProducts) {
                        provider.deleteProduct(p.id);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${TranslationKeys.deleteSelected.tr(context)} (${_selectedProducts.length})',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      setState(() {
                        _selectedProducts.clear();
                      });
                    },
                    searchQuery: _searchQuery,
                    onSearchChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _currentPage = 1;
                      });
                    },
                    currentPage: _currentPage,
                    totalPages: totalPages > 0 ? totalPages : 1,
                    totalItems: totalItems,
                    itemsPerPage: _itemsPerPage,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    onItemsPerPageChanged: (rows) {
                      setState(() {
                        _itemsPerPage = rows;
                        _currentPage = 1;
                      });
                    },
                    emptyMessage: _searchQuery.isNotEmpty
                        ? TranslationKeys.noMatchingResults.tr(context)
                        : TranslationKeys.noDataAvailable.tr(context),
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
                            CreateEditProductPage(product: p),
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
