import 'dart:convert';

import 'package:excel/excel.dart' as excel;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:z_ecommerce/core/services/excel_export_service.dart';

import 'package:z_ecommerce/data/models/product/brand_model.dart';
import 'package:z_ecommerce/data/models/product/category_model.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

// ─── Data Models ───────────────────────────────────────────────────────────────

class _ImportPreview {
  final List<CategoryModel> categories;
  final List<BrandModel> brands;
  final List<ProductModel> products;
  final List<String> errors;

  const _ImportPreview({
    this.categories = const [],
    this.brands = const [],
    this.products = const [],
    this.errors = const [],
  });

  int get totalItems => categories.length + brands.length + products.length;
}

class _ImportProgress {
  final String label;
  final bool done;
  final bool hasError;
  const _ImportProgress({
    required this.label,
    this.done = false,
    this.hasError = false,
  });
}

class _ImportDiffSummary {
  final int newCategories;
  final int newBrands;
  final int newProducts;
  final List<String> categoryChanges;
  final List<String> brandChanges;
  final List<String> productChanges;

  const _ImportDiffSummary({
    this.newCategories = 0,
    this.newBrands = 0,
    this.newProducts = 0,
    this.categoryChanges = const [],
    this.brandChanges = const [],
    this.productChanges = const [],
  });

  bool get hasAnyChange =>
      newCategories > 0 ||
      newBrands > 0 ||
      newProducts > 0 ||
      categoryChanges.isNotEmpty ||
      brandChanges.isNotEmpty ||
      productChanges.isNotEmpty;
}

// ─── Page ──────────────────────────────────────────────────────────────────────

class ExcelImportPage extends StatefulWidget {
  final String businessId;
  final String businessName;

