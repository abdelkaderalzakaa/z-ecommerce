import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/business_provider.dart';

class RestaurantMenuItem {
  final String id;
  final String title;
  final String description;
  final String price;
  final String calories;
  final List<String> allergens;
  final String category;
  final String imageUrl;

  const RestaurantMenuItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.calories,
    required this.allergens,
    required this.category,
    required this.imageUrl,
  });
}

class RestaurantMenuPage extends StatefulWidget {
  const RestaurantMenuPage({super.key});

  @override
  State<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  int _selectedCategoryIndex = 0;
  int _orderCartCount = 0;
  int _currentPageView = 0; // 0: Cover Page, 1: Inside Dishes Page
  final int _selectedTableNumber = 12;

  final List<String> _categories = [
    'الكل',
    'الوجبات الرئيسية',
    'المشويات والستيك',
    'المقبلات والسلطات',
    'المشروبات والعصائر',
    'الحلويات الشرقية',
  ];

  final List<RestaurantMenuItem> _menuItems = const [
    RestaurantMenuItem(
      id: 'm1',
      title: 'وجبة كباب بالكرز والزعفران',
      description: 'كباب لحم غنم طازج مشوي على الفحم مع صوص الكرز وزهر الزعفران.',
      price: '\$24.99',
      calories: '680 kcal',
      allergens: ['🌾 مكسرات'],
      category: 'المشويات والستيك',
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500',
    ),
    RestaurantMenuItem(
      id: 'm2',
      title: 'برجر عالي اللذة بصوص الترافل',
      description: 'شريحة واغيو مشوية مع جبن الشيدر المعتق وصوص الترافل الأسود.',
      price: '\$18.50',
      calories: '820 kcal',
      allergens: ['🌾 جليوتين', '🥛 حليب'],
      category: 'الوجبات الرئيسية',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
    ),
    RestaurantMenuItem(
      id: 'm3',
      title: 'سلطة سيزر بصدور الدجاج المشوي',
      description: 'خس روماني طازج مع قطع دجاج مشوية، جبن بارميزان وصوص السيزر.',
      price: '\$12.99',
      calories: '340 kcal',
      allergens: ['🥛 حليب'],
      category: 'المقبلات والسلطات',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
    ),
    RestaurantMenuItem(
      id: 'm4',
      title: 'عصير كوكتيل الفواكه الاستوائي',
      description: 'مزيج طازج من المانجو الفاخر والأناناس والباكارد مع شرائح الكيوي.',
      price: '\$6.50',
      calories: '180 kcal',
      allergens: [],
      category: 'المشروبات والعصائر',
      imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500',
    ),
  ];

