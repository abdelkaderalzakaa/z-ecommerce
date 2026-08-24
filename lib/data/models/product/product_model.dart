import 'package:z_ecommerce/data/models/product/product_variant.dart';
import 'package:z_ecommerce/data/models/product/discount_model.dart';
import 'package:z_ecommerce/data/models/product/product_offer_model.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';

/// Represents a product in the e-commerce store with dynamic variants.
class ProductModel {
  // 1. المعرفات والروابط
  final String id;
  final String businessId; // معرف المتجر / الشركة المالك للمنتج
  final String categoryId; // معرف القسم/التصنيف
  final String? brandId; // معرف الماركة/البراند (إن وجد)

  // 2. البيانات الأساسية
  final String name; // اسم المنتج الأساسي
  final String description; // وصف المنتج
  final String category; // اسم التصنيف للعرض المباشر
  final String? brand; // اسم البراند للعرض المباشر

  // 3. الصور والمظهر
  final List<String> images; // قائمة روابط الصور
  final String? thumbnail; // الصورة المصغرة الرئيسية

  // 5. المتغيرات والخيارات الديناميكية (Variants)
  final List<ProductVariant> variants;

  // 5.2 الخصومات المحددة للمنتج
  final List<DiscountModel> discounts;

  // 5.3 العروض والاوفرات المحددة للمنتج
  final List<ProductOfferModel> offers;

  // 6. حالة المنتج والتفضيل
  final bool isActive; // هل المنتج نشط؟
  final bool isFeatured; // هل المنتج مميز؟
  final bool isTopSelling; // هل المنتج من الأكثر مبيعاً؟
  final bool isRecommended; // هل المنتج موصى به من السوبر أدمن؟

  // 6.2 الشحن والتوصيل
  final bool isFreeShipping; // هل الشحن مجاني؟
  final double
  shippingCost; // كلفة الشحن إلى كامل الأراضي اللبنانية (إن لم يكن مجانياً)

  // 6.3 التسعير المجاني
  final bool isFreeProduct; // هل المنتج مجاني بالكامل؟

  // 7. التقييمات والمراجعات
  final List<RatedUser> ratings; // قائمة التقييمات التفصيلية
  final bool isActiveRatings; // هل مسموح عرض وإضافة التقييمات لهذا المنتج؟

  // 8. التواريخ
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.businessId,
    required this.categoryId,
    this.brandId,
    required this.name,
    required this.description,
    required this.category,
    this.brand,
    this.images = const [],
    this.thumbnail,
    this.variants = const [],
    this.discounts = const [],
    this.offers = const [],
    this.isActive = false, // جعل المنتج غير نشط بشكل افتراضي حتى يتم تسعيره
    this.isFeatured = false,
    this.isTopSelling = false,
    this.isRecommended = false,
    this.isFreeShipping = false,
    this.shippingCost = 0.0,
    this.isFreeProduct = false,
    this.isActiveRatings = true,
    this.ratings = const [],
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // 🧮 Dynamic Getters & Helpers
  // ==========================================

  bool get isEmpty => id.isEmpty;

  /// الحصول على المتغير الافتراضي
  ProductVariant get defaultVariant {
    if (variants.isEmpty) {
      return const ProductVariant(isDefault: true, price: 0.0, stock: 0);
    }
    return variants.firstWhere(
      (v) => v.isDefault,
      orElse: () => variants.first,
    );
  }

  /// إجمالي مخزون المنتج المجمع من كافة المتغيرات
  int get totalStock {
    if (variants.isEmpty) return 0;
    return variants.fold<int>(0, (sum, variant) => sum + variant.stock);
  }

  /// هل المنتج متوفر (إجمالي المخزون أكبر من 0)
  bool get isAvailable => totalStock > 0;

  /// الحصول على الخصم الفعال بناءً على الأولوية
  DiscountModel? get activeDiscount {
    final validDiscounts = discounts.where((d) => d.isValid).toList();
    if (validDiscounts.isEmpty) return null;

    // Sort by priority ASC (lower number means higher priority)
    validDiscounts.sort((a, b) => a.priority.compareTo(b.priority));
    return validDiscounts.first;
  }

  /// السعر الأساسي للمنتج بعد تطبيق الخصم (في حال عدم تحديد متغيّر)
  double get basePrice {
    final activeDisc = activeDiscount;
    if (activeDisc != null && activeDisc.isActive && activeDisc.value > 0) {
      if (activeDisc.isPercentage) {
        return defaultVariant.price * (1 - (activeDisc.value / 100));
      } else {
        return (defaultVariant.price - activeDisc.value).clamp(
          0.0,
          double.infinity,
        );
      }
    }
    return defaultVariant.price;
  }

  /// السعر الأصلي قبل الخصم
  double get originalPrice {
    return defaultVariant.price;
  }

  /// نسبة الخصم المئوية (مثل 15%) المحسوبة ديناميكياً
  int? get discountPercent {
    final activeDisc = activeDiscount;
    if (activeDisc != null && activeDisc.isActive && activeDisc.value > 0) {
      if (activeDisc.isPercentage) {
        return activeDisc.value.round();
      } else {
        final orig = defaultVariant.price;
        if (orig > 0) {
          return ((activeDisc.value / orig) * 100).round();
        }
      }
    }
    return null;
  }

