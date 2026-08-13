import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

void main() {
  final random = Random();
  String getRandomDate() {
    final daysToSubtract = random.nextInt(30);
    final date = DateTime(2026, 8, 1).subtract(Duration(days: daysToSubtract));
    return '${date.toIso8601String()}Z';
  }

  final business = {
    'id': 'cmp_99344235',
    'owner': {
      'id': 'HPjG3vv2r8eJ3UAtOI0bSxgZjZp1',
      'name': 'usertestbuisness',
      'email': 'usertestbuisness@gmail.com',
      'role': 'businessOwner',
      'businessId': 'cmp_99344235',
      'phoneNumber': '+9647701234567',
      'avatarUrl': 'https://example.com/avatar.png',
      'createdAt': '2026-08-01T18:40:36.774Z',
      'isActive': true
    },
    'businessType': 'retailStore',
    'addAddress': [{
      'id': 'addr_1',
      'title': 'الرئيسي',
      'city': {'ar': 'بغداد', 'en': 'Baghdad'},
      'street': 'شارع الرشيد',
      'building': '12',
      'phone': '+9647701234567',
      'isDefault': true
    }],
    'likes': 245,
    'theme': {
      'primaryColor': '#0D47A1',
      'secondaryColor': '#FF6F00',
      'backgroundColor': '#F5F5F5',
      'surfaceColor': '#FFFFFF',
      'textColor': '#212121',
      'fontFamily': 'Cairo',
      'fontScale': 1,
      'buttonRadius': 12,
      'cardRadius': 16,
      'inputRadius': 10,
      'logoUrl': 'https://example.com/logo.png',
      'coverBannerUrl': 'https://example.com/banner.png'
    },
    'localization': {
      'name': {'ar': 'متجر الأناقة', 'en': 'Elegance Store'},
      'slogan': {'ar': 'أناقتك تبدأ من هنا', 'en': 'Your elegance starts here'},
      'description': {'ar': 'متجر متخصص في المنتجات الفاخرة والإلكترونيات والأزياء', 'en': 'Specialized in luxury products, electronics and fashion'},
      'footerDescription': {'ar': 'شكراً لزيارتكم متجرنا', 'en': 'Thank you for visiting our store'},
      'aboutUs': {'ar': 'نحن متجر رائد في تقديم أفضل المنتجات بأسعار تنافسية', 'en': 'We are a leading store offering the best products at competitive prices'},
      'termsAndConditions': {'ar': 'الشروط والأحكام...', 'en': 'Terms and conditions...'},
      'privacyPolicy': {'ar': 'سياسة الخصوصية...', 'en': 'Privacy policy...'}
    },
    'currency': {
      'id': 'curr_usd',
      'code': 'USD',
      'symbol': '\$',
      'name': 'US Dollar',
      'exchangeRate': 1,
      'isPrimary': true
    },
    'socials': [
      {'platform': 'instagram', 'url': 'https://instagram.com/elegance_store'},
      {'platform': 'facebook', 'url': 'https://facebook.com/elegance_store'},
      {'platform': 'whatsapp', 'url': 'https://wa.me/9647701234567'}
    ],
    'paymentMethods': ['cash', 'card', 'wallet'],
    'orders': 128,
    'followersUsers': ['usr_1', 'usr_2', 'usr_3'],
    'ratings': [{'userId': 'usr_1', 'rating': 5, 'comment': 'ممتاز'}],
    'visits': [{'date': '2026-08-01', 'count': 150}, {'date': '2026-08-02', 'count': 200}],
    'status': 'Active',
    'createdAt': '2026-08-01T18:49:04.241Z',
    'updatedAt': '2026-08-02T10:30:00.000Z'
  };

  final categoryNames = [
    {'ar': 'الهواتف الذكية', 'en': 'Smartphones', 'id': 'cat_phones'},
    {'ar': 'الحواسيب المحمولة', 'en': 'Laptops', 'id': 'cat_laptops'},
    {'ar': 'الساعات الذكية', 'en': 'Smartwatches', 'id': 'cat_watches'},
    {'ar': 'الإكسسوارات', 'en': 'Accessories', 'id': 'cat_acc'},
    {'ar': 'الأجهزة المنزلية', 'en': 'Home Appliances', 'id': 'cat_home'}
  ];

  List<Map<String, dynamic>> categories = [];
  for (var cat in categoryNames) {
    categories.add({
      'id': cat['id'],
      'businessId': business['id'],
      'label': cat['ar'],
      'label_en': cat['en'],
      'iconName': 'device_hub',
      'bgColor': '#FFFFFF',
      'createdAt': getRandomDate()
    });
  }

  final brandNames = [
    'Apple', 'Samsung', 'Sony', 'Dell', 'HP', 
    'Lenovo', 'Asus', 'Acer', 'Huawei', 'Xiaomi',
    'Oppo', 'Vivo', 'Nokia', 'Motorola', 'OnePlus',
    'Google', 'LG', 'Panasonic', 'Toshiba', 'Philips'
  ];

  List<Map<String, dynamic>> brands = [];
  for (int i = 0; i < brandNames.length; i++) {
    brands.add({
      'id': 'brand_\${i + 1}',
      'businessId': business['id'],
      'name': brandNames[i],
      'name_en': brandNames[i],
      'logo': 'https://example.com/brands/\${brandNames[i].toLowerCase()}.png'
    });
  }

  List<Map<String, dynamic>> products = [];
  for (int i = 0; i < 20; i++) {
    final brand = brands[random.nextInt(brands.length)];
    final cat = categories[random.nextInt(categories.length)];
    final basePrice = random.nextInt(1400) + 100;
    final hasDiscount = random.nextBool();
    final discount = hasDiscount ? random.nextInt(40) + 10 : 0;
    
    products.add({
      'id': 'prod_\${i + 1}',
      'businessId': business['id'],
      'categoryId': cat['id'],
      'brandId': brand['id'],
      'name': 'منتج \${brand["name"]} المميز \${i + 1}',
      'description': 'وصف رائع لمنتج \${brand["name"]} في فئة \${cat["label"]}',
      'images': ['https://example.com/products/prod_\${i + 1}_1.jpg', 'https://example.com/products/prod_\${i + 1}_2.jpg'],
      'basePrice': basePrice,
      'costPrice': basePrice * 0.7,
      'discount': discount,
      'currency': 'USD',
      'isAvailable': true,
      'stockQuantity': random.nextInt(90) + 10,
      'variants': [],
      'tags': ['جديد', 'مميز', brand['name']],
      'relatedProductIds': [],
      'specifications': [{'key': 'اللون', 'value': 'أسود'}, {'key': 'الضمان', 'value': 'سنة واحدة'}],
      'hasDiscount': hasDiscount,
      'isFeatured': random.nextBool(),
      'isNewArrival': random.nextBool(),
      'isBestSeller': random.nextBool(),
      'sku': 'SKU-\${1000 + i}',
      'rating': (random.nextDouble() * 1.5 + 3.5).toStringAsFixed(1),
      'createdAt': getRandomDate(),
      'updatedAt': getRandomDate()
    });
  }

  List<Map<String, dynamic>> offers = [];
  for (int i = 0; i < 20; i++) {
    final numAppProducts = random.nextInt(3) + 1;
    final appProducts = <String>[];
    for (int j = 0; j < numAppProducts; j++) {
      appProducts.add(products[random.nextInt(products.length)]['id']);
    }
    
    offers.add({
      'id': 'offer_\${i + 1}',
      'businessId': business['id'],
      'title': 'عرض التوفير الأكبر \${i + 1}',
      'description': 'خصم خاص لفترة محدودة!',
      'imageUrl': 'https://example.com/offers/off_\${i + 1}.jpg',
      'discountType': random.nextBool() ? 'percentage' : 'fixed',
      'discountValue': random.nextInt(40) + 10,
      'applicableProductIds': appProducts,
      'isActive': true,
      'startDate': getRandomDate(),
      'endDate': '${DateTime.now().add(Duration(days: random.nextInt(25) + 5)).toIso8601String()}Z',
      'createdAt': getRandomDate(),
      'updatedAt': getRandomDate()
    });
  }

  final data = {
    'business': business,
    'categories': categories,
    'brands': brands,
    'products': products,
    'offers': offers
  };

  final file = File('lib/core/services/json_data.json');
  file.writeAsStringSync(jsonEncode(data));
  if (kDebugMode) {
    print('Successfully wrote 20 mock items to lib/core/services/json_data.json');
  }
}
