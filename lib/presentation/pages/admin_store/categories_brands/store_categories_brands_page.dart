import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/brand_model.dart';
import 'package:z_ecommerce/data/models/product/category_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class StoreCategoriesBrandsPage extends StatefulWidget {
  const StoreCategoriesBrandsPage({super.key});

  @override
  State<StoreCategoriesBrandsPage> createState() =>
      _StoreCategoriesBrandsPageState();
}

class _StoreCategoriesBrandsPageState extends State<StoreCategoriesBrandsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _categorySearch = '';
  String _brandSearch = '';

  int _categoryPage = 1;
  int _brandPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final companyProvider = Provider.of<CompanyProvider>(context);
    final currentStoreId =
        companyProvider.companySettings?.id ??
        context.watch<AuthProvider>().currentUser?.businessId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
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
                    const Text(
                      'إدارة الفئات والأقسام والعلامات التجارية',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إضافة وإدارة تصنيفات وعلامات متجرك التجارية المعروضة للعملاء',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: theme.primaryColor,
                labelColor: theme.primaryColor,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.category_rounded, size: 20),
                    text: 'الأقسام والفئات (Categories)',
                  ),
                  Tab(
                    icon: Icon(Icons.branding_watermark_rounded, size: 20),
                    text: 'العلامات التجارية (Brands)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoriesTab(context, currentStoreId),
                  _buildBrandsTab(context, currentStoreId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 1. CATEGORIES TAB ====================
  Widget _buildCategoriesTab(BuildContext context, String? currentStoreId) {
    return Consumer<CategoryProvider>(
      builder: (context, catProvider, child) {
        final categories = catProvider.categories.where((c) {
          final belongs =
              currentStoreId == null ||
              c.businessId == null ||
              c.businessId == currentStoreId;
          final matches =
              _categorySearch.isEmpty ||
              c.label.toLowerCase().contains(_categorySearch.toLowerCase());
          return belongs && matches;
        }).toList();

        final totalItems = categories.length;
        final totalPages = (totalItems / _itemsPerPage).ceil();
        final startIndex = (_categoryPage - 1) * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
        final paginated = (startIndex < totalItems)
            ? categories.sublist(startIndex, endIndex)
            : <CategoryModel>[];

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _showAddEditCategoryDialog(context, currentStoreId),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('إضافة قسم/فئة جديدة'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AppDataTable<CategoryModel>(
                items: paginated,
                selectable: false,
                showIndexColumn: true,
                searchQuery: _categorySearch,
                onSearchChanged: (val) {
                  setState(() {
                    _categorySearch = val;
                    _categoryPage = 1;
                  });
                },
                currentPage: _categoryPage,
                totalPages: totalPages > 0 ? totalPages : 1,
                totalItems: totalItems,
                itemsPerPage: _itemsPerPage,
                onPageChanged: (p) => setState(() => _categoryPage = p),
                onItemsPerPageChanged: (r) {
                  setState(() {
                    _categoryPage = 1;
                  });
                },
                emptyMessage: 'لا توجد فئات مسجلة لهذا المتجر حالياً',
                columns: [
                  AppTableColumn<CategoryModel>(
                    title: 'القسم / الفئة',
                    flex: 2,
                    sortable: true,
                    sortKey: (c) => c.label,
                    cellBuilder: (c) => TableImageTextCell(
                      title: c.label,
                      subtitle: 'ID: ${c.id}',
                      fallbackIcon: c.icon ?? Icons.category_rounded,
                    ),
                  ),
                  AppTableColumn<CategoryModel>(
                    title: 'لون التمييز',
                    flex: 1,
                    cellBuilder: (c) => Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: c.bgColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '#${c.bgColor.value.toRadixString(16).substring(2).toUpperCase()}',
                        ),
                      ],
                    ),
                  ),
                  AppTableColumn<CategoryModel>(
                    title: TranslationKeys.actions.tr(context),
                    width: 70,
                    alignment: Alignment.center,
                    cellBuilder: (c) => TablePopupMenuActions(
                      onEdit: () => _showAddEditCategoryDialog(
                        context,
                        currentStoreId,
                        category: c,
                      ),
                      onDelete: () async {
                        await catProvider.deleteCategory(c.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم حذف الفئة "${c.label}" بنجاح'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================== 2. BRANDS TAB ====================
  Widget _buildBrandsTab(BuildContext context, String? currentStoreId) {
    return Consumer<BrandProvider>(
      builder: (context, brandProvider, child) {
        final brands = brandProvider.brands.where((b) {
          final belongs =
              currentStoreId == null ||
              b.businessId == null ||
              b.businessId == currentStoreId;
          final matches =
              _brandSearch.isEmpty ||
              b.name.toLowerCase().contains(_brandSearch.toLowerCase());
          return belongs && matches;
        }).toList();

        final totalItems = brands.length;
        final totalPages = (totalItems / _itemsPerPage).ceil();
        final startIndex = (_brandPage - 1) * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
        final paginated = (startIndex < totalItems)
            ? brands.sublist(startIndex, endIndex)
            : <BrandModel>[];

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _showAddEditBrandDialog(context, currentStoreId),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('إضافة علامة تجارية جديدة'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AppDataTable<BrandModel>(
                items: paginated,
                selectable: false,
                showIndexColumn: true,
                searchQuery: _brandSearch,
                onSearchChanged: (val) {
                  setState(() {
                    _brandSearch = val;
                    _brandPage = 1;
                  });
                },
                currentPage: _brandPage,
                totalPages: totalPages > 0 ? totalPages : 1,
                totalItems: totalItems,
                itemsPerPage: _itemsPerPage,
                onPageChanged: (p) => setState(() => _brandPage = p),
                onItemsPerPageChanged: (r) {
                  setState(() {
                    _brandPage = 1;
                  });
                },
                emptyMessage: 'لا توجد علامات تجارية مسجلة لهذا المتجر حالياً',
                columns: [
                  AppTableColumn<BrandModel>(
                    title: 'العلامة التجارية (Brand)',
                    flex: 2,
                    sortable: true,
                    sortKey: (b) => b.name,
                    cellBuilder: (b) => TableImageTextCell(
                      title: b.name,
                      subtitle: b.description ?? 'ID: ${b.id}',
                      imageUrl: b.logoUrl,
                      fallbackIcon: Icons.branding_watermark_rounded,
                    ),
                  ),
                  AppTableColumn<BrandModel>(
                    title: TranslationKeys.actions.tr(context),
                    width: 70,
                    alignment: Alignment.center,
                    cellBuilder: (b) => TablePopupMenuActions(
                      onEdit: () => _showAddEditBrandDialog(
                        context,
                        currentStoreId,
                        brand: b,
                      ),
                      onDelete: () async {
                        await brandProvider.deleteBrand(b.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم حذف العلامة التجارية "${b.name}" بنجاح',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================== DIALOGS ====================

  void _showAddEditCategoryDialog(
    BuildContext context,
    String? currentStoreId, {
    CategoryModel? category,
  }) {
    final nameController = TextEditingController(text: category?.label ?? '');
    final isEdit = category != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'تعديل القسم / الفئة' : 'إضافة قسم / فئة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم القسم أو الفئة (مثال: أقمشة، أحذية، وجبات)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(TranslationKeys.cancel.tr(ctx)),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = nameController.text.trim();
              if (text.isEmpty) return;

              final catProvider = context.read<CategoryProvider>();
              final timestamp = DateTime.now().millisecondsSinceEpoch
                  .toString();
              final catId = isEdit
                  ? category.id
                  : 'cat_${timestamp.substring(timestamp.length - 6)}';

              final newCat = CategoryModel(
                id: catId,
                businessId: currentStoreId ?? category?.businessId,
                label: text,
                bgColor: category?.bgColor ?? const Color(0xFF4F46E5),
                icon: category?.icon ?? Icons.shopping_bag_outlined,
              );

              if (isEdit) {
                await catProvider.updateCategory(newCat);
              } else {
                await catProvider.addCategory(newCat);
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEdit ? 'تم تحديث الفئة بنجاح' : 'تم إضافة الفئة بنجاح',
                    ),
                  ),
                );
              }
            },
            child: Text(
              isEdit
                  ? TranslationKeys.saveChanges.tr(ctx)
                  : TranslationKeys.addNewProduct.tr(ctx),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditBrandDialog(
    BuildContext context,
    String? currentStoreId, {
    BrandModel? brand,
  }) {
    final nameController = TextEditingController(text: brand?.name ?? '');
    final logoController = TextEditingController(text: brand?.logoUrl ?? '');
    final descController = TextEditingController(
      text: brand?.description ?? '',
    );
    final isEdit = brand != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isEdit ? 'تعديل العلامة التجارية' : 'إضافة علامة تجارية جديدة',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم العلامة التجارية (Brand Name)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.branding_watermark_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: logoController,
              decoration: const InputDecoration(
                labelText: 'رابط الشعار (Logo URL)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'وصف أصل وخبرة الماركة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(TranslationKeys.cancel.tr(ctx)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final brandProvider = context.read<BrandProvider>();
              final timestamp = DateTime.now().millisecondsSinceEpoch
                  .toString();
              final brandId = isEdit
                  ? brand.id
                  : 'bnd_${timestamp.substring(timestamp.length - 6)}';

              final newBrand = BrandModel(
                id: brandId,
                businessId: currentStoreId ?? brand?.businessId,
                name: name,
                logoUrl: logoController.text.trim().isNotEmpty
                    ? logoController.text.trim()
                    : null,
                description: descController.text.trim().isNotEmpty
                    ? descController.text.trim()
                    : null,
              );

              if (isEdit) {
                await brandProvider.updateBrand(newBrand);
              } else {
                await brandProvider.addBrand(newBrand);
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEdit
                          ? 'تم تحديث العلامة بنجاح'
                          : 'تم إضافة العلامة بنجاح',
                    ),
                  ),
                );
              }
            },
            child: Text(
              isEdit
                  ? TranslationKeys.saveChanges.tr(ctx)
                  : TranslationKeys.addNewProduct.tr(ctx),
            ),
          ),
        ],
      ),
    );
  }
}