  const ExcelImportPage({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  @override
  State<ExcelImportPage> createState() => _ExcelImportPageState();
}

class _ExcelImportPageState extends State<ExcelImportPage>
    with SingleTickerProviderStateMixin {
  bool _isReading = false;
  bool _isImporting = false;
  _ImportPreview? _preview;
  String? _fileName;
  List<_ImportProgress> _progressItems = [];
  int _completedCount = 0;
  bool _importDone = false;
  Map<String, String> _categoryStatus = {};
  Map<String, String> _brandStatus = {};
  Map<String, String> _productStatus = {};
  Set<String> _selectedCategoryIds = {};
  Set<String> _selectedBrandIds = {};
  Set<String> _selectedProductIds = {};

  TabController? _tabController;

  List<CategoryModel> get _selectedCategories =>
      _preview?.categories
              .where((item) => _selectedCategoryIds.contains(item.id))
              .toList() ??
          const [];

  List<BrandModel> get _selectedBrands =>
      _preview?.brands
              .where((item) => _selectedBrandIds.contains(item.id))
              .toList() ??
          const [];

  List<ProductModel> get _selectedProducts =>
      _preview?.products
              .where((item) => _selectedProductIds.contains(item.id))
              .toList() ??
          const [];

  int get _selectedTotal =>
      _selectedCategories.length + _selectedBrands.length + _selectedProducts.length;

  void _syncSelection(_ImportPreview preview) {
    _selectedCategoryIds = {
      for (final item in preview.categories) item.id,
    };
    _selectedBrandIds = {
      for (final item in preview.brands) item.id,
    };
    _selectedProductIds = {
      for (final item in preview.products) item.id,
    };
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedCategoryIds.contains(id)) {
        _selectedCategoryIds.remove(id);
      } else {
        _selectedCategoryIds.add(id);
      }
    });
  }

  void _toggleBrand(String id) {
    setState(() {
      if (_selectedBrandIds.contains(id)) {
        _selectedBrandIds.remove(id);
      } else {
        _selectedBrandIds.add(id);
      }
    });
  }

  void _toggleProduct(String id) {
    setState(() {
      if (_selectedProductIds.contains(id)) {
        _selectedProductIds.remove(id);
      } else {
        _selectedProductIds.add(id);
      }
    });
  }

  void _selectAllVisible() {
    if (_preview == null) return;
    setState(() {
      _selectedCategoryIds = {for (final item in _preview!.categories) item.id};
      _selectedBrandIds = {for (final item in _preview!.brands) item.id};
      _selectedProductIds = {for (final item in _preview!.products) item.id};
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedCategoryIds.clear();
      _selectedBrandIds.clear();
      _selectedProductIds.clear();
    });
  }

  static const _primary = Color(0xFF6366F1);
  static const _success = Color(0xFF10B981);
  static const _warning = Color(0xFFF59E0B);
  static const _error = Color(0xFFEF4444);
  static const _surface = Color(0xFFF8FAFC);

  // ── Parse helpers ────────────────────────────────────────────────────────

  static dynamic _parseJson(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    final normalized = val.trim();
    final lower = normalized.toLowerCase();
    if (lower == 'true' || lower == 'false' || lower == 'null') return null;
    if (!normalized.startsWith('{') && !normalized.startsWith('[')) return null;
    try {
      return jsonDecode(normalized);
    } catch (_) {
      return null;
    }
  }

  static String _safeCellStr(List<dynamic>? row, int index) {
    if (row == null || index >= row.length) return '';
    final value = row[index]?.value;
    if (value == null) return '';
    if (value is bool) return value ? 'true' : 'false';
    if (value is DateTime) return value.toIso8601String();
    return value.toString();
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    if (value is num) return value != 0;
    return false;
  }

  Future<void> _loadPreviewStatus(_ImportPreview preview) async {
    final categoryProvider = context.read<CategoryProvider>();
    final brandProvider = context.read<BrandProvider>();
    final productProvider = context.read<ProductProvider>();

    if (categoryProvider.categories.isEmpty) {
      await categoryProvider.fetchCategories(businessId: widget.businessId);
    }
    if (brandProvider.brands.isEmpty) {
      await brandProvider.fetchBrands(businessId: widget.businessId);
    }
    if (productProvider.storeProducts.isEmpty) {
      await productProvider.fetchProductsByBusiness(widget.businessId);
    }

    final categoryMap = {
      for (final item in categoryProvider.categories
          .where((c) => c.businessIds.contains(widget.businessId)))
        item.id: true,
    };
    final brandMap = {
      for (final item in brandProvider.brands
          .where((b) => b.businessIds.contains(widget.businessId)))
        item.id: true,
    };
    final productMap = {
      for (final item in productProvider.storeProducts
          .where((p) => p.businessId == widget.businessId))
        item.id: true,
    };

    setState(() {
      _categoryStatus = {
        for (final item in preview.categories)
          item.id: categoryMap.containsKey(item.id) ? 'موجود' : 'جديد',
      };
      _brandStatus = {
        for (final item in preview.brands)
          item.id: brandMap.containsKey(item.id) ? 'موجود' : 'جديد',
      };
      _productStatus = {
        for (final item in preview.products)
          item.id: productMap.containsKey(item.id) ? 'موجود' : 'جديد',
      };
    });
  }

  Future<_ImportPreview> _parseExcel(List<int> bytes) async {
    final workbook = excel.Excel.decodeBytes(bytes);
    final errors = <String>[];

    // Categories
    final categories = <CategoryModel>[];
    final catSheet = workbook.tables['الفئات'];
    if (catSheet != null) {
      for (int i = 2; i < catSheet.maxRows; i++) {
        final row = catSheet.rows[i];
        if (row.isEmpty) continue;
        try {
          final id = _safeCellStr(row, 0);
          if (id.isEmpty) continue;
          final map = {
            'id': id,
            'businessIds': [widget.businessId],
            'label': _safeCellStr(row, 2),
            'bgColor': _safeCellStr(row, 5).isEmpty ? '4294507263' : _safeCellStr(row, 5),
            'iconCodePoint': null,
            'isGlobal': false,
            'isRecommended': false,
          };
          categories.add(CategoryModel.fromJson(map));
        } catch (e) {
          errors.add('فئة صف $i: $e');
        }
      }
    }

    // Brands
    final brands = <BrandModel>[];
    final brandSheet = workbook.tables['العلامات التجارية'];
    if (brandSheet != null) {
      for (int i = 2; i < brandSheet.maxRows; i++) {
        final row = brandSheet.rows[i];
        if (row.isEmpty) continue;
        try {
          final id = _safeCellStr(row, 0);
          if (id.isEmpty) continue;
          final map = {
            'id': id,
            'businessIds': [widget.businessId],
            'name': _safeCellStr(row, 2),
            'logoUrl': _safeCellStr(row, 4).isEmpty ? null : _safeCellStr(row, 4),
            'isGlobal': false,
            'isRecommended': false,
          };
          brands.add(BrandModel.fromJson(map));
        } catch (e) {
          errors.add('علامة تجارية صف $i: $e');
        }
      }
    }

    // Products
    final products = <ProductModel>[];
    final prodSheet = workbook.tables['المنتجات'];
    if (prodSheet != null) {
      for (int i = 2; i < prodSheet.maxRows; i++) {
        final row = prodSheet.rows[i];
        if (row.isEmpty) continue;
        try {
          final id = _safeCellStr(row, 0);
          if (id.isEmpty) continue;
          final map = {
            'id': id,
            'businessId': widget.businessId,
            'categoryId': _safeCellStr(row, 2),
            'brandId': _safeCellStr(row, 3),
            'name': _safeCellStr(row, 4),
            'description': _safeCellStr(row, 5),
            'images': _parseJson(_safeCellStr(row, 6)),
            'basePrice': double.tryParse(_safeCellStr(row, 7)) ?? 0,
            'costPrice': double.tryParse(_safeCellStr(row, 8)) ?? 0,
            'discount': double.tryParse(_safeCellStr(row, 9)) ?? 0,
            'currency': _safeCellStr(row, 10).isEmpty ? 'SAR' : _safeCellStr(row, 10),
            'isAvailable': _toBool(_safeCellStr(row, 11)),
            'stockQuantity': int.tryParse(_safeCellStr(row, 12)) ?? 0,
            'variants': _parseJson(_safeCellStr(row, 13)),
            'tags': _parseJson(_safeCellStr(row, 14)),
            'relatedProductIds': _parseJson(_safeCellStr(row, 15)),
            'specifications': _parseJson(_safeCellStr(row, 16)),
            'additionalFees': _parseJson(_safeCellStr(row, 17)),
            'hasDiscount': _toBool(_safeCellStr(row, 18)),
            'isFeatured': _toBool(_safeCellStr(row, 19)),
            'isNewArrival': _toBool(_safeCellStr(row, 20)),
            'isBestSeller': _toBool(_safeCellStr(row, 21)),
            'barcode': _safeCellStr(row, 22),
            'sku': _safeCellStr(row, 23),
            'weight': double.tryParse(_safeCellStr(row, 24)) ?? 0,
            'dimensions': _safeCellStr(row, 25),
            'shippingClass': _safeCellStr(row, 26),
            'minOrderQuantity': int.tryParse(_safeCellStr(row, 27)) ?? 1,
            'maxOrderQuantity': int.tryParse(_safeCellStr(row, 28)) ?? 0,
            'isDigital': _toBool(_safeCellStr(row, 29)),
            'seoData': _parseJson(_safeCellStr(row, 30)),
            'rating': double.tryParse(_safeCellStr(row, 31)) ?? 0,
            'ratings': _parseJson(_safeCellStr(row, 32)),
            'offers': _parseJson(_safeCellStr(row, 33)),
            'createdAt': _safeCellStr(row, 34).isEmpty ? DateTime.now().toIso8601String() : _safeCellStr(row, 34),
            'updatedAt': _safeCellStr(row, 35).isEmpty ? DateTime.now().toIso8601String() : _safeCellStr(row, 35),
          };
          products.add(ProductModel.fromMap(map, docId: id));
        } catch (e) {
          errors.add('منتج صف $i: $e');
        }
      }
    }

    return _ImportPreview(
      categories: categories,
      brands: brands,
      products: products,
      errors: errors,
    );
  }

  // ── File Pick ────────────────────────────────────────────────────────────

  void _pickFile() {
    final input = html.FileUploadInputElement()..accept = '.xlsx';
    input.click();
    input.onChange.listen((event) async {
      final files = input.files;
      if (files == null || files.isEmpty) return;
      final file = files[0];
      setState(() {
        _isReading = true;
        _fileName = file.name;
        _preview = null;
        _importDone = false;
        _progressItems = [];
        _selectedCategoryIds.clear();
        _selectedBrandIds.clear();
        _selectedProductIds.clear();
      });

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoadEnd.first;

      final bytes = reader.result as List<int>;
      try {
        final preview = await _parseExcel(bytes);
        await _loadPreviewStatus(preview);
        _tabController?.dispose();
        _tabController = TabController(length: 3, vsync: this);
        _syncSelection(preview);
        setState(() {
          _preview = preview;
          _isReading = false;
        });
      } catch (e) {
        setState(() => _isReading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في قراءة الملف: $e'),
              backgroundColor: _error,
            ),
          );
        }
      }
    });
  }

  // ── Import ───────────────────────────────────────────────────────────────

  Future<_ImportDiffSummary> _buildImportDiffSummary(
    _ImportPreview preview,
  ) async {
    final categoryProvider = context.read<CategoryProvider>();
    final brandProvider = context.read<BrandProvider>();
    final productProvider = context.read<ProductProvider>();

    if (categoryProvider.categories.isEmpty) {
      await categoryProvider.fetchCategories(businessId: widget.businessId);
    }
    if (brandProvider.brands.isEmpty) {
      await brandProvider.fetchBrands(businessId: widget.businessId);
    }
    if (productProvider.storeProducts.isEmpty) {
      await productProvider.fetchProductsByBusiness(widget.businessId);
    }

    final currentCategories = categoryProvider.categories
        .where((c) => c.businessIds.contains(widget.businessId))
        .toList();
    final currentBrands = brandProvider.brands
        .where((b) => b.businessIds.contains(widget.businessId))
        .toList();
    final currentProducts = productProvider.storeProducts
        .where((p) => p.businessId == widget.businessId)
        .toList();

    final categoryMap = {
      for (final item in currentCategories) item.id: item,
    };
    final brandMap = {
      for (final item in currentBrands) item.id: item,
    };
    final productMap = {
      for (final item in currentProducts) item.id: item,
    };

    final categoryChanges = <String>[];
    for (final item in preview.categories) {
      final existing = categoryMap[item.id];
      if (existing == null) continue;
      final differences = <String>[];
      if (existing.label != item.label) differences.add('الاسم');
      if (existing.bgColor.value != item.bgColor.value) differences.add('اللون');
      if (existing.businessIds.toSet() != item.businessIds.toSet()) {
        differences.add('ربط المتجر');
      }
      if (differences.isNotEmpty) {
        categoryChanges.add(
          'الفئة "${item.label}" تم تغيير: ${differences.join(', ')}',
        );
      }
    }

    final brandChanges = <String>[];
    for (final item in preview.brands) {
      final existing = brandMap[item.id];
      if (existing == null) continue;
      final differences = <String>[];
      if (existing.name != item.name) differences.add('الاسم');
      if ((existing.logoUrl ?? '') != (item.logoUrl ?? '')) {
        differences.add('الشعار');
      }
      if (existing.businessIds.toSet() != item.businessIds.toSet()) {
        differences.add('ربط المتجر');
      }
      if (differences.isNotEmpty) {
        brandChanges.add(
          'العلامة "${item.name}" تم تغيير: ${differences.join(', ')}',
        );
      }
    }

    final productChanges = <String>[];
    for (final item in preview.products) {
      final existing = productMap[item.id];
      if (existing == null) continue;
      final differences = <String>[];
      if (existing.name != item.name) differences.add('الاسم');
      if (existing.description != item.description) differences.add('الوصف');
      if (existing.categoryId != item.categoryId) differences.add('التصنيف');
      if ((existing.brandId ?? '') != (item.brandId ?? '')) {
        differences.add('الماركة');
      }
      if (existing.defaultVariant.price != item.defaultVariant.price) {
        differences.add('السعر');
      }
      if (existing.isFeatured != item.isFeatured) differences.add('مميز');
      if (existing.isTopSelling != item.isTopSelling) {
        differences.add('الأكثر مبيعاً');
      }
      if (existing.isActive != item.isActive) differences.add('الحالة');
      if (differences.isNotEmpty) {
        productChanges.add(
          'المنتج "${item.name}" تم تغيير: ${differences.join(', ')}',
        );
      }
    }

    return _ImportDiffSummary(
      newCategories: preview.categories
          .where((item) => !categoryMap.containsKey(item.id))
          .length,
      newBrands: preview.brands.where((item) => !brandMap.containsKey(item.id)).length,
      newProducts: preview.products
          .where((item) => !productMap.containsKey(item.id))
          .length,
      categoryChanges: categoryChanges,
      brandChanges: brandChanges,
      productChanges: productChanges,
    );
  }

  Future<void> _startImport() async {
    if (_preview == null) return;
    final preview = _ImportPreview(
      categories: _selectedCategories,
      brands: _selectedBrands,
      products: _selectedProducts,
      errors: _preview!.errors,
    );

    if (preview.totalItems == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد عنصر واحد على الأقل للاستيراد.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final diff = await _buildImportDiffSummary(preview);

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تقرير قبل الاستيراد'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('البزنس: ${widget.businessName}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.folder_rounded, size: 18, color: _primary),
                      const SizedBox(width: 8),
                      Text('الفئات: ${preview.categories.length}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.label_rounded, size: 18, color: _warning),
                      const SizedBox(width: 8),
                      Text('الماركات: ${preview.brands.length}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_rounded, size: 18, color: _success),
                      const SizedBox(width: 8),
                      Text('المنتجات: ${preview.products.length}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'التحقق قبل الإدخال:',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text('جديد الفئات: ${diff.newCategories}'),
                        Text('جديد العلامات: ${diff.newBrands}'),
                        Text('جديد المنتجات: ${diff.newProducts}'),
                        if (diff.categoryChanges.isNotEmpty)
                          ...diff.categoryChanges.map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('• $line', style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        if (diff.brandChanges.isNotEmpty)
                          ...diff.brandChanges.map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('• $line', style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        if (diff.productChanges.isNotEmpty)
                          ...diff.productChanges.map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('• $line', style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        if (!diff.hasAnyChange)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'لا توجد تغييرات على العناصر الحالية. سيتم إدراج العناصر الجديدة فقط.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (preview.errors.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _error.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _error.withOpacity(0.25)),
                      ),
                      child: Text(
                        'تحذيرات: ${preview.errors.length} سجلًا قد يتطلب مراجعة يدويًا قبل الحفظ.',
                        style: const TextStyle(color: _error, fontSize: 12),
                      ),
                    )
                  else
                    const Text(
                      'لا توجد أخطاء في الملف، ويمكن إدراج البيانات في البزنس المحدد.',
                      style: TextStyle(color: Color(0xFF475569), fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ButtonApp(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: Icons.upload_rounded,
              label: 'تأكيد الاستيراد',
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final categoryProvider = context.read<CategoryProvider>();
    final brandProvider = context.read<BrandProvider>();
    final productProvider = context.read<ProductProvider>();

    final items = <_ImportProgress>[];
    for (final c in preview.categories) {
      items.add(_ImportProgress(label: 'فئة: ${c.label}'));
    }
    for (final b in preview.brands) {
      items.add(_ImportProgress(label: 'علامة: ${b.name}'));
    }
    for (final p in preview.products) {
      items.add(_ImportProgress(label: 'منتج: ${p.name}'));
    }

    setState(() {
      _progressItems = items;
      _completedCount = 0;
      _isImporting = true;
      _importDone = false;
    });

    int idx = 0;

    for (final cat in preview.categories) {
      try {
        await categoryProvider.addCategory(cat);
        setState(() {
          _progressItems[idx] = _ImportProgress(
            label: _progressItems[idx].label,
            done: true,
          );
          _completedCount++;
        });
      } catch (_) {
        setState(() {
          _progressItems[idx] = _ImportProgress(
            label: _progressItems[idx].label,
            done: true,
            hasError: true,
          );
          _completedCount++;
        });
      }
      idx++;
    }

    for (final brand in preview.brands) {
      try {
        await brandProvider.addBrand(brand);
        setState(() {
          _progressItems[idx] = _ImportProgress(
            label: _progressItems[idx].label,
            done: true,
          );
          _completedCount++;
        });
      } catch (_) {
        setState(() {
          _progressItems[idx] = _ImportProgress(
            label: _progressItems[idx].label,
            done: true,
            hasError: true,
          );
          _completedCount++;
        });
      }
      idx++;
    }

    for (final prod in preview.products) {
      try {
        await productProvider.addProduct(prod);
        setState(() {
          _progressItems[idx] = _ImportProgress(
            label: _progressItems[idx].label,
            done: true,
          );
          _completedCount++;
        });
      } catch (_) {
        setState(() {
          _progressItems[idx] = _ImportProgress(
            label: _progressItems[idx].label,
            done: true,
            hasError: true,
          );
          _completedCount++;
        });
      }
      idx++;
    }

    setState(() {
      _isImporting = false;
      _importDone = true;
    });
  }

  // ── Template Download ────────────────────────────────────────────────────

  void _downloadTemplate() {
    final workbook = excel.Excel.createExcel();

    void addSheet(String name, List<String> headers) {
      final sheet = workbook[name];
      // Row 0: description
      sheet.appendRow([excel.TextCellValue('أدخل البيانات من الصف الثالث فما فوق')]);
      // Row 1: headers
      sheet.appendRow(headers.map((h) => excel.TextCellValue(h)).toList());
      // Row 2+: sample data row (empty)
      sheet.appendRow(headers.map((_) => excel.TextCellValue('')).toList());
    }

    addSheet('الفئات', [
      'ID',
      'businessId',
      'الاسم (عربي)',
      'الاسم (إنجليزي)',
      'أيقونة',
      'لون الخلفية',
      'ID الفئة الأم',
      'تاريخ الإنشاء',
    ]);

    addSheet('العلامات التجارية', [
      'ID',
      'businessId',
      'الاسم (عربي)',
      'الاسم (إنجليزي)',
      'رابط الشعار',
    ]);

    addSheet('المنتجات', [
      'ID',
      'businessId',
      'categoryId',
      'brandId',
      'الاسم',
      'الوصف',
      'الصور (JSON)',
      'السعر الأساسي',
      'سعر التكلفة',
      'الخصم',
      'العملة',
      'متاح',
      'الكمية',
      'المتغيرات (JSON)',
      'الوسوم (JSON)',
      'منتجات ذات صلة (JSON)',
      'المواصفات (JSON)',
      'رسوم إضافية (JSON)',
      'لديه خصم',
      'مميز',
      'وصول جديد',
      'الأكثر مبيعاً',
      'الباركود',
      'SKU',
      'الوزن',
      'الأبعاد',
      'فئة الشحن',
      'الحد الأدنى للطلب',
      'الحد الأقصى للطلب',
      'رقمي',
      'بيانات SEO (JSON)',
      'التقييم',
      'تقييمات المستخدمين (JSON)',
      'العروض (JSON)',
      'تاريخ الإنشاء',
      'تاريخ التحديث',
    ]);

    workbook.delete('Sheet1');

    final bytes = workbook.save();
    if (bytes == null) return;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final fileName = 'business_import_template_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // ── Export Current Data ──────────────────────────────────────────────────

  Future<void> _exportCurrentData() async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('جاري تجهيز الملف...')));
      await ExcelExportService.exportBusinessData(context, widget.businessId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: _error),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeaderCard(),
                const SizedBox(height: 20),
                _buildActionBar(),
                const SizedBox(height: 20),
                if (_isReading) _buildReadingIndicator(),
                if (_preview != null && !_isImporting && !_importDone)
                  _buildPreviewSection(),
                if (_isImporting) _buildImportingSection(),
                if (_importDone) _buildDoneSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'استيراد البيانات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            widget.businessName,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE2E8F0)),
      ),
    );
  }

  // ── Header Card ──────────────────────────────────────────────────────────

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.table_chart_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'استيراد وتصدير بيانات المتجر',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'استيراد المنتجات والفئات والعلامات التجارية من Excel، مع تقرير مفصل قبل الحفظ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Bar ───────────────────────────────────────────────────────────

  Widget _buildActionBar() {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.upload_file_rounded,
            label: 'استيراد ملف Excel',
            subtitle: _fileName ?? 'اختر ملف .xlsx',
            color: _primary,
            onTap: _isReading ? null : _pickFile,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.download_rounded,
            label: 'تصدير البيانات الحالية',
            subtitle: 'تنزيل بيانات المتجر',
            color: _success,
            onTap: _exportCurrentData,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.file_download_outlined,
            label: 'تحميل نموذج فارغ',
            subtitle: 'Template للاستيراد',
            color: _warning,
            onTap: _downloadTemplate,
          ),
        ),
      ],
    );
  }

  // ── Reading Indicator ────────────────────────────────────────────────────

  Widget _buildReadingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(width: 16),
          Text(
            'جاري قراءة وتحليل الملف...',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Preview Section ──────────────────────────────────────────────────────

  Widget _buildPreviewSection() {
    final preview = _preview!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryRow(preview),
        const SizedBox(height: 16),
        if (preview.errors.isNotEmpty) _buildErrorsCard(preview.errors),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'العناصر المحددة: $_selectedTotal / ${preview.totalItems}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _selectAllVisible,
                icon: const Icon(Icons.select_all_rounded, size: 18),
                label: const Text('تحديد الكل'),
              ),
              TextButton.icon(
                onPressed: _clearSelection,
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('إلغاء'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: _primary,
                  unselectedLabelColor: const Color(0xFF64748B),
                  indicatorColor: _primary,
                  tabs: [
                    Tab(text: 'الفئات (${preview.categories.length})'),
                    Tab(text: 'العلامات (${preview.brands.length})'),
                    Tab(text: 'المنتجات (${preview.products.length})'),
                  ],
                ),
              ),
              SizedBox(
                height: 350,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoriesPreview(preview.categories),
                    _buildBrandsPreview(preview.brands),
                    _buildProductsPreview(preview.products),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_selectedTotal > 0)
          SizedBox(
            width: double.infinity,
            child: ButtonApp(
              onPressed: _startImport,
              icon: Icons.rocket_launch_rounded,
              label: 'بدء الاستيراد ($_selectedTotal عنصر محدد)',
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(_ImportPreview preview) {
    return Row(
      children: [
        _SummaryChip(
          icon: Icons.folder_rounded,
          label: 'الفئات',
          count: preview.categories.length,
          color: _primary,
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          icon: Icons.label_rounded,
          label: 'العلامات',
          count: preview.brands.length,
          color: _warning,
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          icon: Icons.inventory_2_rounded,
          label: 'المنتجات',
          count: preview.products.length,
          color: _success,
        ),
        if (preview.errors.isNotEmpty) ...[
          const SizedBox(width: 10),
          _SummaryChip(
            icon: Icons.warning_rounded,
            label: 'أخطاء',
            count: preview.errors.length,
            color: _error,
          ),
        ],
      ],
    );
  }

  Widget _buildErrorsCard(List<String> errors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: _error, size: 18),
              const SizedBox(width: 8),
              Text(
                'تحذيرات (${errors.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...errors.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $e',
                style: const TextStyle(fontSize: 12, color: _error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesPreview(List<CategoryModel> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد فئات في الملف',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final cat = categories[i];
        final selected = _selectedCategoryIds.contains(cat.id);
        return ListTile(
          leading: Checkbox(
            value: selected,
            onChanged: (_) => _toggleCategory(cat.id),
            activeColor: _primary,
          ),
          title: Text(
            cat.label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            cat.id,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (_categoryStatus[cat.id] == 'موجود'
                      ? _success
                      : _primary)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _categoryStatus[cat.id] ?? 'جديد',
              style: TextStyle(
                fontSize: 11,
                color: _categoryStatus[cat.id] == 'موجود' ? _success : _primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandsPreview(List<BrandModel> brands) {
    if (brands.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد علامات تجارية في الملف',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: brands.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final brand = brands[i];
        final selected = _selectedBrandIds.contains(brand.id);
        return ListTile(
          leading: Checkbox(
            value: selected,
            onChanged: (_) => _toggleBrand(brand.id),
            activeColor: _warning,
          ),
          title: Text(
            brand.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            brand.id,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (_brandStatus[brand.id] == 'موجود'
                      ? _success
                      : _warning)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _brandStatus[brand.id] ?? 'جديد',
              style: TextStyle(
                fontSize: 11,
                color: _brandStatus[brand.id] == 'موجود' ? _success : _warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsPreview(List<ProductModel> products) {
    if (products.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد منتجات في الملف',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final p = products[i];
        final selected = _selectedProductIds.contains(p.id);
        return ListTile(
          leading: Checkbox(
            value: selected,
            onChanged: (_) => _toggleProduct(p.id),
            activeColor: _success,
          ),
          title: Text(
            p.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${p.categoryId} • ${p.basePrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (_productStatus[p.id] == 'موجود'
                          ? _success
                          : _primary)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _productStatus[p.id] ?? 'جديد',
                  style: TextStyle(
                    fontSize: 11,
                    color: _productStatus[p.id] == 'موجود' ? _success : _primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: p.isAvailable
                      ? _success.withOpacity(0.1)
                      : _error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.isAvailable ? 'متاح' : 'غير متاح',
                  style: TextStyle(
                    fontSize: 11,
                    color: p.isAvailable ? _success : _error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Importing Section ────────────────────────────────────────────────────

  Widget _buildImportingSection() {
    final total = _progressItems.length;
    final progress = total > 0 ? _completedCount / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: 12),
              Text(
                'جاري الاستيراد... $_completedCount / $total',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation(_primary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _progressItems.length,
              itemBuilder: (context, i) {
                final item = _progressItems[i];
                final isActive = !item.done && i == _completedCount;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: item.done
                            ? Icon(
                                item.hasError
                                    ? Icons.error_rounded
                                    : Icons.check_circle_rounded,
                                size: 20,
                                color: item.hasError ? _error : _success,
                              )
                            : isActive
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: item.done
                                ? (item.hasError ? _error : _success)
                                : isActive
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF94A3B8),
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Done Section ─────────────────────────────────────────────────────────

  Widget _buildDoneSection() {
    final errorsCount = _progressItems.where((p) => p.hasError).length;
    final successCount = _progressItems.length - errorsCount;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _success, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'اكتمل الاستيراد!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$successCount عنصر تم حفظه بنجاح${errorsCount > 0 ? ' • $errorsCount عنصر به خطأ' : ''}',
            style: TextStyle(
              color: errorsCount > 0 ? _warning : const Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonApp(
                onPressed: () {
                  setState(() {
                    _preview = null;
                    _importDone = false;
                    _fileName = null;
                    _progressItems = [];
                    _completedCount = 0;
                  });
                },
                icon: Icons.refresh_rounded,
                label: 'استيراد ملف آخر',
              ),
              const SizedBox(width: 12),
              ButtonApp(
                onPressed: () => Navigator.pop(context),
                icon: Icons.arrow_back_ios_rounded,
                label: 'العودة للمتجر',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────────

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _hovered && widget.onTap != null
                ? widget.color.withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered && widget.onTap != null
                  ? widget.color.withOpacity(0.4)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_hovered ? 0.12 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: color.withOpacity(0.7)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
