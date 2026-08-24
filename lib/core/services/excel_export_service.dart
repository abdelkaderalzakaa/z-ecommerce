import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/offer_provider.dart';

class ExcelExportService {
  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    return date.toIso8601String();
  }

  static String _jsonEncodeSafe(dynamic data) {
    if (data == null) return '';
    try {
      if (data is List) {
        return jsonEncode(data.map((e) {
          try {
            return (e as dynamic).toMap();
          } catch (_) {
            try {
              return (e as dynamic).toJson();
            } catch (_) {
              return e.toString();
            }
          }
        }).toList());
      }
      try {
        return jsonEncode((data as dynamic).toMap());
      } catch (_) {
        try {
          return jsonEncode((data as dynamic).toJson());
        } catch (_) {
          return data.toString();
        }
      }
    } catch (e) {
      return data.toString();
    }
  }

  static Future<void> exportBusinessData(BuildContext context, String businessId) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);

    // Fetch data for the business
    final products = productProvider.allProducts.where((p) => p.businessId == businessId).toList();
    final categories = categoryProvider.categories;
    final brands = brandProvider.brands.where((b) => b.businessId == businessId).toList();
    final offers = offerProvider.storeOffers.where((o) => o.businessId == businessId).toList();

    var excel = Excel.createExcel();
    excel.rename('Sheet1', 'الفئات');
    
    // ==========================================
    // Categories Sheet (الفئات)
    // ==========================================
    Sheet categoriesSheet = excel['الفئات'];
    categoriesSheet.appendRow([TextCellValue('طريقة الربط: الفئات تعتبر عامة أو ترتبط بالمتجر. ترتبط بالمنتجات كـ categoryId.')]);
    categoriesSheet.appendRow([
      TextCellValue('ID'), 
      TextCellValue('businessId'),
      TextCellValue('الاسم (عربي)'), 
      TextCellValue('الاسم (إنجليزي)'),
      TextCellValue('أيقونة'),
      TextCellValue('لون الخلفية'),
      TextCellValue('ID الفئة الأم'),
      TextCellValue('تاريخ الإنشاء'),
    ]);
    for (var c in categories) {
      categoriesSheet.appendRow([
        TextCellValue(c.id),
        TextCellValue(c.businessIds.join(', ')),
        TextCellValue(c.label),
        TextCellValue(''),
        TextCellValue(c.icon?.codePoint.toString() ?? ''),
        TextCellValue(c.bgColor.value.toString()),
        TextCellValue(''),
        TextCellValue(''),
      ]);
    }

    // ==========================================
    // Brands Sheet (العلامات التجارية)
    // ==========================================
    Sheet brandsSheet = excel['العلامات التجارية'];
    brandsSheet.appendRow([TextCellValue('طريقة الربط: ترتبط العلامة بالمتجر عبر businessId. والمنتجات ترتبط بها عبر brandId.')]);
    brandsSheet.appendRow([
      TextCellValue('ID'), 
      TextCellValue('businessId'), 
      TextCellValue('الاسم (عربي)'), 
      TextCellValue('الاسم (إنجليزي)'),
      TextCellValue('رابط الشعار'),
    ]);
    for (var b in brands) {
      brandsSheet.appendRow([
        TextCellValue(b.id),
        TextCellValue(b.businessIds.join(', ')),
        TextCellValue(b.name),
        TextCellValue(''),
        TextCellValue(b.logoUrl ?? ''),
      ]);
    }

    // ==========================================
    // Products Sheet (المنتجات)
    // ==========================================
    Sheet productsSheet = excel['المنتجات'];
    productsSheet.appendRow([TextCellValue('طريقة الربط: يرتبط المنتج بالمتجر عن طريق businessId وبالفئة عن طريق categoryId وبالعلامة التجارية عبر brandId.')]);
    productsSheet.appendRow([
      TextCellValue('ID'), 
      TextCellValue('businessId'), 
      TextCellValue('categoryId'),
      TextCellValue('brandId'),
      TextCellValue('الاسم'),
      TextCellValue('الوصف'),
      TextCellValue('الصور (JSON)'),
      TextCellValue('السعر الأساسي'),
      TextCellValue('سعر التكلفة'),
      TextCellValue('الخصم'),
      TextCellValue('العملة'),
      TextCellValue('متاح'),
      TextCellValue('الكمية'),
      TextCellValue('المتغيرات (JSON)'),
      TextCellValue('الوسوم (JSON)'),
      TextCellValue('منتجات ذات صلة (JSON)'),
      TextCellValue('المواصفات (JSON)'),
      TextCellValue('رسوم إضافية (JSON)'),
      TextCellValue('لديه خصم'),
      TextCellValue('مميز'),
      TextCellValue('وصول جديد'),
      TextCellValue('الأكثر مبيعاً'),
      TextCellValue('الباركود'),
      TextCellValue('SKU'),
      TextCellValue('الوزن'),
      TextCellValue('الأبعاد'),
      TextCellValue('فئة الشحن'),
      TextCellValue('الحد الأدنى للطلب'),
      TextCellValue('الحد الأقصى للطلب'),
      TextCellValue('رقمي'),
      TextCellValue('بيانات SEO (JSON)'),
      TextCellValue('التقييم'),
      TextCellValue('تقييمات المستخدمين (JSON)'),
      TextCellValue('العروض (JSON)'),
      TextCellValue('تاريخ الإنشاء'),
      TextCellValue('تاريخ التحديث'),
    ]);
    for (var p in products) {
      productsSheet.appendRow([
        TextCellValue(p.id),
        TextCellValue(p.businessId),
        TextCellValue(p.categoryId),
        TextCellValue(p.brandId ?? ''),
        TextCellValue(p.name),
        TextCellValue(p.description),
        TextCellValue(_jsonEncodeSafe(p.images)),
        TextCellValue(p.basePrice.toString()),
        TextCellValue((p.defaultVariant.originalPrice ?? p.defaultVariant.price).toString()),
        TextCellValue((p.discountPercent ?? 0).toString()),
        TextCellValue('SAR'),
        TextCellValue(p.isAvailable.toString()),
        TextCellValue(p.totalStock.toString()),
        TextCellValue(_jsonEncodeSafe(p.variants)),
        TextCellValue('[]'),
        TextCellValue('[]'),
        TextCellValue('{}'),
        TextCellValue('{}'),
        TextCellValue((p.activeDiscount != null).toString()),
        TextCellValue(p.isFeatured.toString()),
        TextCellValue(p.isNewArrival.toString()),
        TextCellValue(p.isTopSelling.toString()),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('0'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('1'),
        TextCellValue('0'),
        TextCellValue('false'),
        TextCellValue('{}'),
        TextCellValue(p.rating.toString()),
        TextCellValue(_jsonEncodeSafe(p.ratings)),
        TextCellValue(_jsonEncodeSafe(p.offers)),
        TextCellValue(_formatDate(p.createdAt)),
        TextCellValue(_formatDate(p.updatedAt)),
      ]);
    }

    // ==========================================
    // Offers Sheet (العروض)
    // ==========================================
    Sheet offersSheet = excel['العروض'];
    offersSheet.appendRow([TextCellValue('طريقة الربط: ترتبط بالمتجر عبر businessId و المنتجات عبر productId او productIds.')]);
    offersSheet.appendRow([
      TextCellValue('ID'), 
      TextCellValue('businessId'), 
      TextCellValue('name'), 
      TextCellValue('description'), 
      TextCellValue('type'), 
      TextCellValue('productId'), 
      TextCellValue('productIds'), 
      TextCellValue('price'), 
      TextCellValue('giftProductId'), 
      TextCellValue('giftName'), 
      TextCellValue('giftImageUrl'), 
      TextCellValue('startDate'), 
      TextCellValue('endDate'), 
      TextCellValue('isActive'), 
      TextCellValue('imageUrl'), 
      TextCellValue('discountPercent'), 
      TextCellValue('discountAmount'), 
      TextCellValue('minOrderAmount'), 
      TextCellValue('couponCode'), 
      TextCellValue('buyQuantity'), 
      TextCellValue('getQuantity'), 
      TextCellValue('pointsMultiplier'),
    ]);
    for (var o in offers) {
      offersSheet.appendRow([
        TextCellValue(o.id),
        TextCellValue(o.businessId),
        TextCellValue(_jsonEncodeSafe(o.name)),
        TextCellValue(_jsonEncodeSafe(o.description)),
        TextCellValue(o.type),
        TextCellValue(o.productId ?? ''),
        TextCellValue(o.productIds?.join(', ') ?? ''),
        TextCellValue(o.price?.toString() ?? ''),
        TextCellValue(o.giftProductId ?? ''),
        TextCellValue(o.giftName ?? ''),
        TextCellValue(o.giftImageUrl ?? ''),
        TextCellValue(_formatDate(o.startDate)),
        TextCellValue(_formatDate(o.endDate)),
        TextCellValue(o.isActive.toString()),
        TextCellValue(o.imageUrl ?? ''),
        TextCellValue(o.discountPercent?.toString() ?? ''),
        TextCellValue(o.discountAmount?.toString() ?? ''),
        TextCellValue(o.minOrderAmount?.toString() ?? ''),
        TextCellValue(o.couponCode ?? ''),
        TextCellValue(o.buyQuantity?.toString() ?? ''),
        TextCellValue(o.getQuantity?.toString() ?? ''),
        TextCellValue(o.pointsMultiplier?.toString() ?? ''),
      ]);
    }

    debugPrint('ExcelExportService: Starting export for business ID: $businessId');
    try {
      // Trigger file download
      debugPrint('ExcelExportService: Encoding excel file...');
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        debugPrint('ExcelExportService: Triggering file download...');
        final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final fileName = 'store_data_${businessId}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = fileName;
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        debugPrint('ExcelExportService: File download triggered successfully.');
      } else {
        debugPrint('ExcelExportService: Error encoding file (fileBytes is null).');
      }
    } catch (e, st) {
      debugPrint('ExcelExportService: Error during export: $e');
      debugPrint('ExcelExportService: Stacktrace: $st');
    }
  }
}
