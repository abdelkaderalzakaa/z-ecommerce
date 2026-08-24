import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/offer_provider.dart';

import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/category_model.dart';
import 'package:z_ecommerce/data/models/product/brand_model.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

class ExcelImportService {
  
  static Future<void> _saveImportedData(BuildContext context, ImportDataResult data) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (data.business != null) {
        await businessProvider.saveBusiness(data.business!);
      }
      for (var cat in data.categories) {
        await categoryProvider.addCategory(cat);
      }
      for (var brand in data.brands) {
        await brandProvider.addBrand(brand);
      }
      for (var prod in data.products) {
        await productProvider.addProduct(prod);
      }
      for (var offer in data.offers) {
        await offerProvider.addOffer(offer);
      }
    } finally {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
      }
    }
  }

  static Future<bool> _showImportConfirmationDialog(BuildContext context, ImportDataResult data) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('مراجعة بيانات الاستيراد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تم العثور على البيانات التالية في الملف:'),
                const SizedBox(height: 12),
                if (data.business != null)
                  const Text('• معلومات المتجر: موجودة', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• عدد الفئات: ${data.categories.length}'),
                Text('• عدد العلامات التجارية: ${data.brands.length}'),
                Text('• عدد المنتجات: ${data.products.length}'),
                Text('• عدد العروض: ${data.offers.length}'),
                const SizedBox(height: 20),
                const Text('هل أنت متأكد من رغبتك في استيراد وحفظ هذه البيانات في متجرك؟\n(قد يتم الكتابة فوق البيانات الحالية)', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          actions: [
            ButtonApp(
              label:'إلغاء',
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            ButtonApp(
              label :'تأكيد واستيراد',
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    ) ?? false;
  }

  static Future<void> importData(BuildContext context, String currentBusinessId) async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.xlsx';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final file = files[0];
      final reader = html.FileReader();
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري قراءة الملف...'), duration: Duration(seconds: 2)),
      );

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) async {
        final bytes = reader.result as List<int>;
        debugPrint('ExcelImportService: File read successfully. Byte length: ${bytes.length}');
        
        try {
          debugPrint('ExcelImportService: Attempting to decode Excel file...');
          var excel = Excel.decodeBytes(bytes);
          debugPrint('ExcelImportService: Excel decoded successfully. Sheets found: ${excel.tables.keys.join(', ')}');
          
          final parsedData = await _processExcelData(excel, currentBusinessId);
          debugPrint('ExcelImportService: Data parsed successfully. Business: ${parsedData.business != null}, Categories: ${parsedData.categories.length}, Brands: ${parsedData.brands.length}, Products: ${parsedData.products.length}, Offers: ${parsedData.offers.length}');
          
          if (context.mounted) {
            final shouldImport = await _showImportConfirmationDialog(context, parsedData);
            debugPrint('ExcelImportService: User confirmation: $shouldImport');
            
            if (shouldImport && context.mounted) {
              await _saveImportedData(context, parsedData);
              if (context.mounted) {
                debugPrint('ExcelImportService: Import saved successfully.');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم استيراد البيانات بنجاح!'), backgroundColor: Colors.green),
                );
              }
            }
          }
        } catch (error, stackTrace) {
          debugPrint('ExcelImportService: Critical Error during import: $error');
          debugPrint('ExcelImportService: StackTrace: $stackTrace');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('حدث خطأ أثناء الاستيراد: $error'), backgroundColor: Colors.red),
            );
          }
        }
      });
    });
  }

  static Future<ImportDataResult> _processExcelData(Excel excel, String currentBusinessId) async {
    debugPrint('ExcelImportService: Starting _processExcelData...');
    // 0. Optional Store Info (معلومات المتجر)
    BusinessModel? business;
    if (excel.tables.containsKey('معلومات المتجر')) {
      debugPrint('ExcelImportService: Processing Store Info sheet...');
      final storeSheet = excel['معلومات المتجر'];
      business = await _parseBusinessInfo(storeSheet, currentBusinessId);
    }
  
    // 1. Process Categories (الفئات)
    debugPrint('ExcelImportService: Processing Categories sheet...');
    final categorySheet = excel['الفئات'];
    final categories = await _parseCategories(categorySheet, currentBusinessId);

    // 2. Process Brands (العلامات التجارية)
    debugPrint('ExcelImportService: Processing Brands sheet...');
    final brandSheet = excel['العلامات التجارية'];
    final brands = await _parseBrands(brandSheet, currentBusinessId);

    // 3. Process Products (المنتجات)
    debugPrint('ExcelImportService: Processing Products sheet...');
    final productSheet = excel['المنتجات'];
    final products = await _parseProducts(productSheet, currentBusinessId);

    // 4. Process Offers (العروض)
    debugPrint('ExcelImportService: Processing Offers sheet...');
    final offerSheet = excel['العروض'];
    final offers = await _parseOffers(offerSheet, currentBusinessId);

    debugPrint('ExcelImportService: Finished _processExcelData.');
    return ImportDataResult(
      business: business,
      categories: categories,
      brands: brands,
      products: products,
      offers: offers,
    );
  }

  static dynamic _parseJsonStr(String? val) {
    if (val == null || val.isEmpty) return null;
    try {
      return jsonDecode(val);
    } catch (_) {
      return null;
    }
  }

  static Future<BusinessModel?> _parseBusinessInfo(Sheet? sheet, String currentBusinessId) async {
    if (sheet == null) {
      debugPrint('ExcelImportService: Store Info sheet is null.');
      return null;
    }
    // Assuming data is in row 2 (index 2)
    if (sheet.maxRows > 2) {
      final row = sheet.rows[2];
      if (row.isEmpty || row[0]?.value == null) {
        debugPrint('ExcelImportService: Store Info row 2 is empty or missing ID.');
        return null;
      }
      
      try {
        final map = {
          'id': currentBusinessId,
          'owner': _parseJsonStr(row[1]?.value?.toString()),
          'businessType': row[2]?.value?.toString(),
          'addAddress': _parseJsonStr(row[3]?.value?.toString()),
          'likes': int.tryParse(row[4]?.value?.toString() ?? '0'),
          'theme': {
            'primaryColor': row[5]?.value?.toString(),
            'secondaryColor': row[6]?.value?.toString(),
            'backgroundColor': row[7]?.value?.toString(),
            'surfaceColor': row[8]?.value?.toString(),
            'textColor': row[9]?.value?.toString(),
            'fontFamily': row[10]?.value?.toString(),
            'fontScale': double.tryParse(row[11]?.value?.toString() ?? '1.0'),
            'buttonRadius': double.tryParse(row[12]?.value?.toString() ?? '8.0'),
            'cardRadius': double.tryParse(row[13]?.value?.toString() ?? '12.0'),
            'inputRadius': double.tryParse(row[14]?.value?.toString() ?? '8.0'),
            'logoUrl': row[15]?.value?.toString(),
            'coverBannerUrl': row[16]?.value?.toString(),
          },
          'localization': {
            'name': _parseJsonStr(row[17]?.value?.toString()),
            'slogan': _parseJsonStr(row[18]?.value?.toString()),
            'description': _parseJsonStr(row[19]?.value?.toString()),
            'footerDescription': _parseJsonStr(row[20]?.value?.toString()),
            'aboutUs': _parseJsonStr(row[21]?.value?.toString()),
            'termsAndConditions': _parseJsonStr(row[22]?.value?.toString()),
            'privacyPolicy': _parseJsonStr(row[23]?.value?.toString()),
          },
          'currency': _parseJsonStr(row[24]?.value?.toString()),
          'socials': _parseJsonStr(row[25]?.value?.toString()),
          'paymentMethods': _parseJsonStr(row[26]?.value?.toString()),
          'orders': int.tryParse(row[27]?.value?.toString() ?? '0'),
          'followersUsers': _parseJsonStr(row[28]?.value?.toString()),
          'ratings': _parseJsonStr(row[29]?.value?.toString()),
          'visits': _parseJsonStr(row[30]?.value?.toString()),
          'status': row[31]?.value?.toString(),
          'createdAt': row[32]?.value?.toString(),
          'updatedAt': row[33]?.value?.toString(),
        };

        return BusinessModel.fromMap(map, currentBusinessId);
      } catch (e, st) {
        debugPrint('ExcelImportService: Error parsing business info: $e');
        debugPrint('ExcelImportService: Business info stacktrace: $st');
        return null;
      }
    } else {
      debugPrint('ExcelImportService: Store info sheet does not have enough rows (maxRows: ${sheet.maxRows}).');
    }
    return null;
  }

  static Future<List<CategoryModel>> _parseCategories(Sheet? sheet, String businessId) async {
    List<CategoryModel> categories = [];
    if (sheet == null) {
      debugPrint('ExcelImportService: Categories sheet is null.');
      return categories;
    }
    // Rows 0 and 1 are headers (based on export logic)
    for (int i = 2; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty || row[0]?.value == null) {
        debugPrint('ExcelImportService: Category row $i is empty or missing ID.');
        continue;
      }

      try {
        final idStr = row[0]?.value.toString() ?? '';
        if (idStr.isEmpty) continue;
        
        final map = {
          'id': idStr,
          'businessId': row[1]?.value?.toString(),
          'label': row[2]?.value?.toString(),
          'label_en': row[3]?.value?.toString(),
          'iconName': row[4]?.value?.toString(),
          'bgColor': row[5]?.value?.toString(),
          'parentId': row[6]?.value?.toString(),
          'createdAt': row[7]?.value?.toString(),
        };
        categories.add(CategoryModel.fromJson(map));
      } catch (e, st) {
        debugPrint('ExcelImportService: Error parsing category row $i: $e');
        debugPrint('ExcelImportService: Category stacktrace: $st');
      }
    }
    return categories;
  }

  static Future<List<BrandModel>> _parseBrands(Sheet? sheet, String businessId) async {
    List<BrandModel> brands = [];
    if (sheet == null) {
      debugPrint('ExcelImportService: Brands sheet is null.');
      return brands;
    }
    for (int i = 2; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty || row[0]?.value == null) {
        debugPrint('ExcelImportService: Brand row $i is empty or missing ID.');
        continue;
      }

      try {
        final idStr = row[0]?.value.toString() ?? '';
        if (idStr.isEmpty) continue;

        final map = {
          'id': idStr,
          'businessId': row[1]?.value?.toString(),
          'name': row[2]?.value?.toString(),
          'name_en': row[3]?.value?.toString(),
          'logo': row[4]?.value?.toString(),
        };
        brands.add(BrandModel.fromJson(map));
      } catch (e, st) {
        debugPrint('ExcelImportService: Error parsing brand row $i: $e');
        debugPrint('ExcelImportService: Brand stacktrace: $st');
      }
    }
    return brands;
  }

  static Future<List<ProductModel>> _parseProducts(Sheet? sheet, String businessId) async {
    List<ProductModel> products = [];
    if (sheet == null) {
      debugPrint('ExcelImportService: Products sheet is null.');
      return products;
    }
    for (int i = 2; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty || row[0]?.value == null) {
        debugPrint('ExcelImportService: Product row $i is empty or missing ID.');
        continue;
      }

      try {
        final idStr = row[0]?.value.toString() ?? '';
        if (idStr.isEmpty) continue;

        final variantsList = _parseJsonStr(row[13]?.value?.toString());
        final tagsList = _parseJsonStr(row[14]?.value?.toString());
        final relatedList = _parseJsonStr(row[15]?.value?.toString());
        final specsList = _parseJsonStr(row[16]?.value?.toString());
        final additionalFeesMap = _parseJsonStr(row[17]?.value?.toString());
        final seoDataMap = _parseJsonStr(row[30]?.value?.toString());
        final ratingUsersMap = _parseJsonStr(row[32]?.value?.toString());
        final offersList = _parseJsonStr(row[33]?.value?.toString());

        final map = {
          'id': idStr,
          'businessId': row[1]?.value?.toString(),
          'categoryId': row[2]?.value?.toString(),
          'brandId': row[3]?.value?.toString(),
          'name': row[4]?.value?.toString(),
          'description': row[5]?.value?.toString(),
          'images': _parseJsonStr(row[6]?.value?.toString()), // Assuming JSON array string
          'basePrice': double.tryParse(row[7]?.value?.toString() ?? '0'),
          'costPrice': double.tryParse(row[8]?.value?.toString() ?? '0'),
          'discount': double.tryParse(row[9]?.value?.toString() ?? '0'),
          'currency': row[10]?.value?.toString(),
          'isAvailable': row[11]?.value?.toString() == 'true',
          'stockQuantity': int.tryParse(row[12]?.value?.toString() ?? '0'),
          'variants': variantsList,
          'tags': tagsList,
          'relatedProductIds': relatedList,
          'specifications': specsList,
          'additionalFees': additionalFeesMap,
          'hasDiscount': row[18]?.value?.toString() == 'true',
          'isFeatured': row[19]?.value?.toString() == 'true',
          'isNewArrival': row[20]?.value?.toString() == 'true',
          'isBestSeller': row[21]?.value?.toString() == 'true',
          'barcode': row[22]?.value?.toString(),
          'sku': row[23]?.value?.toString(),
          'weight': double.tryParse(row[24]?.value?.toString() ?? '0'),
          'dimensions': row[25]?.value?.toString(),
          'shippingClass': row[26]?.value?.toString(),
          'minOrderQuantity': int.tryParse(row[27]?.value?.toString() ?? '1'),
          'maxOrderQuantity': int.tryParse(row[28]?.value?.toString() ?? '0'),
          'isDigital': row[29]?.value?.toString() == 'true',
          'seoData': seoDataMap,
          'rating': double.tryParse(row[31]?.value?.toString() ?? '0'),
          'ratings': ratingUsersMap,
          'offers': offersList,
          'createdAt': row[34]?.value?.toString(),
          'updatedAt': row[35]?.value?.toString(),
        };
        products.add(ProductModel.fromMap(map, docId: idStr));
      } catch (e, st) {
        debugPrint('ExcelImportService: Error parsing product row $i: $e');
        debugPrint('ExcelImportService: Product stacktrace: $st');
      }
    }
    return products;
  }

  static Future<List<OfferModel>> _parseOffers(Sheet? sheet, String businessId) async {
    List<OfferModel> offers = [];
    if (sheet == null) {
      debugPrint('ExcelImportService: Offers sheet is null.');
      return offers;
    }
    for (int i = 2; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty || row[0]?.value == null) {
        debugPrint('ExcelImportService: Offer row $i is empty or missing ID.');
        continue;
      }

      try {
        final idStr = row[0]?.value.toString() ?? '';
        if (idStr.isEmpty) continue;

        final map = {
          'id': idStr,
          'businessId': row[1]?.value?.toString(),
          'title': row[2]?.value?.toString(),
          'description': row[3]?.value?.toString(),
          'imageUrl': row[4]?.value?.toString(),
          'discountType': row[5]?.value?.toString(),
          'discountValue': double.tryParse(row[6]?.value?.toString() ?? '0'),
          'minPurchaseAmount': double.tryParse(row[7]?.value?.toString() ?? '0'),
          'maxDiscountAmount': double.tryParse(row[8]?.value?.toString() ?? '0'),
          'applicableProductIds': _parseJsonStr(row[9]?.value?.toString()),
          'applicableCategoryIds': _parseJsonStr(row[10]?.value?.toString()),
          'promoCode': row[11]?.value?.toString(),
          'usageLimit': int.tryParse(row[12]?.value?.toString() ?? '0'),
          'usedCount': int.tryParse(row[13]?.value?.toString() ?? '0'),
          'isActive': row[14]?.value?.toString() == 'true',
          'startDate': row[15]?.value?.toString(),
          'endDate': row[16]?.value?.toString(),
          'createdAt': row[17]?.value?.toString(),
          'updatedAt': row[18]?.value?.toString(),
          'theme': _parseJsonStr(row[19]?.value?.toString()),
        };
        offers.add(OfferModel.fromMap(map));
      } catch (e, st) {
        debugPrint('ExcelImportService: Error parsing offer row $i: $e');
        debugPrint('ExcelImportService: Offer stacktrace: $st');
      }
    }
    return offers;
  }
}

class ImportDataResult {
  final BusinessModel? business;
  final List<CategoryModel> categories;
  final List<BrandModel> brands;
  final List<ProductModel> products;
  final List<OfferModel> offers;

  ImportDataResult({
    this.business,
    this.categories = const [],
    this.brands = const [],
    this.products = const [],
    this.offers = const [],
  });
}
