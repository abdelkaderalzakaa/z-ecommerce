import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/company_settings_model.dart';
import 'package:z_ecommerce/data/models/product_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class ProductsTab extends StatefulWidget {
  final CompanySettingsModel store;

  const ProductsTab({super.key, required this.store});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  String _searchQuery = '';
  List<Product> _selectedProducts = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final storeProducts = provider.allProducts.where((p) {
          final titleStr = p.name.toLowerCase();
          final matchesQuery = _searchQuery.isEmpty ||
              titleStr.contains(_searchQuery.toLowerCase()) ||
              p.id.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesQuery;
        }).toList();

        final totalItems = storeProducts.length;
        final totalPages = (totalItems / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
        final paginatedProducts = (startIndex < totalItems)
            ? storeProducts.sublist(startIndex, endIndex)
            : <Product>[];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppDataTable<Product>(
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${TranslationKeys.deleteSelected.tr(context)} (${_selectedProducts.length})'),
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
            onPageChanged: (page) => setState(() => _currentPage = page),
            onItemsPerPageChanged: (rows) {
              setState(() {
                _itemsPerPage = rows;
                _currentPage = 1;
              });
            },
            emptyMessage: _searchQuery.isNotEmpty
                ? TranslationKeys.noMatchingResults.tr(context)
                : TranslationKeys.noDataAvailable.tr(context),
            columns: [
              AppTableColumn<Product>(
                title: TranslationKeys.product.tr(context),
                flex: 2,
                sortable: true,
                sortKey: (p) => p.name,
                cellBuilder: (p) => TableImageTextCell(
                  title: p.name,
                  subtitle: 'رمز: ${p.id}',
                  imageUrl: p.images.isNotEmpty ? p.images.first : null,
                  fallbackIcon: Icons.inventory_2_rounded,
                ),
              ),
              AppTableColumn<Product>(
                title: TranslationKeys.price.tr(context),
                flex: 1,
                sortable: true,
                sortKey: (p) => p.price,
                cellBuilder: (p) => TablePriceCell(
                  amount: p.price,
                ),
              ),
              AppTableColumn<Product>(
                title: TranslationKeys.rating.tr(context),
                flex: 1,
                sortable: true,
                sortKey: (p) => p.rating,
                cellBuilder: (p) => TableTextCell(
                  title: '⭐ ${p.rating.toStringAsFixed(1)}',
                  subtitle: '${p.reviewsCount}',
                ),
              ),
              AppTableColumn<Product>(
                title: TranslationKeys.actions.tr(context),
                width: 70,
                alignment: Alignment.center,
                cellBuilder: (p) => TablePopupMenuActions(
                  onView: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