  void _showOrderTableModal(RestaurantMenuItem dish, Color primaryColor, Color surfaceColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dish.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(dish.imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 14),
              Text(dish.description, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7))),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('السعر: ${dish.price}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('🔥 ${dish.calories}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _orderCartCount++);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تمت إضافة ${dish.title} لطاولة رقم $_selectedTableNumber بنجاح!'),
                        backgroundColor: primaryColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.restaurant_rounded, size: 18),
                  label: const Text('طلب الوجبة للطاولة الآن'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = Provider.of<BusinessProvider>(context);
    final business = businessProvider.selectedBusiness;
    final themeInfo = business?.theme;
    final storeName = business?.localization.name.ar ?? 'مطعم وكافيه السعادة';
    final themeStyle = 'chalkboard';

    Color primaryColor = themeInfo?.primaryColorValue ?? const Color(0xFF4F46E5);
    Color bgColor = themeInfo?.backgroundColorValue ?? const Color(0xFFF9FAFB);
    Color surfaceColor = themeInfo?.surfaceColorValue ?? const Color(0xFFFFFFFF);
    Color textColor = themeInfo?.textColorValue ?? const Color(0xFF111827);
    final fontFamily = themeInfo?.fontFamily ?? 'Cairo';

    if (themeStyle == 'chalkboard') {
      bgColor = const Color(0xFF121212);
      surfaceColor = const Color(0xFF1A1A1E);
      textColor = const Color(0xFFF59E0B); // Amber Gold
      primaryColor = const Color(0xFFFBBF24); // Bright Gold
    } else if (themeStyle == 'italiano') {
      bgColor = const Color(0xFF1E1E22);
      surfaceColor = const Color(0xFF27272A);
      textColor = Colors.white;
      primaryColor = const Color(0xFFF97316); // Warm Amber Orange
    }

    final filteredItems = _selectedCategoryIndex == 0
        ? _menuItems
        : _menuItems.where((i) => i.category == _categories[_selectedCategoryIndex]).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: primaryColor.withOpacity(0.12),
              backgroundImage: themeInfo?.logoUrl != null ? NetworkImage(themeInfo!.logoUrl!) : null,
              child: themeInfo?.logoUrl == null ? Icon(Icons.restaurant_menu_rounded, color: primaryColor, size: 18) : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(storeName, style: TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                Text('المنيو الرقمي للطاولات (Digital Menu)', style: TextStyle(fontFamily: fontFamily, fontSize: 10, color: textColor.withOpacity(0.6))),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.table_restaurant_rounded, size: 14, color: primaryColor),
                const SizedBox(width: 4),
                Text('طاولة رقم $_selectedTableNumber', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_basket_rounded, color: primaryColor),
                onPressed: () {},
              ),
              if (_orderCartCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text('$_orderCartCount', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentPageView == 0
            ? _buildFrontCoverBody(themeInfo, primaryColor, bgColor, surfaceColor, textColor, fontFamily, storeName)
            : _buildInsideDishesBody(themeInfo, primaryColor, bgColor, surfaceColor, textColor, fontFamily, filteredItems),
      ),
    );
  }

  Widget _buildInsideDishesBody(
    dynamic themeInfo,
    Color primaryColor,
    Color bgColor,
    Color surfaceColor,
    Color textColor,
    String fontFamily,
    List<RestaurantMenuItem> filteredItems,
  ) {
    return Column(
      children: [
        // Return to Front Cover Page Banner Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: primaryColor.withOpacity(0.08),
          child: Row(
            children: [
              InkWell(
                onTap: () => setState(() => _currentPageView = 0),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 16, color: primaryColor),
                    const SizedBox(width: 4),
                    Text('📖 العودة لصفحة غلاف المنيو الرئيسي', style: TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
                  ],
                ),
              ),
              const Spacer(),
              Text('صفحة 2 من 2', style: TextStyle(fontFamily: fontFamily, fontSize: 10, color: textColor.withOpacity(0.6))),
            ],
          ),
        ),

        // Banner Cover
        if (themeInfo?.coverBannerUrl != null)
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(themeInfo!.coverBannerUrl!), fit: BoxFit.cover),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
              ),
              child: Text('قائمة الطعام الفاخرة والطازجة اليوم', style: TextStyle(fontFamily: fontFamily, color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),

        // Categories Carousel
        Container(
          color: surfaceColor,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(_categories.length, (index) {
                final isSel = _selectedCategoryIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? primaryColor : primaryColor.withOpacity(0.08),
                        borderRadius: themeInfo?.buttonBorderRadius ?? BorderRadius.circular(12),
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : primaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // Meals & Dishes Container (Dynamic Grid / List / Board)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: themeInfo?.restaurantMenuLayout == 'grid'
                ? Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: filteredItems.map((dish) {
                      return InkWell(
                        onTap: () => _showOrderTableModal(dish, primaryColor, surfaceColor, textColor),
                        child: Container(
                          width: 170,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: themeInfo?.cardBorderRadius ?? BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(dish.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 10),
                              Text(dish.title, style: TextStyle(fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(height: 4),
                              Text(dish.price, style: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
                              const SizedBox(height: 6),
                              if (themeInfo?.showCaloriesBadges ?? true)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.deepOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text('🔥 ${dish.calories}', style: const TextStyle(fontSize: 10, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : themeInfo?.restaurantMenuLayout == 'board'
                    ? Column(
                        children: filteredItems.map((dish) {
                          return InkWell(
                            onTap: () => _showOrderTableModal(dish, primaryColor, surfaceColor, textColor),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: themeInfo?.cardBorderRadius ?? BorderRadius.circular(18),
                                border: Border.all(color: Colors.deepOrange.withOpacity(0.3), width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: Colors.deepOrange.withOpacity(0.05), blurRadius: 10),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(themeInfo?.cardRadius ?? 18)),
                                        child: Image.network(dish.imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(10)),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.star_rounded, size: 14, color: Colors.white),
                                              SizedBox(width: 4),
                                              Text('🌟 طبق الشيف الخاص', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(dish.title, style: TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                                              const SizedBox(height: 4),
                                              Text(dish.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: fontFamily, fontSize: 11, color: textColor.withOpacity(0.6))),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(dish.price, style: TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor)),
                                            const SizedBox(height: 6),
                                            if (themeInfo?.showCaloriesBadges ?? true)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: Colors.deepOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                                child: Text('🔥 ${dish.calories}', style: const TextStyle(fontSize: 10, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Column(
                        children: filteredItems.map((dish) {
                          return InkWell(
                            onTap: () => _showOrderTableModal(dish, primaryColor, surfaceColor, textColor),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: themeInfo?.cardBorderRadius ?? BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(dish.imageUrl, height: 85, width: 85, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(dish.title, style: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                                        const SizedBox(height: 4),
                                        Text(dish.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: fontFamily, fontSize: 11, color: textColor.withOpacity(0.6))),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(dish.price, style: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
                                            const Spacer(),
                                            if (themeInfo?.showCaloriesBadges ?? true)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: Colors.deepOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                                child: Text('🔥 ${dish.calories}', style: const TextStyle(fontSize: 10, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrontCoverBody(
    dynamic themeInfo,
    Color primaryColor,
    Color bgColor,
    Color surfaceColor,
    Color textColor,
    String fontFamily,
    String storeName,
  ) {
    final coverTitle = themeInfo?.menuCoverTitle ?? 'THE FOOD RESTO MENU';
    final coverSubtitle = themeInfo?.menuCoverSubtitle ?? 'استمتع بأشهى وأجود الوجبات والمأكولات الطازجة اليوم';
    final offerBadge = themeInfo?.menuOfferBadgeText ?? '🔥 خصم 20% لفترة محدودة';
    final contactPhone = themeInfo?.menuContactPhone ?? '+966 50 123 4567';

    return Container(
      color: bgColor,
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Top Restaurant Logo & Badge
            CircleAvatar(
              radius: 36,
              backgroundColor: primaryColor.withOpacity(0.2),
              backgroundImage: themeInfo?.logoUrl != null ? NetworkImage(themeInfo!.logoUrl!) : null,
              child: themeInfo?.logoUrl == null ? Icon(Icons.restaurant_menu_rounded, color: primaryColor, size: 36) : null,
            ),
            const SizedBox(height: 12),

            Text(
              storeName,
              style: TextStyle(fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),

            // Special Offer Badge
            if (offerBadge.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: primaryColor.withOpacity(0.4), width: 1.5),
                ),
                child: Text(
                  offerBadge,
                  style: TextStyle(fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ),
            const SizedBox(height: 24),

            // Cover Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: themeInfo?.cardBorderRadius ?? BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: primaryColor.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    coverTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    coverSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 13,
                      color: textColor.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hero Cover Image Banner
            ClipRRect(
              borderRadius: themeInfo?.cardBorderRadius ?? BorderRadius.circular(20),
              child: Stack(
                children: [
                  Image.network(
                    themeInfo?.coverBannerUrl ?? 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [bgColor.withOpacity(0.85), Colors.transparent, bgColor.withOpacity(0.85)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Open Full Menu Prominent Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _currentPageView = 1),
                icon: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 22),
                label: Text(
                  'تصفح قائمة الطعام والوجبات الآن (صفحة 2) 👈',
                  style: TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: themeInfo?.buttonBorderRadius ?? BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Footer Contact & Delivery Phone
            if (contactPhone.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_in_talk_rounded, size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'للطلب والتوصيل المباشر: $contactPhone',
                      style: TextStyle(fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
