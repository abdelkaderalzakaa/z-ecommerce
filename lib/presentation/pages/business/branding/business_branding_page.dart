import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';

import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class StoreBrandingPage extends StatefulWidget {
  const StoreBrandingPage({super.key});

  @override
  State<StoreBrandingPage> createState() => _StoreBrandingPageState();
}

class _StoreBrandingPageState extends State<StoreBrandingPage> {
  // Theme Color Hex States
  String _primaryColorHex = '#4F46E5';
  String _secondaryColorHex = '#10B981';
  String _backgroundColorHex = '#F9FAFB';
  String _surfaceColorHex = '#FFFFFF';
  String _textColorHex = '#111827';

  // Font & Shape States
  String _selectedFontFamily = 'Cairo';
  double _fontScale = 1.0;
  double _buttonRadius = 12.0;
  double _cardRadius = 16.0;
  double _inputRadius = 10.0;

  // Media & Mode States
  String _logoUrl =
      'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=150';
  String _coverBannerUrl =
      'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentThemeAdmin = context
          .read<BusinessProvider>()
          .selectedBusiness
          ?.theme;
      if (currentThemeAdmin != null) {
        setState(() {
          _primaryColorHex = currentThemeAdmin.primaryColor;
          _secondaryColorHex = currentThemeAdmin.secondaryColor;
          _backgroundColorHex = currentThemeAdmin.backgroundColor;
          _surfaceColorHex = currentThemeAdmin.surfaceColor;
          _textColorHex = currentThemeAdmin.textColor;
          _selectedFontFamily = currentThemeAdmin.fontFamily;
          _fontScale = currentThemeAdmin.fontScale;
          _buttonRadius = currentThemeAdmin.buttonRadius;
          _cardRadius = currentThemeAdmin.cardRadius;
          _inputRadius = currentThemeAdmin.inputRadius;
          if (currentThemeAdmin.logoUrl != null) {
            _logoUrl = currentThemeAdmin.logoUrl!;
          }
          if (currentThemeAdmin.coverBannerUrl != null) {
            _coverBannerUrl = currentThemeAdmin.coverBannerUrl!;
          }
        });
      }
    });
  }

  // Color Palette Presets
  static const List<Map<String, String>> _primaryPalette = [
    {'name': 'إنديجو ملكي', 'hex': '#4F46E5'},
    {'name': 'أزرق سماوي', 'hex': '#2563EB'},
    {'name': 'زمردي نقي', 'hex': '#059669'},
    {'name': 'تيال مائي', 'hex': '#0D9488'},
    {'name': 'كهرماني ذهبي', 'hex': '#D97706'},
    {'name': 'أحمر ناصع', 'hex': '#DC2626'},
    {'name': 'بنفسجي فاخر', 'hex': '#7C3AED'},
    {'name': 'زهري وردي', 'hex': '#DB2777'},
    {'name': 'أسود فخم', 'hex': '#09090B'},
    {'name': 'كلاسيك رمادي', 'hex': '#475569'},
  ];

  static const List<Map<String, String>> _secondaryPalette = [
    {'name': 'أخضر خصومات', 'hex': '#10B981'},
    {'name': 'برتقالي مشرق', 'hex': '#F59E0B'},
    {'name': 'زهري وردي', 'hex': '#EC4899'},
    {'name': 'سيان تباين', 'hex': '#06B6D4'},
    {'name': 'بنفسجي هادئ', 'hex': '#8B5CF6'},
    {'name': 'أحمر تنبيه', 'hex': '#EF4444'},
  ];

  // Font Families Preset
  static const List<String> _fontFamilies = [
    'Cairo',
    'Tajawal',
    'Almarai',
    'Outfit',
    'Inter',
    'Roboto',
  ];

  // Preset Logos Gallery
  static const List<Map<String, String>> _logoGallery = [
    {
      'title': 'لوجو حديث',
      'url':
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=150',
    },
    {
      'title': 'لوجو موضة',
      'url':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    },
    {
      'title': 'لوجو تقني',
      'url':
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150',
    },
    {
      'title': 'لوجو مطعم',
      'url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=150',
    },
    {
      'title': 'لوجو فاخر',
      'url':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    },
  ];

  // Preset Cover Banners Gallery
  static const List<Map<String, String>> _coverGallery = [
    {
      'title': 'أزياء وموضة',
      'url':
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
    },
    {
      'title': 'إلكترونيات وتقنية',
      'url':
          'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=800',
    },
    {
      'title': 'مطاعم ومأكولات',
      'url':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
    },
    {
      'title': 'منتجات فاخرة',
      'url':
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
    },
    {
      'title': 'أثاث وديكور',
      'url':
          'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800',
    },
  ];

  ThemeAdmin get _currentTheme => ThemeAdmin(
    primaryColor: _primaryColorHex,
    secondaryColor: _secondaryColorHex,
    backgroundColor: _backgroundColorHex,
    surfaceColor: _surfaceColorHex,
    textColor: _textColorHex,
    fontFamily: _selectedFontFamily,
    fontScale: _fontScale,
    buttonRadius: _buttonRadius,
    cardRadius: _cardRadius,
    inputRadius: _inputRadius,
    logoUrl: _logoUrl,
    coverBannerUrl: _coverBannerUrl,
  );

  Future<void> _saveTheme() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      final business = context.read<BusinessProvider>().selectedBusiness;
      if (business != null) {
        context.read<BusinessProvider>().updateTheme(
          business.id,
          _currentTheme,
        );
      }
    }
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حفظ وتطبيق ثيم وهوية المتجر فوراً على كافة صفحات متجرك!',
          ),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 950;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Page Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withOpacity(0.12),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context)) ...[
                        Container(
                          margin: const EdgeInsets.only(left: 14),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.15),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                            tooltip: 'التراجع والعودة للإعدادات',
                          ),
                        ),
                      ],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? 'استوديو تخصيص الهوية والثيم المباشر (100% Visual Studio)'
                                : 'Store Theme & Branding Visual Studio (100% Real-Time)',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? 'اختر الألوان، الخطوط، اللوجو، والغلاف بنقرة واحدة واستعرض المعاينة اللحظية'
                                : 'Choose colors, fonts, logo and cover banner with instant live preview',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveTheme,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_rounded, size: 18),
                    label: Text(TranslationKeys.saveChanges.tr(context)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Split View Layout
            Expanded(
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Live Store Preview Mockup Window (55%)
                        Expanded(
                          flex: 55,
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.dividerColor.withOpacity(0.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildMockupWindowBar(theme),
                                Expanded(
                                  child: _buildStoreMockupPreview(
                                    _currentTheme,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right: Visual Selection Controls Form (45%)
                        Expanded(
                          flex: 45,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                            child: _buildVisualThemeControlsForm(theme),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            height: 480,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.dividerColor.withOpacity(0.15),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildMockupWindowBar(theme),
                                Expanded(
                                  child: _buildStoreMockupPreview(
                                    _currentTheme,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildVisualThemeControlsForm(theme),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Customer Interactive Mockup States
  bool _mockupIsArabic = true;
  bool _mockupIsDarkMode = false;
  int _mockupCartCount = 2;
  int _selectedMockupCategoryIndex = 0;
  int _activeMockupNavIndex = 0;
  bool _product1Favorite = false;
  bool _product2Favorite = true;

  // ───────────────────────────────────────────────
  // INTERACTIVE MOCKUP MODALS & DIALOGS
  // ───────────────────────────────────────────────
  void _showMockupCartModal(ThemeAdmin t) {
    final primaryColor = t.primaryColorValue;
    final surfaceColor = _mockupIsDarkMode
        ? const Color(0xFF1E1E22)
        : t.surfaceColorValue;
    final textColor = _mockupIsDarkMode
        ? const Color(0xFFF4F4F5)
        : t.textColorValue;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: _mockupIsArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _mockupIsArabic
                          ? 'سلة التسوق (2 منتجات)'
                          : 'Shopping Cart (2 Items)',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 16 * t.fontScale,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildCartItemRow(
                  t,
                  title: _mockupIsArabic
                      ? 'قميص كاجوال مودرن'
                      : 'Modern Casual Shirt',
                  price: '\$49.99',
                  imageUrl:
                      'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=300',
                  textColor: textColor,
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 12),
                _buildCartItemRow(
                  t,
                  title: _mockupIsArabic
                      ? 'حذاء رياضي أنيق'
                      : 'Elegant Sports Shoes',
                  price: '\$89.99',
                  imageUrl:
                      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
                  textColor: textColor,
                  primaryColor: primaryColor,
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _mockupIsArabic ? 'المجموع الإجمالي:' : 'Total Amount:',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 14 * t.fontScale,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '\$139.98',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 16 * t.fontScale,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showMockupCheckoutDialog(t);
                    },
                    icon: const Icon(Icons.shopping_bag_rounded, size: 18),
                    label: Text(
                      _mockupIsArabic
                          ? 'متابعة الدفع والشراء'
                          : 'Proceed to Checkout',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: t.buttonBorderRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItemRow(
    ThemeAdmin t, {
    required String title,
    required String price,
    required String imageUrl,
    required Color textColor,
    required Color primaryColor,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: t.inputBorderRadius,
          child: Image.network(
            imageUrl,
            width: 45,
            height: 45,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: 12 * t.fontScale,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: 11 * t.fontScale,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove, size: 12, color: primaryColor),
            ),
            const SizedBox(width: 8),
            Text(
              '1',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 12, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  void _showMockupProductDetailModal(
    ThemeAdmin t, {
    required String title,
    required String price,
    required String imageUrl,
  }) {
    final primaryColor = t.primaryColorValue;
    final surfaceColor = _mockupIsDarkMode
        ? const Color(0xFF1E1E22)
        : t.surfaceColorValue;
    final textColor = _mockupIsDarkMode
        ? const Color(0xFFF4F4F5)
        : t.textColorValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: _mockupIsArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Container(
            height: 460,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: t.cardBorderRadius,
                  child: Image.network(
                    imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 16 * t.fontScale,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      price,
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 18 * t.fontScale,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _mockupIsArabic
                      ? 'قماش قطني مريح عالي الجودة ومناسب لكافة الأوقات والمناسبات.'
                      : 'High quality comfortable cotton fabric suitable for all occasions.',
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: 11 * t.fontScale,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _mockupIsArabic ? 'اختر المقاس:' : 'Select Size:',
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: 12 * t.fontScale,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['S', 'M', 'L', 'XL'].map((sz) {
                    final isM = sz == 'M';
                    return Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isM
                            ? primaryColor
                            : primaryColor.withOpacity(0.1),
                        borderRadius: t.buttonBorderRadius,
                      ),
                      child: Text(
                        sz,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isM ? Colors.white : primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _mockupCartCount++);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _mockupIsArabic
                                ? 'تمت إضافة $title للسلة بنجاح!'
                                : 'Added $title to cart!',
                          ),
                          backgroundColor: primaryColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: Text(
                      _mockupIsArabic
                          ? 'إضافة إلى سلة التسوق'
                          : 'Add to Shopping Cart',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: t.buttonBorderRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMockupFilterModal(ThemeAdmin t) {
    final primaryColor = t.primaryColorValue;
    final surfaceColor = _mockupIsDarkMode
        ? const Color(0xFF1E1E22)
        : t.surfaceColorValue;
    final textColor = _mockupIsDarkMode
        ? const Color(0xFFF4F4F5)
        : t.textColorValue;

    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: _mockupIsArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: t.cardBorderRadius),
            title: Text(
              _mockupIsArabic
                  ? 'تصفية المنتجات (Filter Products)'
                  : 'Filter Products',
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: 16 * t.fontScale,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mockupIsArabic
                      ? 'نطاق السعر (\$10 - \$200):'
                      : 'Price Range (\$10 - \$200):',
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
                Slider(
                  value: 80,
                  min: 10,
                  max: 200,
                  activeColor: primaryColor,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 10),
                Text(
                  _mockupIsArabic ? 'التقييم:' : 'Rating:',
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
                Row(
                  children: [
                    for (int i = 0; i < 5; i++)
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(_mockupIsArabic ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: t.buttonBorderRadius,
                  ),
                ),
                child: Text(
                  _mockupIsArabic ? 'تطبيق الفلترة' : 'Apply Filter',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMockupCheckoutDialog(ThemeAdmin t) {
    final primaryColor = t.primaryColorValue;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _mockupIsArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: t.cardBorderRadius),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: t.secondaryColorValue,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                _mockupIsArabic ? 'تأكيد الطلب والشراء' : 'Order Confirmation',
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: 15 * t.fontScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            _mockupIsArabic
                ? 'هل ترغب بإتمام الطلب بمبلغ \$139.98 والتوصيل للعنوان المسجل؟'
                : 'Would you like to complete checkout for \$139.98?',
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: 12 * t.fontScale,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_mockupIsArabic ? 'تراجع' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _mockupIsArabic
                          ? 'تم إرسال الطلب بنجاح! شكراً لتسوقك.'
                          : 'Order placed successfully! Thank you.',
                    ),
                    backgroundColor: t.secondaryColorValue,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: t.buttonBorderRadius,
                ),
              ),
              child: Text(
                _mockupIsArabic ? 'تأكيد ودفع' : 'Confirm & Pay',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMockupCouponDialog(ThemeAdmin t) {
    final primaryColor = t.primaryColorValue;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _mockupIsArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: t.cardBorderRadius),
          title: Row(
            children: [
              Icon(Icons.card_giftcard_rounded, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                _mockupIsArabic ? 'تطبيق كود الخصم' : 'Apply Coupon Code',
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: 15 * t.fontScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: TextField(
            decoration: InputDecoration(
              hintText: _mockupIsArabic
                  ? 'ادخل كود الخصم (مثال: SUMMER40)'
                  : 'Enter coupon code (e.g. SUMMER40)',
              border: OutlineInputBorder(borderRadius: t.inputBorderRadius),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_mockupIsArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _mockupIsArabic
                          ? 'تم تفعيل خصم 20% بنجاح!'
                          : 'Coupon applied 20% OFF!',
                    ),
                    backgroundColor: primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: t.secondaryColorValue,
                shape: RoundedRectangleBorder(
                  borderRadius: t.buttonBorderRadius,
                ),
              ),
              child: Text(
                _mockupIsArabic ? 'تطبيق الخصم' : 'Apply Discount',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMockupShareDialog(ThemeAdmin t) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _mockupIsArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: t.cardBorderRadius),
          title: Row(
            children: [
              Icon(Icons.share_rounded, color: t.primaryColorValue, size: 24),
              const SizedBox(width: 8),
              Text(
                _mockupIsArabic ? 'مشاركة رابط المتجر' : 'Share Store Link',
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: 15 * t.fontScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.green),
                onPressed: () => Navigator.pop(ctx),
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.pink),
                onPressed: () => Navigator.pop(ctx),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.indigo),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // Mockup Top Browser Frame Bar
  // ───────────────────────────────────────────────
  Widget _buildMockupWindowBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: const [
              CircleAvatar(radius: 5, backgroundColor: Color(0xFFEF4444)),
              SizedBox(width: 6),
              CircleAvatar(radius: 5, backgroundColor: Color(0xFFF59E0B)),
              SizedBox(width: 6),
              CircleAvatar(radius: 5, backgroundColor: Color(0xFF10B981)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 12,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'https://mystore.com/preview',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Interactive Customer Language Switcher
          InkWell(
            onTap: () => setState(() => _mockupIsArabic = !_mockupIsArabic),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language_rounded, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    _mockupIsArabic ? 'English' : 'العربية',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Interactive Customer Dark/Light Theme Switcher
          InkWell(
            onTap: () => setState(() => _mockupIsDarkMode = !_mockupIsDarkMode),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _mockupIsDarkMode
                    ? const Color(0xFF27272A)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    _mockupIsDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    size: 13,
                    color: _mockupIsDarkMode
                        ? Colors.amber
                        : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _mockupIsDarkMode ? 'الليل' : 'النهار',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _mockupIsDarkMode
                          ? Colors.white
                          : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // LIVE MOCKUP PREVIEW WINDOW (WITH CUSTOMER SIMULATION)
  // ───────────────────────────────────────────────
  Widget _buildStoreMockupPreview(ThemeAdmin t) {
    final primaryColor = t.primaryColorValue;

    final bgColor = _mockupIsDarkMode
        ? const Color(0xFF141416)
        : t.backgroundColorValue;
    final surfaceColor = _mockupIsDarkMode
        ? const Color(0xFF1E1E22)
        : t.surfaceColorValue;
    final textColor = _mockupIsDarkMode
        ? const Color(0xFFF4F4F5)
        : t.textColorValue;

    return Directionality(
      textDirection: _mockupIsArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: bgColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Mockup Header Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: t.cardBorderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: primaryColor.withOpacity(0.15),
                      backgroundImage: NetworkImage(t.logoUrl ?? _logoUrl),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _mockupIsArabic ? 'متجري المباشر' : 'My Live Store',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 15 * t.fontScale,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),

                    // Customer Actions (Language & Theme Chips inside Header)
                    InkWell(
                      onTap: () =>
                          setState(() => _mockupIsArabic = !_mockupIsArabic),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _mockupIsArabic ? 'EN' : 'عربي',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(
                        () => _mockupIsDarkMode = !_mockupIsDarkMode,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: t.buttonBorderRadius,
                        ),
                        child: Icon(
                          _mockupIsDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          size: 14,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showMockupCartModal(t),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: t.buttonBorderRadius,
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          if (_mockupCartCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: t.secondaryColorValue,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$_mockupCartCount',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Mockup Store Banner Header
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: t.cardBorderRadius,
                  image: DecorationImage(
                    image: NetworkImage(t.coverBannerUrl ?? _coverBannerUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: t.cardBorderRadius,
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _mockupIsArabic
                            ? 'أفخم التشكيلات المودرن'
                            : 'Premium Modern Collection',
                        style: TextStyle(
                          fontFamily: t.fontFamily,
                          fontSize: 16 * t.fontScale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _mockupIsArabic
                            ? 'خصومات تصل حتى 40%'
                            : 'Discounts up to 40% OFF',
                        style: TextStyle(
                          fontFamily: t.fontFamily,
                          fontSize: 11 * t.fontScale,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 3. Category Pills Carousel (شريط التصنيفات التفاعلي)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMockupCategoryPill(
                      t,
                      index: 0,
                      label: _mockupIsArabic ? 'الكل' : 'All',
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                    ),
                    const SizedBox(width: 8),
                    _buildMockupCategoryPill(
                      t,
                      index: 1,
                      label: _mockupIsArabic ? 'أزياء' : 'Fashion',
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                    ),
                    const SizedBox(width: 8),
                    _buildMockupCategoryPill(
                      t,
                      index: 2,
                      label: _mockupIsArabic ? 'إلكترونيات' : 'Electronics',
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                    ),
                    const SizedBox(width: 8),
                    _buildMockupCategoryPill(
                      t,
                      index: 3,
                      label: _mockupIsArabic ? 'ساعات' : 'Watches',
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. Mockup Search & Filter Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: t.inputBorderRadius,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 16, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            _mockupIsArabic
                                ? 'ابحث عن المنتجات هنا...'
                                : 'Search products here...',
                            style: TextStyle(
                              fontFamily: t.fontFamily,
                              fontSize: 11 * t.fontScale,
                              color: textColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showMockupFilterModal(t),
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: t.inputBorderRadius,
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 5. Sample Products Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMockupProductCard(
                      t,
                      title: _mockupIsArabic
                          ? 'قميص كاجوال مودرن'
                          : 'Modern Casual Shirt',
                      price: '\$49.99',
                      rating: '⭐ 4.8',
                      isFav: _product1Favorite,
                      onFavTap: () => setState(
                        () => _product1Favorite = !_product1Favorite,
                      ),
                      onTap: () => _showMockupProductDetailModal(
                        t,
                        title: _mockupIsArabic
                            ? 'قميص كاجوال مودرن'
                            : 'Modern Casual Shirt',
                        price: '\$49.99',
                        imageUrl:
                            'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=300',
                      ),
                      imageUrl:
                          'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=300',
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMockupProductCard(
                      t,
                      title: _mockupIsArabic
                          ? 'حذاء رياضي أنيق'
                          : 'Elegant Sports Shoes',
                      price: '\$89.99',
                      rating: '⭐ 4.9',
                      isFav: _product2Favorite,
                      onFavTap: () => setState(
                        () => _product2Favorite = !_product2Favorite,
                      ),
                      onTap: () => _showMockupProductDetailModal(
                        t,
                        title: _mockupIsArabic
                            ? 'حذاء رياضي أنيق'
                            : 'Elegant Sports Shoes',
                        price: '\$89.99',
                        imageUrl:
                            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
                      ),
                      imageUrl:
                          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 6. Interactive Button Showcase Box (معرض الأزرار المنبثقة)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: t.cardBorderRadius,
                  border: Border.all(color: primaryColor.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mockupIsArabic
                          ? 'معرض أزرار التفاعل (انقر لتجربة النوافذ المنبثقة):'
                          : 'Interactive Buttons (Click to test dialogs):',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 11 * t.fontScale,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Primary Button
                        Expanded(
                          child: InkWell(
                            onTap: () => _showMockupCheckoutDialog(t),
                            borderRadius: t.buttonBorderRadius,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: t.buttonBorderRadius,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _mockupIsArabic ? 'إتمام الطلب' : 'Checkout',
                                style: TextStyle(
                                  fontFamily: t.fontFamily,
                                  fontSize: 11 * t.fontScale,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Secondary Button
                        Expanded(
                          child: InkWell(
                            onTap: () => _showMockupCouponDialog(t),
                            borderRadius: t.buttonBorderRadius,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: t.secondaryColorValue,
                                borderRadius: t.buttonBorderRadius,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _mockupIsArabic ? 'كوبون الخصم' : 'Coupon',
                                style: TextStyle(
                                  fontFamily: t.fontFamily,
                                  fontSize: 11 * t.fontScale,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Outlined Button
                        Expanded(
                          child: InkWell(
                            onTap: () => _showMockupShareDialog(t),
                            borderRadius: t.buttonBorderRadius,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: t.buttonBorderRadius,
                                border: Border.all(
                                  color: primaryColor,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _mockupIsArabic ? 'مشاركة' : 'Share',
                                style: TextStyle(
                                  fontFamily: t.fontFamily,
                                  fontSize: 11 * t.fontScale,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 7. Typography Styles Showcase Box (معرض أنماط النصوص والخطوط)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: t.cardBorderRadius,
                  border: Border.all(color: primaryColor.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mockupIsArabic
                          ? 'عنوان رئيسي عريض (Heading H1)'
                          : 'Main Heading Title H1',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 16 * t.fontScale,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _mockupIsArabic
                          ? 'عنوان فرعي توضيحي (Subtitle H2)'
                          : 'Subtitle Secondary Text H2',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 12 * t.fontScale,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _mockupIsArabic
                          ? 'هذا نص الفقرة العادي للتأكد من سهولة القراءة وتناسق الخط.'
                          : 'This is standard body paragraph text to ensure legibility and contrast.',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 11 * t.fontScale,
                        color: textColor.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 8. Promo Alert Notification Toast
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: t.buttonBorderRadius,
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _mockupIsArabic
                            ? '🚚 شحن مجاني وسريع لجميع الطلبات اليوم!'
                            : '🚚 Fast Free Shipping on all orders today!',
                        style: TextStyle(
                          fontFamily: t.fontFamily,
                          fontSize: 10 * t.fontScale,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 9. Mockup Bottom Navigation Bar (شريط التصفح السُفلي التفاعلي)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: t.cardBorderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMockupNavItem(
                      t,
                      index: 0,
                      icon: Icons.home_rounded,
                      label: _mockupIsArabic ? 'الرئيسية' : 'Home',
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),
                    _buildMockupNavItem(
                      t,
                      index: 1,
                      icon: Icons.grid_view_rounded,
                      label: _mockupIsArabic ? 'الأقسام' : 'Categories',
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),
                    _buildMockupNavItem(
                      t,
                      index: 2,
                      icon: Icons.favorite_border_rounded,
                      label: _mockupIsArabic ? 'المفضلة' : 'Wishlist',
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),
                    _buildMockupNavItem(
                      t,
                      index: 3,
                      icon: Icons.person_outline_rounded,
                      label: _mockupIsArabic ? 'حسابي' : 'Profile',
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockupCategoryPill(
    ThemeAdmin t, {
    required int index,
    required String label,
    required Color primaryColor,
    required Color surfaceColor,
    required Color textColor,
  }) {
    final isSelected = _selectedMockupCategoryIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedMockupCategoryIndex = index),
      borderRadius: t.buttonBorderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : surfaceColor,
          borderRadius: t.buttonBorderRadius,
          border: Border.all(
            color: isSelected ? primaryColor : primaryColor.withOpacity(0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: 11 * t.fontScale,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildMockupNavItem(
    ThemeAdmin t, {
    required int index,
    required IconData icon,
    required String label,
    required Color primaryColor,
    required Color textColor,
  }) {
    final isSelected = _activeMockupNavIndex == index;

    return InkWell(
      onTap: () => setState(() => _activeMockupNavIndex = index),
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? primaryColor : textColor.withOpacity(0.5),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: 9 * t.fontScale,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryColor : textColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupProductCard(
    ThemeAdmin t, {
    required String title,
    required String price,
    required String rating,
    required bool isFav,
    required VoidCallback onFavTap,
    required VoidCallback onTap,
    required String imageUrl,
    required Color surfaceColor,
    required Color textColor,
  }) {
    final primaryColor = t.primaryColorValue;
    final secondaryColor = t.secondaryColorValue;

    return InkWell(
      onTap: onTap,
      borderRadius: t.cardBorderRadius,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: t.cardBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(t.cardRadius),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _mockupIsArabic ? 'خصم 20%' : '20% OFF',
                      style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 9 * t.fontScale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: InkWell(
                    onTap: onFavTap,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 13,
                        color: isFav ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: t.fontFamily,
                            fontSize: 11 * t.fontScale,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        rating,
                        style: TextStyle(
                          fontFamily: t.fontFamily,
                          fontSize: 9 * t.fontScale,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontFamily: t.fontFamily,
                          fontSize: 12 * t.fontScale,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() => _mockupCartCount++);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _mockupIsArabic
                                    ? 'تمت إضافة $title للسلة بنجاح!'
                                    : 'Added $title to cart!',
                              ),
                              backgroundColor: primaryColor,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: t.buttonBorderRadius,
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
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
  }

  // ───────────────────────────────────────────────
  // 100% VISUAL THEME SELECTION CONTROLS FORM
  // ───────────────────────────────────────────────
  Widget _buildVisualThemeControlsForm(ThemeData theme) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Primary Colors Palette Selector
        _buildControlSectionCard(
          theme,
          title: isArabic
              ? 'اللون الرئيسي للمتجر (Primary Color)'
              : 'Store Primary Color',
          subtitle: isArabic
              ? 'اختر اللون الأساسي للأزرار، الهيدر، والعناوين أو اختر لونك الخاص'
              : 'Choose primary color for buttons, headers and titles or select custom color',
          icon: Icons.palette_rounded,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ..._primaryPalette.map((item) {
                  final hex = item['hex']!;
                  final isSelected =
                      _primaryColorHex.toLowerCase() == hex.toLowerCase();
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: _parseColor(hex),
                        ),
                        const SizedBox(width: 8),
                        Text(item['name']!),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _primaryColorHex = hex),
                    selectedColor: _parseColor(hex).withOpacity(0.18),
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.colorize_rounded, size: 16),
                  label: Text(
                    isArabic
                        ? '🎨 فتح دولاب اختيار اللون المخصص...'
                        : '🎨 Open Custom Color Picker...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _showCustomColorPickerDialog(
                    context: context,
                    initialColorHex: _primaryColorHex,
                    titleText: isArabic
                        ? 'اختيار اللون الرئيسي (Primary Color Picker)'
                        : 'Primary Color Picker',
                    onColorSelected: (hex) =>
                        setState(() => _primaryColorHex = hex),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2. Secondary Colors Palette Selector
        _buildControlSectionCard(
          theme,
          title: isArabic
              ? 'اللون الفرعي والخصومات (Secondary Color)'
              : 'Store Secondary Color',
          subtitle: isArabic
              ? 'اختر اللون الفرعي لبطاقات الخصم والتأكيدات أو اختر لونك الخاص'
              : 'Choose secondary color for discount badges and confirmations',
          icon: Icons.color_lens_rounded,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ..._secondaryPalette.map((item) {
                  final hex = item['hex']!;
                  final isSelected =
                      _secondaryColorHex.toLowerCase() == hex.toLowerCase();
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: _parseColor(hex),
                        ),
                        const SizedBox(width: 8),
                        Text(item['name']!),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (val) =>
                        setState(() => _secondaryColorHex = hex),
                    selectedColor: _parseColor(hex).withOpacity(0.18),
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.colorize_rounded, size: 16),
                  label: Text(
                    isArabic
                        ? '🎨 فتح دولاب اختيار اللون المخصص...'
                        : '🎨 Open Custom Color Picker...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _showCustomColorPickerDialog(
                    context: context,
                    initialColorHex: _secondaryColorHex,
                    titleText: isArabic
                        ? 'اختيار اللون الفرعي (Secondary Color Picker)'
                        : 'Secondary Color Picker',
                    onColorSelected: (hex) =>
                        setState(() => _secondaryColorHex = hex),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 3. Background Theme Style Cards (خلفية ذات لون ناعم وخفيف جداً إجبارياً)
        _buildControlSectionCard(
          theme,
          title: isArabic
              ? 'نمط خلفية وشكل المتجر (Soft Tinted Background Theme)'
              : 'Soft Tinted Background Theme',
          subtitle: isArabic
              ? 'اختر المظهر العام للخلفية (درجات ألوان خفيفة وناعمة جداً إجبارياً لضمان وضوح النصوص)'
              : 'Select overall background theme (soft tinted background for best contrast)',
          icon: Icons.wallpaper_rounded,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildThemePresetCard(
                  title: 'أبيض ناصع',
                  subtitle: 'Pure White',
                  bgHex: '#FFFFFF',
                  surfaceHex: '#F9FAFB',
                  isSelected: _backgroundColorHex.toUpperCase() == '#FFFFFF',
                  onTap: () => setState(() {
                    _backgroundColorHex = '#FFFFFF';
                    _surfaceColorHex = '#F9FAFB';
                    _textColorHex = '#111827';
                  }),
                ),
                _buildThemePresetCard(
                  title: 'رمادي ناعم',
                  subtitle: 'Soft Slate',
                  bgHex: '#F8FAFC',
                  surfaceHex: '#FFFFFF',
                  isSelected: _backgroundColorHex.toUpperCase() == '#F8FAFC',
                  onTap: () => setState(() {
                    _backgroundColorHex = '#F8FAFC';
                    _surfaceColorHex = '#FFFFFF';
                    _textColorHex = '#111827';
                  }),
                ),
                _buildThemePresetCard(
                  title: 'أزرق خفيف',
                  subtitle: 'Soft Blue 3%',
                  bgHex: '#F0F6FF',
                  surfaceHex: '#FFFFFF',
                  isSelected: _backgroundColorHex.toUpperCase() == '#F0F6FF',
                  onTap: () => setState(() {
                    _backgroundColorHex = '#F0F6FF';
                    _surfaceColorHex = '#FFFFFF';
                    _textColorHex = '#0F172A';
                  }),
                ),
                _buildThemePresetCard(
                  title: 'زمردي خفيف',
                  subtitle: 'Soft Emerald 3%',
                  bgHex: '#F0FDF4',
                  surfaceHex: '#FFFFFF',
                  isSelected: _backgroundColorHex.toUpperCase() == '#F0FDF4',
                  onTap: () => setState(() {
                    _backgroundColorHex = '#F0FDF4';
                    _surfaceColorHex = '#FFFFFF';
                    _textColorHex = '#064E3B';
                  }),
                ),
                _buildThemePresetCard(
                  title: 'بنفسجي خفيف',
                  subtitle: 'Soft Purple 3%',
                  bgHex: '#F7F5FF',
                  surfaceHex: '#FFFFFF',
                  isSelected: _backgroundColorHex.toUpperCase() == '#F7F5FF',
                  onTap: () => setState(() {
                    _backgroundColorHex = '#F7F5FF';
                    _surfaceColorHex = '#FFFFFF';
                    _textColorHex = '#3B0764';
                  }),
                ),
                _buildThemePresetCard(
                  title: 'كريمي دافئ',
                  subtitle: 'Soft Cream 3%',
                  bgHex: '#FFFBEB',
                  surfaceHex: '#FFFFFF',
                  isSelected: _backgroundColorHex.toUpperCase() == '#FFFBEB',
                  onTap: () => setState(() {
                    _backgroundColorHex = '#FFFBEB';
                    _surfaceColorHex = '#FFFFFF';
                    _textColorHex = '#451A03';
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ActionChip(
              avatar: const Icon(Icons.colorize_rounded, size: 16),
              label: const Text(
                '🎨 دمج لون المتجر الرئيسي بخلفية خفيفة ناعمة جداً...',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // compulsory ultra-soft tint derived from primary color
                final primary = _parseColor(_primaryColorHex);
                final softTint = Color.alphaBlend(
                  primary.withOpacity(0.04),
                  Colors.white,
                );
                final hexString =
                    '#${softTint.value.toRadixString(16).substring(2).toUpperCase()}';

                setState(() {
                  _backgroundColorHex = hexString;
                  _surfaceColorHex = '#FFFFFF';
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تطبيق لون خلفية ناعم وخفيف جداً مشتق من لون متجرك ($hexString)!',
                    ),
                    backgroundColor: primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 4. Typography & Font Family Picker Chips
        _buildControlSectionCard(
          theme,
          title: 'الخطوط وتنسيق النصوص (Typography & Font)',
          subtitle: 'اختر نوع الخط المفضل بنقرة واحدة مع معاينة الخطوط',
          icon: Icons.font_download_rounded,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _fontFamilies.map((font) {
                final isSelected = _selectedFontFamily == font;
                return ChoiceChip(
                  label: Text(
                    font,
                    style: TextStyle(
                      fontFamily: font,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (val) =>
                      setState(() => _selectedFontFamily = font),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'مقياس حجم الخط (Font Scale)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_fontScale.toStringAsFixed(2)}x',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: _fontScale,
              min: 0.85,
              max: 1.25,
              divisions: 8,
              label: '${_fontScale.toStringAsFixed(2)}x',
              onChanged: (val) => setState(() => _fontScale = val),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 5. Border Radius Preset Shapes Sliders
        _buildControlSectionCard(
          theme,
          title: 'انحناء الزوايا والأشكال (Border Radius Sliders)',
          subtitle: 'التحكم بانحناء الأزرار، كروت المنتجات، وحقول الإدخال',
          icon: Icons.rounded_corner_rounded,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'انحناء الأزرار (Button Radius)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_buttonRadius.toInt()}px',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: _buttonRadius,
              min: 0,
              max: 30,
              divisions: 30,
              onChanged: (val) => setState(() => _buttonRadius = val),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'انحناء كروت المنتجات (Card Radius)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_cardRadius.toInt()}px',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: _cardRadius,
              min: 0,
              max: 30,
              divisions: 30,
              onChanged: (val) => setState(() => _cardRadius = val),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'انحناء حقول البحث والإدخال (Input Radius)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_inputRadius.toInt()}px',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: _inputRadius,
              min: 0,
              max: 25,
              divisions: 25,
              onChanged: (val) => setState(() => _inputRadius = val),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 6. Visual Logo & Banner Gallery Selectors
        _buildControlSectionCard(
          theme,
          title: 'معرض الشعار وغلاف المتجر (Logo & Cover Gallery)',
          subtitle: 'اختر شعار وغلاف المتجر بنقرة واحدة من النماذج الجاهزة',
          icon: Icons.image_search_rounded,
          children: [
            const Text(
              'اختر شعار المتجر (Store Logo)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _logoGallery.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = _logoGallery[index];
                  final isSelected = _logoUrl == item['url'];
                  return GestureDetector(
                    onTap: () => setState(() => _logoUrl = item['url']!),
                    child: Container(
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.primaryColor
                              : theme.dividerColor.withOpacity(0.2),
                          width: isSelected ? 3 : 1,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(item['url']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'اختر غلاف المتجر الرئيسي (Header Cover Banner)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _coverGallery.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = _coverGallery[index];
                  final isSelected = _coverBannerUrl == item['url'];
                  return GestureDetector(
                    onTap: () => setState(() => _coverBannerUrl = item['url']!),
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.primaryColor
                              : theme.dividerColor.withOpacity(0.2),
                          width: isSelected ? 3 : 1,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(item['url']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        color: Colors.black54,
                        child: Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemePresetCard({
    required String title,
    required String subtitle,
    required String bgHex,
    required String surfaceHex,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _parseColor(bgHex),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.dividerColor.withOpacity(0.2),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSectionCard(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: theme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  void _showCustomColorPickerDialog({
    required BuildContext context,
    required String initialColorHex,
    required String titleText,
    required ValueChanged<String> onColorSelected,
  }) {
    Color selectedColor = _parseColor(initialColorHex);
    HSVColor hsvColor = HSVColor.fromColor(selectedColor);
    double hue = hsvColor.hue;
    double saturation = hsvColor.saturation < 0.1 ? 0.8 : hsvColor.saturation;
    double value = hsvColor.value < 0.1 ? 0.9 : hsvColor.value;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentColor = HSVColor.fromAHSV(
              1.0,
              hue,
              saturation,
              value,
            ).toColor();
            final hexString =
                '#${currentColor.value.toRadixString(16).substring(2).toUpperCase()}';

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.palette_outlined, color: Colors.indigo),
                  const SizedBox(width: 10),
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Preview Color Box & Hex Code Banner
                      Container(
                        height: 65,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: currentColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: currentColor.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          hexString,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: currentColor.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Hue Rainbow Spectrum Slider
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'طيف درجة اللون (Hue Spectrum):',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF0000),
                              Color(0xFFFFFF00),
                              Color(0xFF00FF00),
                              Color(0xFF00FFFF),
                              Color(0xFF0000FF),
                              Color(0xFFFF00FF),
                              Color(0xFFFF0000),
                            ],
                          ),
                        ),
                      ),
                      Slider(
                        value: hue,
                        min: 0.0,
                        max: 360.0,
                        onChanged: (val) => setDialogState(() => hue = val),
                      ),
                      const SizedBox(height: 12),

                      // Saturation / Shade Slider
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'درجة تشبع اللون (Saturation & Shade):',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: saturation,
                        min: 0.1,
                        max: 1.0,
                        onChanged: (val) =>
                            setDialogState(() => saturation = val),
                      ),
                      const SizedBox(height: 12),

                      // Fast Color Grid
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'درجات سريعة جاهزة:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var c in [
                            const Color(0xFFF43F5E),
                            const Color(0xFFEC4899),
                            const Color(0xFFD946EF),
                            const Color(0xFFA855F7),
                            const Color(0xFF8B5CF6),
                            const Color(0xFF6366F1),
                            const Color(0xFF3B82F6),
                            const Color(0xFF0EA5E9),
                            const Color(0xFF06B6D4),
                            const Color(0xFF14B8A6),
                            const Color(0xFF10B981),
                            const Color(0xFF22C55E),
                            const Color(0xFF84CC16),
                            const Color(0xFFEAB308),
                            const Color(0xFFF59E0B),
                            const Color(0xFFF97316),
                            const Color(0xFFEF4444),
                            const Color(0xFF78716C),
                            const Color(0xFF18181B),
                            const Color(0xFF0F172A),
                          ]) ...[
                            GestureDetector(
                              onTap: () {
                                final hsv = HSVColor.fromColor(c);
                                setDialogState(() {
                                  hue = hsv.hue;
                                  saturation = hsv.saturation;
                                  value = hsv.value;
                                });
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: currentColor == c
                                        ? Colors.black
                                        : Colors.white,
                                    width: currentColor == c ? 3 : 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    onColorSelected(hexString);
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('تطبيق اللون المختار'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.indigo;
    }
  }
}
