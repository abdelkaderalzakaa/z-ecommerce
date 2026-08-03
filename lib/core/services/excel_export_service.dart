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
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);

    // Fetch data for the business
    final storeInfo = businessProvider.businesses.firstWhere((b) => b.id == businessId);
    final products = productProvider.allProducts.where((p) => p.businessId == businessId).toList();
    final categories = categoryProvider.categories;
    final brands = brandProvider.brands.where((b) => b.businessId == businessId).toList();
    final offers = offerProvider.storeOffers.where((o) => o.businessId == businessId).toList();

    var excel = Excel.createExcel();
    excel.rename('Sheet1', 'معلومات المتجر');
    
    // ==========================================
    // Store Info Sheet
    // ==========================================
    Sheet storeSheet = excel['معلومات المتجر'];
    storeSheet.appendRow([TextCellValue('طريقة الربط: يمثل هذا الشيت تفاصيل المتجر الأساسية والموديلات المتداخلة فيه. المفتاح الأساسي هو id.')]);
    storeSheet.appendRow([
      TextCellValue('id'), 
      TextCellValue('owner'), 
      TextCellValue('businessType'), 
      TextCellValue('addAddress'), 
      TextCellValue('likes'),
      TextCellValue('theme.primaryColor'),
      TextCellValue('theme.secondaryColor'),
      TextCellValue('theme.backgroundColor'),
      TextCellValue('theme.surfaceColor'),
      TextCellValue('theme.textColor'),
      TextCellValue('theme.fontFamily'),
      TextCellValue('theme.fontScale'),
      TextCellValue('theme.buttonRadius'),
      TextCellValue('theme.cardRadius'),
      TextCellValue('theme.inputRadius'),
      TextCellValue('theme.logoUrl'),
      TextCellValue('theme.coverBannerUrl'),
      TextCellValue('localization.name'),
      TextCellValue('localization.slogan'),
      TextCellValue('localization.description'),
      TextCellValue('localization.footerDescription'),
      TextCellValue('localization.aboutUs'),
      TextCellValue('localization.termsAndConditions'),
      TextCellValue('localization.privacyPolicy'),
      TextCellValue('currency'),
      TextCellValue('socials'),
      TextCellValue('paymentMethods'),
      TextCellValue('orders'),
      TextCellValue('followersUsers'),
      TextCellValue('ratings'),
      TextCellValue('visits'),
      TextCellValue('status'),
      TextCellValue('createdAt'),
      TextCellValue('updatedAt'),
    ]);
    
    storeSheet.appendRow([
      TextCellValue(storeInfo.id), 
      TextCellValue(_jsonEncodeSafe(storeInfo.owner)),
      TextCellValue(storeInfo.businessType.toString()),
      TextCellValue(_jsonEncodeSafe(storeInfo.addAddress)),
      TextCellValue(storeInfo.likes.toString()),
      // ThemeAdmin fields
      TextCellValue(storeInfo.theme.primaryColor),
      TextCellValue(storeInfo.theme.secondaryColor),
      TextCellValue(storeInfo.theme.backgroundColor),
      TextCellValue(storeInfo.theme.surfaceColor),
      TextCellValue(storeInfo.theme.textColor),
      TextCellValue(storeInfo.theme.fontFamily),
      TextCellValue(storeInfo.theme.fontScale.toString()),
      TextCellValue(storeInfo.theme.buttonRadius.toString()),
      TextCellValue(storeInfo.theme.cardRadius.toString()),
      TextCellValue(storeInfo.theme.inputRadius.toString()),
      TextCellValue(storeInfo.theme.logoUrl ?? ''),
      TextCellValue(storeInfo.theme.coverBannerUrl ?? ''),
      // LocalizationAdmin fields
      TextCellValue(_jsonEncodeSafe(storeInfo.localization.name)),
      TextCellValue(_jsonEncodeSafe(storeInfo.localization.slogan)),
      TextCellValue(_jsonEncodeSafe(storeInfo.localization.description)),
      TextCellValue(_jsonEncodeSafe(storeInfo.localization.footerDescription)),
      TextCellValue(_jsonEncodeSafe(storeInfo.localization.aboutUs)),
      TextCellValue(_jsonEncodeSafe(storeInfo.localization.termsAndConditions)),
      TextCellValue(_jsonEncodeSafe(storeInfo.localization.privacyPolicy)),
      // Other
      TextCellValue(_jsonEncodeSafe(storeInfo.currency)),
      TextCellValue(_jsonEncodeSafe(storeInfo.socials)),
      TextCellValue(storeInfo.paymentMethods.map((e) => e.toString()).join(', ')),
      TextCellValue(storeInfo.orders.toString()),
      TextCellValue(_jsonEncodeSafe(storeInfo.followersUsers)),
      TextCellValue(_jsonEncodeSafe(storeInfo.ratings)),
      TextCellValue(_jsonEncodeSafe(storeInfo.visits)),
      TextCellValue(storeInfo.status?.toString() ?? ''),
      TextCellValue(_formatDate(storeInfo.createdAt)),
      TextCellValue(_formatDate(storeInfo.updatedAt)),
    ]);

    // ==========================================
    // Products Sheet
    // ==========================================
    Sheet productsSheet = excel['المنتجات'];
    productsSheet.appendRow([TextCellValue('طريقة الربط: يرتبط المنتج بالمتجر عن طريق businessId وبالفئة عن طريق categoryId وبالعلامة التجارية عبر brandId.')]);
    productsSheet.appendRow([
      TextCellValue('id'), 
      TextCellValue('businessId'), 
      TextCellValue('categoryId'),
      TextCellValue('brandId'),
      TextCellValue('name'),
      TextCellValue('description'),
      TextCellValue('category'),
      TextCellValue('brand'),
      TextCellValue('images'),
      TextCellValue('thumbnail'),
      TextCellValue('originalPrice'),
      TextCellValue('discountPercent'),
      TextCellValue('variants'),
      TextCellValue('isFeatured'),
      TextCellValue('isTopSelling'),
      TextCellValue('ratings'),
      TextCellValue('createdAt'),
      TextCellValue('updatedAt'),
    ]);
    for (var p in products) {
      productsSheet.appendRow([
        TextCellValue(p.id),
        TextCellValue(p.businessId),
        TextCellValue(p.categoryId),
        TextCellValue(p.brandId ?? ''),
        TextCellValue(p.name),
        TextCellValue(p.description),
        TextCellValue(p.category),
        TextCellValue(p.brand ?? ''),
        TextCellValue(p.images.join(', ')),
        TextCellValue(p.thumbnail ?? ''),
        TextCellValue(p.originalPrice.toString()),
        TextCellValue(p.discountPercent?.toString() ?? ''),
        TextCellValue(_jsonEncodeSafe(p.variants)),
        TextCellValue(p.isFeatured.toString()),
        TextCellValue(p.isTopSelling.toString()),
        TextCellValue(_jsonEncodeSafe(p.ratings)),
        TextCellValue(_formatDate(p.createdAt)),
        TextCellValue(_formatDate(p.updatedAt)),
      ]);
    }

    // ==========================================
    // Categories Sheet
    // ==========================================
    Sheet categoriesSheet = excel['الفئات'];
    categoriesSheet.appendRow([TextCellValue('طريقة الربط: الفئات تعتبر عامة أو ترتبط بالمتجر. ترتبط بالمنتجات كـ categoryId.')]);
    categoriesSheet.appendRow([
      TextCellValue('id'), 
      TextCellValue('businessId'),
      TextCellValue('label'), 
      TextCellValue('bgColor'),
      TextCellValue('icon')
    ]);
    for (var c in categories) {
      categoriesSheet.appendRow([
        TextCellValue(c.id),
        TextCellValue(c.businessId ?? ''),
        TextCellValue(c.label),
        TextCellValue(c.bgColor.value.toString()),
        TextCellValue(c.icon?.codePoint.toString() ?? ''),
      ]);
    }

    // ==========================================
    // Brands Sheet
    // ==========================================
    Sheet brandsSheet = excel['العلامات التجارية'];
    brandsSheet.appendRow([TextCellValue('طريقة الربط: ترتبط العلامة بالمتجر عبر businessId. والمنتجات ترتبط بها عبر brandId.')]);
    brandsSheet.appendRow([
      TextCellValue('id'), 
      TextCellValue('businessId'), 
      TextCellValue('name'), 
      TextCellValue('logoUrl'),
      TextCellValue('description')
    ]);
    for (var b in brands) {
      brandsSheet.appendRow([
        TextCellValue(b.id),
        TextCellValue(b.businessId ?? ''),
        TextCellValue(b.name),
        TextCellValue(b.logoUrl ?? ''),
        TextCellValue(b.description ?? ''),
      ]);
    }

    // ==========================================
    // Offers Sheet
    // ==========================================
    Sheet offersSheet = excel['العروض'];
    offersSheet.appendRow([TextCellValue('طريقة الربط: ترتبط بالمتجر عبر businessId و المنتجات عبر productId او productIds.')]);
    offersSheet.appendRow([
      TextCellValue('id'), 
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
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = 'store_data_$businessId.xlsx';
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
