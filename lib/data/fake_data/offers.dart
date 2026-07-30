import '../models/offer_model.dart';
import '../models/localized_string.dart';
import 'company.dart';

final List<OfferModel> _baseFakeOffers = [
  // ════════════════════════════════════════════════════════
  //              PRODUCT GIFT (اشترِ واحداً واحصل على هدية)
  // ════════════════════════════════════════════════════════
  OfferModel(
    id: 'off_gift_001',
    name: const LocalizedString(
      ar: 'اشترِ ١ واحصل على ١ مجاناً - قمصان',
      en: 'Buy 1 Get 1 Free - T-Shirts',
    ),
    type: 'product_gift',
    productId: 'shirt_001',
    giftProductId: 'shirt_002',
    giftName: 'POLO WITH CONTRAST TRIMS',
    giftImageUrl:
        'https://images.unsplash.com/photo-1625910513413-5fc4e5e6727e?q=80&w=1974',
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    endDate: DateTime.now().add(const Duration(days: 5)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=1780',
    description: const LocalizedString(
      ar: 'اشترِ قميصاً واحصل على بولو مجاناً! عرض لفترة محدودة.',
      en: 'Buy a Graphic T-Shirt and get a Polo completely free! Limited time offer.',
    ),
  ),
  OfferModel(
    id: 'off_gift_002',
    name: const LocalizedString(
      ar: 'اشترِ حذاء واحصل على جوارب مجاناً',
      en: 'Buy Shoes Get Socks Free',
    ),
    type: 'product_gift',
    productId: 'shoes_001',
    giftProductId: 'sport_005',
    giftName: 'SPORTS SOCKS PACK',
    giftImageUrl:
        'https://images.unsplash.com/photo-1582966772680-860e372bb558?q=80&w=1974',
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    endDate: DateTime.now().add(const Duration(days: 10)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1770',
    description: const LocalizedString(
      ar: 'اشترِ أي حذاء رياضي واحصل على حزمة جوارب رياضية مجاناً.',
      en: 'Purchase any running sneakers and receive a pack of sports socks absolutely free.',
    ),
  ),
  OfferModel(
    id: 'off_gift_003',
    name: const LocalizedString(
      ar: 'اشترِ ساعة واحصل على حزام مجاناً',
      en: 'Buy Watch Get Belt Free',
    ),
    type: 'product_gift',
    productId: 'acc_003',
    giftProductId: 'acc_006',
    giftName: 'LEATHER BELT',
    giftImageUrl:
        'https://images.unsplash.com/photo-1624222247344-550fb60583dc?q=80&w=1974',
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    endDate: DateTime.now().add(const Duration(days: 7)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1999',
    description: const LocalizedString(
      ar: 'اشترِ ساعتنا واحصل على حزام جلدي فاخر كهدية.',
      en: 'Buy our minimalist analog watch and get a premium leather belt as a gift.',
    ),
  ),

  // ════════════════════════════════════════════════════════
  //              BUNDLE OFFERS (عروض المجموعات)
  // ════════════════════════════════════════════════════════
  OfferModel(
    id: 'off_bundle_001',
    name: const LocalizedString(
      ar: 'باقة الصيف الأساسية',
      en: 'Summer Essentials Bundle',
    ),
    type: 'bundle',
    productIds: ['1', '2', '3', '4'],
    price: 95,
    startDate: DateTime.now().subtract(const Duration(days: 10)),
    endDate: DateTime.now().add(const Duration(days: 20)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1491553895911-0055eca6402d?q=80&w=1780',
    description: const LocalizedString(
      ar: 'مجموعة كاملة من الأحذية الرياضية، الشورتات، وقميص.',
      en: 'Complete set of running shoes, shorts, and a breathable t-shirt.',
    ),
  ),
  OfferModel(
    id: 'off_bundle_002',
    name: const LocalizedString(
      ar: 'باقة العمل من المنزل',
      en: 'Work From Home Bundle',
    ),
    type: 'bundle',
    productIds: ['1', '2', '3', '4'],
    price: 120,
    startDate: DateTime.now().subtract(const Duration(days: 3)),
    endDate: DateTime.now().add(const Duration(days: 15)),
    isActive: true,
    description: const LocalizedString(
      ar: 'عزز إنتاجيتك: سماعات لاسلكية + مصباح مكتب + دفتر بسعر 120 دولار.',
      en: 'Boost your productivity: Wireless headphones + LED desk lamp + hardcover notebook for \$120.',
    ),
  ),
  OfferModel(
    id: 'off_bundle_003',
    name: const LocalizedString(
      ar: 'باقة اللياقة البدنية',
      en: 'Fitness Starter Pack',
    ),
    type: 'bundle',
    productIds: ['1', '2', '3', '4'],
    price: 75,
    startDate: DateTime.now().subtract(const Duration(days: 7)),
    endDate: DateTime.now().add(const Duration(days: 14)),
    isActive: true,
    description: const LocalizedString(
      ar: 'ابدأ رحلة لياقتك: سجادة يوجا + أحزمة مقاومة + زجاجة ماء + منشفة بسعر 75 دولار.',
      en: 'Start your fitness journey: Yoga mat + resistance bands + water bottle + gym towel for \$75.',
    ),
  ),
  OfferModel(
    id: 'off_bundle_004',
    name: const LocalizedString(
      ar: 'باقة المطبخ الفاخر',
      en: 'Gourmet Kitchen Bundle',
    ),
    type: 'bundle',
    productIds: ['1', '2', '3', '4'],
    price: 85,
    startDate: DateTime.now().subtract(const Duration(days: 4)),
    endDate: DateTime.now().add(const Duration(days: 12)),
    isActive: true,
    description: const LocalizedString(
      ar: 'ارتقِ بطبخك: لوح تقطيع + أوعية زجاجية + عسل + زيت زيتون بسعر 85 دولار.',
      en: 'Elevate your cooking: Bamboo cutting board + glass containers + honey + olive oil for \$85.',
    ),
  ),
  OfferModel(
    id: 'off_bundle_005',
    name: const LocalizedString(
      ar: 'باقة العناية الذاتية',
      en: 'Self-Care Sunday Bundle',
    ),
    type: 'bundle',
    productIds: ['1', '2', '3', '4'],
    price: 110,
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    endDate: DateTime.now().add(const Duration(days: 8)),
    isActive: true,
    description: const LocalizedString(
      ar: 'دلل نفسك: سيروم للوجه + لوشن للجسم + شموع معطرة + ساعة بسعر 110 دولار.',
      en: 'Treat yourself: Face serum + body lotion + scented candles + watch for \$110.',
    ),
  ),

  // ════════════════════════════════════════════════════════
  //              PERCENTAGE DISCOUNT (خصم نسبة مئوية)
  // ════════════════════════════════════════════════════════
  OfferModel(
    id: 'off_discount_001',
    name: const LocalizedString(
      ar: 'عرض سريع - خصم 50%',
      en: 'Flash Sale - 50% Off',
    ),
    type: 'percentage_discount',
    productIds: ['1', '2', '3', '4'],
    discountPercent: 50,
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    endDate: DateTime.now().add(const Duration(days: 2)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1580828369019-2238b6d7c865?q=80&w=1772',
    description: const LocalizedString(
      ar: 'تخفيضات نهائية! خصم حتى 70٪ على جميع العناصر الصيفية.',
      en: 'Final markdown! Up to 70% off on all summer items.',
    ),
  ),
  OfferModel(
    id: 'off_discount_002',
    name: const LocalizedString(
      ar: 'عرض عطلة نهاية الأسبوع - خصم 30%',
      en: 'Weekend Special - 30% Off',
    ),
    type: 'percentage_discount',
    productIds: ['1', '2', '3', '4'],
    discountPercent: 30,
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    endDate: DateTime.now().add(const Duration(days: 3)),
    isActive: true,
    description: const LocalizedString(
      ar: 'عرض خاص لعطلة نهاية الأسبوع! خصم 30٪ على أحذية مختارة.',
      en: 'Weekend special! 30% off selected footwear. Step into savings!',
    ),
  ),
  OfferModel(
    id: 'off_pct_003',
    name: const LocalizedString(
      ar: 'أسبوع الجمال - خصم 25% على العناية بالبشرة',
      en: 'Beauty Week - 25% Off Skincare',
    ),
    type: 'percentage_discount',
    productIds: ['1', '2', '3', '4'],
    discountPercent: 25,
    startDate: DateTime.now().subtract(const Duration(days: 3)),
    endDate: DateTime.now().add(const Duration(days: 11)),
    isActive: true,
    description: const LocalizedString(
      ar: 'تألقي بخصم 25٪ على جميع منتجات العناية بالبشرة.',
      en: 'Glow up with 25% off all skincare products. Your skin deserves it!',
    ),
  ),
  OfferModel(
    id: 'off_pct_004',
    name: const LocalizedString(
      ar: 'العودة للمدارس - خصم 40% على القرطاسية',
      en: 'Back to School - 40% Off Stationery',
    ),
    type: 'percentage_discount',
    productIds: ['1', '2', '3', '4'],
    discountPercent: 40,
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    endDate: DateTime.now().add(const Duration(days: 18)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=1770',
    description: const LocalizedString(
      ar: 'احصل على ملابس شتوية كاملة بجزء بسيط من السعر!',
      en: 'Get a full winter outfit for a fraction of the price! Includes jacket, sweater, and jeans.',
    ),
  ),

  // ════════════════════════════════════════════════════════
  //              FIXED AMOUNT DISCOUNT (خصم بمبلغ ثابت)
  // ════════════════════════════════════════════════════════
  OfferModel(
    id: 'off_fixed_001',
    name: const LocalizedString(
      ar: 'خصم 20 دولار للطلبات فوق 100 دولار',
      en: '\$20 Off Orders Over \$100',
    ),
    type: 'fixed_discount',
    minOrderAmount: 100,
    discountAmount: 20,
    startDate: DateTime.now().subtract(const Duration(days: 4)),
    endDate: DateTime.now().add(const Duration(days: 10)),
    isActive: true,
    description: const LocalizedString(
      ar: 'أنفق 100 دولار أو أكثر واحصل على خصم 20 دولار. بدون الحاجة لكود!',
      en: 'Spend \$100 or more and get \$20 off your entire order. No code needed!',
    ),
  ),
  OfferModel(
    id: 'off_fixed_002',
    name: const LocalizedString(
      ar: 'خصم 10 دولار على قسم المنزل',
      en: '\$10 Off Home & Living',
    ),
    type: 'fixed_discount',
    productIds: ['1', '2', '3', '4'],
    discountAmount: 10,
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    endDate: DateTime.now().add(const Duration(days: 9)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1607083206968-13611e3d76ba?q=80&w=1790',
    description: const LocalizedString(
      ar: 'خصم هائل على جميع السترات الشتوية بمناسبة الربيع.',
      en: 'Massive discount on all winter jackets as we prepare for spring.',
    ),
  ),

  // ════════════════════════════════════════════════════════
  //              FREE SHIPPING (شحن مجاني)
  // ════════════════════════════════════════════════════════
  OfferModel(
    id: 'off_ship_001',
    name: const LocalizedString(
      ar: 'شحن مجاني لجميع الطلبات',
      en: 'Free Shipping on All Orders',
    ),
    type: 'free_shipping',
    startDate: DateTime.now().subtract(const Duration(days: 6)),
    endDate: DateTime.now().add(const Duration(days: 8)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?q=80&w=1770',
    description: const LocalizedString(
      ar: 'استمتع بتوصيل مجاني لجميع الطلبات أكثر من 150 دولار.',
      en: 'Enjoy free delivery on all orders over 150 dollars.',
    ),
  ),
  OfferModel(
    id: 'off_ship_002',
    name: const LocalizedString(
      ar: 'شحن سريع مجاني فوق 75 دولار',
      en: 'Free Express Shipping Over \$75',
    ),
    type: 'free_shipping',
    minOrderAmount: 75,
    startDate: DateTime.now().subtract(const Duration(days: 3)),
    endDate: DateTime.now().add(const Duration(days: 12)),
    isActive: true,
    description: const LocalizedString(
      ar: 'الطلبات أكثر من 75 دولار مؤهلة للشحن السريع المجاني.',
      en: 'Orders over \$75 qualify for free express shipping. Get it fast, get it free!',
    ),
  ),

  // ════════════════════════════════════════════════════════
  //              COUPON CODE (كوبونات)
  // ════════════════════════════════════════════════════════
  OfferModel(
    id: 'off_coupon_001',
    name: const LocalizedString(
      ar: 'كوبون الترحيب - خصم 15%',
      en: 'Welcome Coupon - 15% Off',
    ),
    type: 'coupon',
    couponCode: 'WELCOME15',
    discountPercent: 15,
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now().add(const Duration(days: 30)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?q=80&w=1770',
    description: const LocalizedString(
      ar: 'استخدم الكود WELCOME20 للحصول على خصم 20% على طلبك الأول.',
      en: 'Use code WELCOME20 to get 20% off your entire first order.',
    ),
  ),
  OfferModel(
    id: 'off_coupon_001',
    name: const LocalizedString(
      ar: 'العودة للمدارس - خصم 40%',
      en: 'Back to School - 40% Off',
    ),
    type: 'coupon',
    couponCode: 'SCHOOL40',
    discountPercent: 40,
    productIds: ['1', '2', '3', '4'],
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    endDate: DateTime.now().add(const Duration(days: 20)),
    isActive: true,
    description: const LocalizedString(
      ar: 'حصري لأعضاء VIP! استخدم VIP20 لخصم 20%.',
      en: 'Exclusive for VIP members! Use VIP20 for 20% off your entire cart.',
    ),
  ),
  OfferModel(
    id: 'off_coupon_002',
    name: const LocalizedString(
      ar: 'عضو VIP - خصم 20% على كل شيء',
      en: 'VIP Member - 20% Off Everything',
    ),
    type: 'coupon',
    couponCode: 'VIP20',
    discountPercent: 20,
    startDate: DateTime.now().subtract(const Duration(days: 10)),
    endDate: DateTime.now().add(const Duration(days: 20)),
    isActive: true,
    description: const LocalizedString(
      ar: 'حصري لأعضاء VIP! استخدم VIP20 لخصم 20%.',
      en: 'Exclusive for VIP members! Use VIP20 for 20% off your entire cart.',
    ),
  ),
  OfferModel(
    id: 'off_coupon_003',
    name: const LocalizedString(
      ar: 'عرض العطلة - خصم 30 دولار',
      en: 'Holiday Special - \$30 Off',
    ),
    type: 'coupon',
    couponCode: 'HOLIDAY30',
    discountAmount: 30,
    minOrderAmount: 120,
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    endDate: DateTime.now().add(const Duration(days: 14)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1607082349566-187342175e2f?q=80&w=1770',
    description: const LocalizedString(
      ar: 'احتفل بالعطلات مع خصم 30 دولار للمشتريات 120 دولار أو أكثر.',
      en: 'Use code SAVE15 for a flat 15 dollar discount on orders over 100.',
    ),
  ),

  // ════════════════════════════════════════════════════════
  //              BUY X GET Y (اشترِ X واحصل على Y)
  // ════════════════════════════════════════════════════════
  OfferModel(
    id: 'off_bxgy_001',
    name: const LocalizedString(
      ar: 'اشترِ 2 واحصل على 1 مجاناً - إكسسوارات',
      en: 'Buy 2 Get 1 Free - Accessories',
    ),
    type: 'buy_x_get_y',
    productIds: ['1', '2', '3', '4'],
    buyQuantity: 2,
    getQuantity: 1,
    startDate: DateTime.now().subtract(const Duration(days: 3)),
    endDate: DateTime.now().add(const Duration(days: 7)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?q=80&w=1771',
    description: const LocalizedString(
      ar: 'تخفيضات ضخمة على الأحذية الرياضية.',
      en: 'Huge sale on sports shoes from top brands.',
    ),
  ),
  OfferModel(
    id: 'off_bxgy_002',
    name: const LocalizedString(
      ar: 'اشترِ 3 واحصل على 1 مجاناً - مواد غذائية',
      en: 'Buy 3 Get 1 Free - Food Items',
    ),
    type: 'buy_x_get_y',
    productIds: ['1', '2', '3', '4'],
    buyQuantity: 3,
    getQuantity: 1,
    startDate: DateTime.now().subtract(const Duration(days: 4)),
    endDate: DateTime.now().add(const Duration(days: 9)),
    isActive: true,
    description: const LocalizedString(
      ar: 'اشترِ 3 مواد غذائية واحصل على الرابعة مجاناً.',
      en: 'Stock up your pantry! Buy 3 food items and get the 4th one free.',
    ),
  ),

  // ════════════════════════════════════════════════════════
  //              CLEARANCE (تصفية)
  // ════════════════════════════════════════════════════════
  OfferModel(
    id: 'off_clear_001',
    name: const LocalizedString(
      ar: 'تصفية - خصم حتى 70%',
      en: 'Clearance Sale - Up to 70% Off',
    ),
    type: 'clearance',
    productIds: ['1', '2', '3', '4'],
    discountPercent: 70,
    startDate: DateTime.now().subtract(const Duration(days: 8)),
    endDate: DateTime.now().add(const Duration(days: 5)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=1770',
    description: const LocalizedString(
      ar: 'تخفيضات هائلة على جميع عناصر التصفية.',
      en: 'Clearance sale! All clearance items are heavily discounted.',
    ),
  ),

  // ════════════════════════════════════════════════════════
  //              LOYALTY POINTS (نقاط الولاء)
  // ════════════════════════════════════════════════════════
  OfferModel(
    id: 'off_loyal_001',
    name: const LocalizedString(
      ar: 'عطلة النقاط المضاعفة',
      en: 'Double Points Weekend',
    ),
    type: 'loyalty_points',
    pointsMultiplier: 2,
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    endDate: DateTime.now().add(const Duration(days: 2)),
    isActive: true,
    imageUrl:
        'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1770',
    description: const LocalizedString(
      ar: 'اربح نقاط مكافأة مضاعفة على جميع المشتريات نهاية هذا الأسبوع!',
      en: 'Enjoy 50 dollars off on any purchase over 200 dollars.',
    ),
  ),

  // ════════════════════════════════════════════════════════
  //              EXPIRED / INACTIVE (منتهية / غير نشطة)
  // ════════════════════════════════════════════════════════
  OfferModel(
    id: 'off_expired_001',
    name: const LocalizedString(
      ar: 'الجمعة السوداء - خصم 60%',
      en: 'Black Friday - 60% Off',
    ),
    type: 'percentage_discount',
    discountPercent: 60,
    startDate: DateTime.now().subtract(const Duration(days: 45)),
    endDate: DateTime.now().subtract(const Duration(days: 38)),
    isActive: false,
    description: const LocalizedString(
      ar: 'أكبر تخفيضاتنا هذا العام! خصم 60% على كل شيء. (منتهي)',
      en: 'Our biggest sale of the year! 60% off everything. (Expired)',
    ),
  ),
  OfferModel(
    id: 'off_inactive_001',
    name: const LocalizedString(
      ar: 'إطلاق التشكيلة الربيعية',
      en: 'Spring Collection Launch',
    ),
    type: 'percentage_discount',
    productIds: ['1', '2', '3', '4'],
    discountPercent: 20,
    startDate: DateTime.now().add(const Duration(days: 30)),
    endDate: DateTime.now().add(const Duration(days: 45)),
    isActive: false,
    description: const LocalizedString(
      ar: 'قريباً! خصم 20% على التشكيلة الربيعية الجديدة.',
      en: 'Coming soon! 20% off the new spring collection. Mark your calendars!',
    ),
  ),
];

final List<OfferModel> fakeOffers = _baseFakeOffers.asMap().entries.map((
  entry,
) {
  final index = entry.key;
  final offer = entry.value;
  final businessId = fakeCompanies[index % fakeCompanies.length].id;

  return OfferModel(
    id: offer.id,
    businessId: businessId,
    name: offer.name,
    type: offer.type,
    productId: offer.productId,
    productIds: offer.productIds,
    price: offer.price,
    giftProductId: offer.giftProductId,
    giftName: offer.giftName,
    giftImageUrl: offer.giftImageUrl,
    startDate: offer.startDate,
    endDate: offer.endDate,
    isActive: offer.isActive,
    description: offer.description,
    imageUrl: offer.imageUrl,
    discountPercent: offer.discountPercent,
    discountAmount: offer.discountAmount,
    minOrderAmount: offer.minOrderAmount,
    couponCode: offer.couponCode,
    buyQuantity: offer.buyQuantity,
    getQuantity: offer.getQuantity,
    pointsMultiplier: offer.pointsMultiplier,
  );
}).toList();