  /// حساب السعر لمتغير محدد وتطبيق الخصم عليه إذا كان للمنتج خصم
  double getPriceForVariant(ProductVariant variant) {
    final activeDisc = activeDiscount;
    if (activeDisc == null || !activeDisc.isActive || activeDisc.value <= 0) {
      return variant.price;
    }

    if (activeDisc.isPercentage) {
      return variant.price * (1 - (activeDisc.value / 100));
    } else {
      return (variant.price - activeDisc.value).clamp(0.0, double.infinity);
    }
  }

  /// قائمة المتغيرات المتوفرة فقط (التي كميتها أكبر من 0)
  List<ProductVariant> get availableVariants {
    return variants.where((variant) => variant.stock > 0).toList();
  }

  /// الحصول على الصورة الرئيسية للعرض
  String get displayImage {
    if (thumbnail != null && thumbnail!.isNotEmpty) return thumbnail!;
    if (images.isNotEmpty) return images.first;
    return '';
  }

  /// هل يوجد خصم فعلي على المنتج؟
  bool get hasDiscount => discountPercent != null && discountPercent! > 0;

  /// هل المنتج صالح للعرض في واجهات الزبون؟
  /// (يجب أن يكون نشطاً، وأن يكون له سعر أكبر من 0 أو أن يكون مجانياً بالكامل)
  bool get isValidForCustomer {
    if (!isActive) return false;
    if (isFreeProduct) return true;
    if (basePrice > 0) return true;
    return false;
  }

  /// هل المنتج وصل حديثاً؟ (إذا تم إنشاؤه خلال آخر 30 يوماً)
  bool get isNewArrival {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inDays <= 30;
  }

  /// متوسط التقييمات المحسوب ديناميكياً من مصفوفة ratings
  double get rating {
    if (ratings.isEmpty) return 0.0;
    final totalSum = ratings.fold<double>(
      0.0,
      (sum, item) => sum + item.rating,
    );
    return double.parse((totalSum / ratings.length).toStringAsFixed(1));
  }

  /// إجمالي عدد التقييمات والمراجعات
  int get reviewsCount => ratings.length;

  // ==========================================
  // 🔄 Serialization (fromMap & toMap)
  // ==========================================

  factory ProductModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ProductModel(
      id: docId ?? map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      brandId: map['brandId'],
      isFreeShipping: map['isFreeShipping'] ?? false,
      shippingCost: map['shippingCost'] != null
          ? (map['shippingCost'] as num).toDouble()
          : 0.0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'],
      images: List<String>.from(map['images'] ?? []),
      thumbnail: map['thumbnail'],
      variants:
          (map['variants'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ProductVariant.fromMap(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
      discounts:
          (map['discounts'] as List<dynamic>?)
              ?.map(
                (e) =>
                    DiscountModel.fromMap(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
      offers:
          (map['offers'] as List<dynamic>?)
              ?.map(
                (e) => ProductOfferModel.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      isActive: map['isActive'] as bool? ?? false,
      isFeatured: map['isFeatured'] as bool? ?? false,
      isTopSelling: map['isTopSelling'] as bool? ?? false,
      isRecommended: map['isRecommended'] as bool? ?? false,
      isFreeProduct: map['isFreeProduct'] as bool? ?? false,
      isActiveRatings: map['isActiveRatings'] as bool? ?? true,
      ratings:
          (map['ratings'] as List<dynamic>?)
              ?.map((r) => RatedUser.fromMap(r as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'categoryId': categoryId,
      'brandId': brandId,
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'images': images,
      'thumbnail': thumbnail,
      'variants': variants.map((v) => v.toMap()).toList(),
      'discounts': discounts.map((d) => d.toMap()).toList(),
      'offers': offers.map((o) => o.toMap()).toList(),
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isTopSelling': isTopSelling,
      'isRecommended': isRecommended,
      'isFreeShipping': isFreeShipping,
      'shippingCost': shippingCost,
      'isFreeProduct': isFreeProduct,
      'isActiveRatings': isActiveRatings,
      'ratings': ratings.map((r) => r.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      ProductModel.fromMap(json);

  // ==========================================
  // ✂️ CopyWith Function
  // ==========================================

  ProductModel copyWith({
    String? id,
    String? businessId,
    String? categoryId,
    String? brandId,
    String? name,
    String? description,
    String? category,
    String? brand,
    List<String>? images,
    String? thumbnail,
    List<ProductVariant>? variants,
    List<DiscountModel>? discounts,
    List<ProductOfferModel>? offers,
    bool? isActive,
    bool? isFeatured,
    bool? isTopSelling,
    bool? isRecommended,
    bool? isFreeShipping,
    double? shippingCost,
    bool? isFreeProduct,
    bool? isActiveRatings,
    List<RatedUser>? ratings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      images: images ?? this.images,
      thumbnail: thumbnail ?? this.thumbnail,
      variants: variants ?? this.variants,
      discounts: discounts ?? this.discounts,
      offers: offers ?? this.offers,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isTopSelling: isTopSelling ?? this.isTopSelling,
      isRecommended: isRecommended ?? this.isRecommended,
      isFreeShipping: isFreeShipping ?? this.isFreeShipping,
      shippingCost: shippingCost ?? this.shippingCost,
      isFreeProduct: isFreeProduct ?? this.isFreeProduct,
      isActiveRatings: isActiveRatings ?? this.isActiveRatings,
      ratings: ratings ?? this.ratings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// إنشاء كائن ProductModel فارغ بقيم افتراضية
  factory ProductModel.empty() {
    return const ProductModel(
      id: '',
      businessId: '',
      categoryId: '',
      name: '',
      description: '',
      category: '',
    );
  }
}
