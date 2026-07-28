import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/company_settings_model.dart';
import '../../../../data/providers/company_provider.dart';

class RestaurantMenuBrandingPage extends StatefulWidget {
  const RestaurantMenuBrandingPage({super.key});

  @override
  State<RestaurantMenuBrandingPage> createState() =>
      _RestaurantMenuBrandingPageState();
}

class _RestaurantMenuBrandingPageState
    extends State<RestaurantMenuBrandingPage> {
  bool _isRestaurantMenuEnabled = true;
  String _restaurantMenuLayout = 'grid'; // 'grid', 'list', 'board'
  String _restaurantMenuThemeStyle = 'chalkboard'; // 'chalkboard', 'italiano', 'modern'
  bool _showCaloriesBadges = true;
  bool _showAllergensBadges = true;
  bool _enableTableOrderQR = true;

  int _mockupPageView = 0; // 0: Cover Page, 1: Inside Menu Page

  final TextEditingController _menuCoverTitleController =
      TextEditingController(text: 'THE FOOD RESTO MENU');
  final TextEditingController _menuCoverSubtitleController =
      TextEditingController(text: 'استمتع بأشهى وأجود الوجبات والمأكولات الطازجة اليوم');
  final TextEditingController _menuOfferBadgeController =
      TextEditingController(text: '🔥 خصم 20% لفترة محدودة');
  final TextEditingController _menuContactPhoneController =
      TextEditingController(text: '+966 50 123 4567');

  bool _mockupIsArabic = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final theme = context.read<CompanyProvider>().companySettings?.theme;
      if (theme != null) {
        setState(() {
          _isRestaurantMenuEnabled = theme.isRestaurantMenuEnabled;
          _restaurantMenuLayout = theme.restaurantMenuLayout;
          _restaurantMenuThemeStyle = theme.restaurantMenuThemeStyle;
          _showCaloriesBadges = theme.showCaloriesBadges;
          _showAllergensBadges = theme.showAllergensBadges;
          _enableTableOrderQR = theme.enableTableOrderQR;
          _menuCoverTitleController.text = theme.menuCoverTitle;
          _menuCoverSubtitleController.text = theme.menuCoverSubtitle;
          _menuOfferBadgeController.text = theme.menuOfferBadgeText;
          _menuContactPhoneController.text = theme.menuContactPhone;
        });
      }
    });
  }

  @override
  void dispose() {
    _menuCoverTitleController.dispose();
    _menuCoverSubtitleController.dispose();
    _menuOfferBadgeController.dispose();
    _menuContactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveMenuBranding() async {
    setState(() => _isSaving = true);
    final companyProvider = context.read<CompanyProvider>();
    final currentTheme = companyProvider.companySettings?.theme ??
        const StoreTheme(
          primaryColor: '#4F46E5',
          secondaryColor: '#10B981',
        );

    final updatedTheme = StoreTheme(
      primaryColor: currentTheme.primaryColor,
      secondaryColor: currentTheme.secondaryColor,
      backgroundColor: currentTheme.backgroundColor,
      surfaceColor: currentTheme.surfaceColor,
      textColor: currentTheme.textColor,
      fontFamily: currentTheme.fontFamily,
      fontScale: currentTheme.fontScale,
      buttonRadius: currentTheme.buttonRadius,
      cardRadius: currentTheme.cardRadius,
      inputRadius: currentTheme.inputRadius,
      logoUrl: currentTheme.logoUrl,
      coverBannerUrl: currentTheme.coverBannerUrl,
      isDarkModeEnabled: currentTheme.isDarkModeEnabled,
      isRestaurantMenuEnabled: _isRestaurantMenuEnabled,
      restaurantMenuLayout: _restaurantMenuLayout,
      restaurantMenuThemeStyle: _restaurantMenuThemeStyle,
      showCaloriesBadges: _showCaloriesBadges,
      showAllergensBadges: _showAllergensBadges,
      enableTableOrderQR: _enableTableOrderQR,
      menuCoverTitle: _menuCoverTitleController.text,
      menuCoverSubtitle: _menuCoverSubtitleController.text,
      menuOfferBadgeText: _menuOfferBadgeController.text,
      menuContactPhone: _menuContactPhoneController.text,
    );

    companyProvider.updateStoreTheme(updatedTheme);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('تم حفظ وتطبيق إعدادات استوديو المنيو الرقمي للمطعم بنجاح!'),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final companyProvider = Provider.of<CompanyProvider>(context);
    final storeTheme = companyProvider.companySettings?.theme ??
        const StoreTheme(primaryColor: '#4F46E5', secondaryColor: '#10B981');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Page Top Header Bar
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
                children: [
                  if (Navigator.canPop(context))
                    Container(
                      margin: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: theme.dividerColor.withOpacity(0.15)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'تراجع والعودة',
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'استوديو تخصيص منيو المطعم الرقمي (Restaurant Menu Studio)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'تخصيص نمط المنيو، السعرات الحرارية، تنبيهات الحساسية، ورقم الطاولة مع معاينة حية للمطعم',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveMenuBranding,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ الهوية للمنيو'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Controls & Options Form
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildControlCard(
                            theme,
                            title: 'تفعيل وإعدادات المنيو الرقمي',
                            subtitle:
                                'تحويل واجهة المتجر إلى منيو تفاعلي مخصص للمطاعم والكافيهات',
                            icon: Icons.restaurant_menu_rounded,
                            children: [
                              SwitchListTile(
                                title: const Text(
                                  'تفعيل نمط المنيو الرقمي للمطعم (Restaurant Digital Menu)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: const Text(
                                    'عرض وجبات وأطباق الطعام بتنسيق المنيو التفاعلي'),
                                value: _isRestaurantMenuEnabled,
                                onChanged: (val) => setState(
                                    () => _isRestaurantMenuEnabled = val),
                                activeColor: Colors.deepOrange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildControlCard(
                            theme,
                            title: 'نمط عرض وجبات الطعام',
                            subtitle:
                                'اختر التنسيق الأنسب لعرض قائمة الطعام للزبائن',
                            icon: Icons.grid_view_rounded,
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _buildLayoutChip(
                                      'grid', 'شبكة كروت (Grid)', Icons.grid_on_rounded),
                                  _buildLayoutChip('list', 'قائمة أفقية (List)',
                                      Icons.view_list_rounded),
                                  _buildLayoutChip('board', 'لوحة مميزة (Board)',
                                      Icons.dashboard_customize_rounded),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildControlCard(
                            theme,
                            title: 'طراز وتصميم المنيو الفاخر (Menu Theme Style)',
                            subtitle:
                                'اختر مظهر وثيم المنيو المفضل لمطعمك المستوحى من أشهر التصاميم العالمية',
                            icon: Icons.auto_awesome_rounded,
                            children: [
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  ChoiceChip(
                                    avatar: const Icon(Icons.dark_mode_rounded, size: 16, color: Colors.amber),
                                    label: const Text('🌙 ثيم السبورة والذهب (Chalkboard Gold)', style: TextStyle(fontWeight: FontWeight.bold)),
                                    selected: _restaurantMenuThemeStyle == 'chalkboard',
                                    selectedColor: Colors.amber.shade800,
                                    onSelected: (val) => setState(() => _restaurantMenuThemeStyle = 'chalkboard'),
                                  ),
                                  ChoiceChip(
                                    avatar: const Icon(Icons.restaurant_rounded, size: 16, color: Colors.deepOrange),
                                    label: const Text('🍊 ثيم إيطاليانو دافئ (Italiano Amber)', style: TextStyle(fontWeight: FontWeight.bold)),
                                    selected: _restaurantMenuThemeStyle == 'italiano',
                                    selectedColor: Colors.deepOrange,
                                    onSelected: (val) => setState(() => _restaurantMenuThemeStyle = 'italiano'),
                                  ),
                                  ChoiceChip(
                                    avatar: const Icon(Icons.wb_sunny_rounded, size: 16, color: Colors.blue),
                                    label: const Text('🌿 ثيم مودرن نقي (Modern Clean)', style: TextStyle(fontWeight: FontWeight.bold)),
                                    selected: _restaurantMenuThemeStyle == 'modern',
                                    selectedColor: Colors.blue,
                                    onSelected: (val) => setState(() => _restaurantMenuThemeStyle = 'modern'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildControlCard(
                            theme,
                            title: 'شارات ومعلومات الوجبة الحية',
                            subtitle:
                                'تحديد البيانات الصحية والغذائية الظاهرة على الأطباق',
                            icon: Icons.local_fire_department_rounded,
                            children: [
                              SwitchListTile(
                                title: const Text(
                                  'إظهار شارة السعرات الحرارية (🔥 Calories Badges)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: const Text(
                                    'عرض عدد السعرات الحرارية لكل وجبة (مثل 680 Kcal)'),
                                value: _showCaloriesBadges,
                                onChanged: (val) => setState(
                                    () => _showCaloriesBadges = val),
                                activeColor: Colors.deepOrange,
                              ),
                              SwitchListTile(
                                title: const Text(
                                  'إظهار مكونات الحساسية (🌾 Allergens Badges)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: const Text(
                                    'تنبيه الزبائن لمكونات الحساسية (جليوتين، حليب، مكسرات)'),
                                value: _showAllergensBadges,
                                onChanged: (val) => setState(
                                    () => _showAllergensBadges = val),
                                activeColor: Colors.deepOrange,
                              ),
                              SwitchListTile(
                                title: const Text(
                                  'تفعيل الطلب المباشر للطاولة بالـ QR Code',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: const Text(
                                    'السماح للزبون بإدخال رقم الطاولة وإرسال الطلب المباشر'),
                                value: _enableTableOrderQR,
                                onChanged: (val) =>
                                    setState(() => _enableTableOrderQR = val),
                                activeColor: Colors.deepOrange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildControlCard(
                            theme,
                            title: 'تخصيص الصفحة الأولى (غلاف المنيو الرئيسي)',
                            subtitle:
                                'التحكم بالنصوص والعروض الظاهرة على غلاف المنيو الترحيبي',
                            icon: Icons.chrome_reader_mode_rounded,
                            children: [
                              TextField(
                                controller: _menuCoverTitleController,
                                decoration: const InputDecoration(
                                  labelText: 'عنوان الغلاف الرئيسي (Cover Title)',
                                  prefixIcon: Icon(Icons.title_rounded),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _menuCoverSubtitleController,
                                decoration: const InputDecoration(
                                  labelText: 'الوصف الترحيبي على الغلاف',
                                  prefixIcon: Icon(Icons.subtitles_rounded),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _menuOfferBadgeController,
                                decoration: const InputDecoration(
                                  labelText: 'شارة العرض الخاص (Offer Badge Text)',
                                  prefixIcon: Icon(Icons.local_offer_rounded),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _menuContactPhoneController,
                                decoration: const InputDecoration(
                                  labelText: 'رقم هاتف التواصل والتوصيل المباشر',
                                  prefixIcon: Icon(Icons.phone_rounded),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right Side: Live Digital Menu Mockup Preview
                  Expanded(
                    flex: 6,
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: theme.dividerColor.withOpacity(0.12)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 16),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Browser Frame Window Header Bar
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              border: Border(
                                  bottom: BorderSide(
                                      color:
                                          theme.dividerColor.withOpacity(0.1))),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                    radius: 5, backgroundColor: Color(0xFFEF4444)),
                                const SizedBox(width: 6),
                                const CircleAvatar(
                                    radius: 5, backgroundColor: Color(0xFFF59E0B)),
                                const SizedBox(width: 6),
                                const CircleAvatar(
                                    radius: 5, backgroundColor: Color(0xFF10B981)),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: theme.dividerColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => setState(() => _mockupPageView = 0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _mockupPageView == 0 ? Colors.deepOrange : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('📖 ص1: الغلاف', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _mockupPageView == 0 ? Colors.white : theme.textTheme.bodyMedium?.color)),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => setState(() => _mockupPageView = 1),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _mockupPageView == 1 ? Colors.deepOrange : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('🍽️ ص2: الأطباق', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _mockupPageView == 1 ? Colors.white : theme.textTheme.bodyMedium?.color)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () => setState(
                                      () => _mockupIsArabic = !_mockupIsArabic),
                                  child: Text(_mockupIsArabic ? 'English' : 'العربية',
                                      style: const TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          ),

                          // Live Menu Content (Cover Page or Inside Dishes Page)
                          Expanded(
                            child: _mockupPageView == 0
                                ? _buildCoverPageMockup(storeTheme)
                                : _buildLiveMenuMockup(storeTheme),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPageMockup(StoreTheme t) {
    Color primaryColor = t.primaryColorValue;
    Color bgColor = t.backgroundColorValue;
    Color surfaceColor = t.surfaceColorValue;
    Color textColor = t.textColorValue;

    if (_restaurantMenuThemeStyle == 'chalkboard') {
      bgColor = const Color(0xFF121212);
      surfaceColor = const Color(0xFF1A1A1E);
      textColor = const Color(0xFFF59E0B);
      primaryColor = const Color(0xFFFBBF24);
    } else if (_restaurantMenuThemeStyle == 'italiano') {
      bgColor = const Color(0xFF1E1E22);
      surfaceColor = const Color(0xFF27272A);
      textColor = Colors.white;
      primaryColor = const Color(0xFFF97316);
    }

    final coverTitle = _menuCoverTitleController.text.isNotEmpty
        ? _menuCoverTitleController.text
        : 'THE FOOD RESTO MENU';
    final coverSubtitle = _menuCoverSubtitleController.text.isNotEmpty
        ? _menuCoverSubtitleController.text
        : 'استمتع بأشهى وأجود الوجبات والمأكولات الطازجة اليوم';
    final offerBadge = _menuOfferBadgeController.text;
    final contactPhone = _menuContactPhoneController.text;

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Header: Logo & Restaurant Slogan
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  backgroundImage: NetworkImage(t.logoUrl ??
                      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=150'),
                ),
                const SizedBox(width: 10),
                Text(
                  _mockupIsArabic ? 'مطعم الفخامة الرقمي' : 'Luxurious Digital Resto',
                  style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Offer Badge
            if (offerBadge.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.4)),
                ),
                child: Text(
                  offerBadge,
                  style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                ),
              ),
            const SizedBox(height: 16),

            // Large Cover Title Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: t.cardBorderRadius,
                border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: primaryColor.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    coverTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: primaryColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    coverSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 11,
                        color: textColor.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hero Dish Image Collage
            ClipRRect(
              borderRadius: t.cardBorderRadius,
              child: Stack(
                children: [
                  Image.network(
                    t.coverBannerUrl ??
                        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            bgColor.withOpacity(0.8),
                            Colors.transparent,
                            bgColor.withOpacity(0.8)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _mockupPageView = 1),
                      icon: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 16),
                      label: Text(
                        _mockupIsArabic
                            ? 'تصفح قائمة الطعام والوجبات الآن 👈'
                            : 'Open Full Food Menu 👈',
                        style: TextStyle(
                            fontFamily: t.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: t.buttonBorderRadius),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Footer Contact Bar
            if (contactPhone.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_in_talk_rounded, size: 14, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'طلب وتوصيل مباشر: $contactPhone',
                      style: TextStyle(
                          fontFamily: t.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard(ThemeData theme,
      {required String title,
      required String subtitle,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepOrange, size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.textTheme.bodySmall?.color)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLayoutChip(String code, String label, IconData icon) {
    final isSel = _restaurantMenuLayout == code;
    return ChoiceChip(
      avatar: Icon(icon,
          size: 16, color: isSel ? Colors.white : Colors.deepOrange),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      selected: isSel,
      selectedColor: Colors.deepOrange,
      onSelected: (val) => setState(() => _restaurantMenuLayout = code),
    );
  }

  Widget _buildLiveMenuMockup(StoreTheme t) {
    Color primaryColor = t.primaryColorValue;
    Color bgColor = t.backgroundColorValue;
    Color surfaceColor = t.surfaceColorValue;
    Color textColor = t.textColorValue;

    if (_restaurantMenuThemeStyle == 'chalkboard') {
      bgColor = const Color(0xFF121212);
      surfaceColor = const Color(0xFF1A1A1E);
      textColor = const Color(0xFFF59E0B); // Amber / Gold
      primaryColor = const Color(0xFFFBBF24); // Bright Gold
    } else if (_restaurantMenuThemeStyle == 'italiano') {
      bgColor = const Color(0xFF1E1E22);
      surfaceColor = const Color(0xFF27272A);
      textColor = Colors.white;
      primaryColor = const Color(0xFFF97316); // Warm Amber Orange
    }

    final categories = ['الكل', 'المشويات والستيك', 'برجر وعصائر', 'مقبلات وسلطات'];
    final sampleMeals = [
      {
        'title': 'وجبة كباب بالكرز والزعفران',
        'desc': 'كباب لحم غنم طازج مشوي على الفحم مع صوص الكرز وزهر الزعفران.',
        'price': '\$24.99',
        'calories': '680 kcal',
        'allergen': '🌾 مكسرات',
        'image':
            'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
      },
      {
        'title': 'برجر عالي اللذة بصوص الترافل',
        'desc': 'شريحة واغيو مشوية مع جبن الشيدر المعتق وصوص الترافل الأسود.',
        'price': '\$18.50',
        'calories': '820 kcal',
        'allergen': '🥛 حليب',
        'image':
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      },
    ];

    return Directionality(
      textDirection: _mockupIsArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Menu
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: t.cardBorderRadius,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: primaryColor.withOpacity(0.15),
                      backgroundImage: NetworkImage(t.logoUrl ??
                          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=150'),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mockupIsArabic
                              ? 'مطعم الفخامة الرقمي'
                              : 'Luxurious Digital Menu',
                          style: TextStyle(
                              fontFamily: t.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                        if (_enableTableOrderQR)
                          Text('طاولة رقم 12 (Table #12)',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: textColor.withOpacity(0.5))),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.restaurant_menu_rounded,
                              size: 12, color: Colors.deepOrange),
                          SizedBox(width: 4),
                          Text('منيو مطعم',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Banner Header
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: t.cardBorderRadius,
                  image: DecorationImage(
                    image: NetworkImage(t.coverBannerUrl ??
                        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800'),
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
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: Text(
                    _mockupIsArabic
                        ? 'قائمة الطعام الطازجة اليوم'
                        : 'Fresh Daily Dishes Menu',
                    style: TextStyle(
                        fontFamily: t.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Menu Category Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(categories.length, (idx) {
                    final isSel = idx == 0;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? primaryColor : surfaceColor,
                          borderRadius: t.buttonBorderRadius,
                          border: Border.all(
                              color: isSel
                                  ? primaryColor
                                  : primaryColor.withOpacity(0.15)),
                        ),
                        child: Text(
                          categories[idx],
                          style: TextStyle(
                              fontFamily: t.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : textColor),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),

              // Dynamic Dishes Layout (Grid / List / Board)
              if (_restaurantMenuLayout == 'grid')
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: sampleMeals.map((meal) {
                    return SizedBox(
                      width: 175,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: t.cardBorderRadius,
                          border: Border.all(color: primaryColor.withOpacity(0.12)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(meal['image']!, height: 110, width: double.infinity, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 8),
                            Text(meal['title']!, style: TextStyle(fontFamily: t.fontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 4),
                            Text(meal['price']!, style: TextStyle(fontFamily: t.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (_showCaloriesBadges)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.deepOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: Text('🔥 ${meal['calories']}', style: const TextStyle(fontSize: 8, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                  ),
                                if (_showAllergensBadges) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: Text(meal['allergen']!, style: TextStyle(fontSize: 8, color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              else if (_restaurantMenuLayout == 'board')
                Column(
                  children: sampleMeals.map((meal) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: t.cardBorderRadius,
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
                                borderRadius: BorderRadius.vertical(top: Radius.circular(t.cardRadius)),
                                child: Image.network(meal['image']!, height: 120, width: double.infinity, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(10)),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.star_rounded, size: 12, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text('🌟 طبق الشيف الموصى به', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(meal['title']!, style: TextStyle(fontFamily: t.fontFamily, fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                                      const SizedBox(height: 2),
                                      Text(meal['desc']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: t.fontFamily, fontSize: 10, color: textColor.withOpacity(0.6))),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(meal['price']!, style: TextStyle(fontFamily: t.fontFamily, fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
                                    const SizedBox(height: 4),
                                    if (_showCaloriesBadges)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.deepOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                        child: Text('🔥 ${meal['calories']}', style: const TextStyle(fontSize: 8, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                // Default List Layout (قائمة أفقية)
                Column(
                  children: sampleMeals.map((meal) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: t.cardBorderRadius,
                        border: Border.all(color: primaryColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(meal['image']!, height: 70, width: 70, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meal['title']!, style: TextStyle(fontFamily: t.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(height: 2),
                              Text(meal['desc']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: t.fontFamily, fontSize: 10, color: textColor.withOpacity(0.6))),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(meal['price']!, style: TextStyle(fontFamily: t.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                                  const Spacer(),
                                  if (_showCaloriesBadges)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.deepOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                      child: Text('🔥 ${meal['calories']}', style: const TextStyle(fontSize: 8, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                    ),
                                  if (_showAllergensBadges) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                      child: Text(meal['allergen']!, style: TextStyle(fontSize: 8, color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
