import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/category_model.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/categories/create_edit_category_page.dart';

class CategoriesManagementPage extends StatefulWidget {
  const CategoriesManagementPage({super.key});

  @override
  State<CategoriesManagementPage> createState() =>
      _CategoriesManagementPageState();
}

class _CategoriesManagementPageState extends State<CategoriesManagementPage> {
  String _searchQuery = '';
  List<CategoryModel> _selectedCategories = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {

    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        final filteredCategories = provider.categories.where((cat) {
          final titleStr = cat.label.toLowerCase();
          final matchesQuery =
              _searchQuery.isEmpty ||
              titleStr.contains(_searchQuery.toLowerCase()) ||
              cat.id.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesQuery;
        }).toList();

        final totalItems = filteredCategories.length;
        final totalPages = (totalItems / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
        final paginatedCategories = (startIndex < totalItems)
            ? filteredCategories.sublist(startIndex, endIndex)
            : <CategoryModel>[];

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Height Expanded AppDataTable for CategoryModel
                Expanded(
                  child: AppDataTable<CategoryModel>(
                    items: paginatedCategories,
                    selectable: true,
                    showIndexColumn: true,
                    selectedItems: _selectedCategories,
                    onSelectionChanged: (selected) {
                      setState(() {
                        _selectedCategories = selected;
                      });
                    },
                    primaryActionButton: ButtonApp(
                      onPressed: () =>
                          changeScreen(context, const CreateEditCategoryPage()),
                      icon: Icons.add,
                      label: TranslationKeys.addNewCategory.tr(context),
                    ),
                    onBulkDelete: () {
                      setState(() {
                        for (var c in _selectedCategories) {
                          provider.categories.removeWhere(
                            (item) => item.id == c.id,
                          );
                        }
                        _selectedCategories.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${TranslationKeys.deleteSelected.tr(context)} (${_selectedCategories.length})',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
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
                    columns: [
                      AppTableColumn<CategoryModel>(
                        title: TranslationKeys.categoryName.tr(context),
                        flex: 2,
                        sortable: true,
                        sortKey: (c) => c.label,
                        cellBuilder: (c) => TableImageTextCell(
                          title: c.label,
                          subtitle: 'رمز: ${c.id}',
                          iconBackgroundColor: c.bgColor,
                          fallbackIcon: c.icon ?? Icons.category_rounded,
                        ),
                      ),
                      AppTableColumn<CategoryModel>(
                        title: TranslationKeys.slugKey.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (c) => c.id,
                        cellBuilder: (c) =>
                            TableTextCell(title: c.id, isBold: true),
                      ),
                      AppTableColumn<CategoryModel>(
                        title: TranslationKeys.categoryStatus.tr(context),
                        flex: 1,
                        cellBuilder: (c) => TableStatusBadge.fromStatus(
                          TranslationKeys.statusActive.tr(context),
                        ),
                      ),
                      AppTableColumn<CategoryModel>(
                        title: TranslationKeys.actions.tr(context),
                        width: 70,
                        alignment: Alignment.center,
                        cellBuilder: (c) => TablePopupMenuActions(
                          onView: () => changeScreen(
                            context,
                            CreateEditCategoryPage(category: c),
                          ),
                          onEdit: () => changeScreen(
                            context,
                            CreateEditCategoryPage(category: c),
                          ),
                          onDelete: () {
                            setState(() {
                              provider.categories.removeWhere(
                                (item) => item.id == c.id,
                              );
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم حذف القسم "${c.label}" بنجاح',
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
          ),
        );
      },
    );
  }
}
