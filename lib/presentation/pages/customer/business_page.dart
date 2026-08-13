import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_section.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_buisness.dart';
import '../../../data/models/store/business_model.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/locale_provider.dart';
import '../../global/translate/translation_keys.dart';
import '../../global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_buisness.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry_page.dart';
import 'package:z_ecommerce/presentation/global/theme/app_theme.dart';
import 'package:z_ecommerce/presentation/global/settings_provider.dart';
import '../../../data/providers/super_admin_provider.dart';

class BusinessPage extends StatefulWidget {
  const BusinessPage({super.key});

  @override
  State<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LocaleProvider>().locale.languageCode == 'ar';
    final settings = context.watch<SettingsProvider>();

    final bool isDark =
        settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final superAdminProvider = context.watch<SuperAdminProvider>();
    final themeAdmin = superAdminProvider.currentSuperAdmin?.themeAdmin;
    final dynamicTheme = AppTheme.getThemeFromAdmin(themeAdmin, isDark);

    return Theme(
      data: dynamicTheme,
      child: Scaffold(
        backgroundColor: dynamicTheme.scaffoldBackgroundColor,
        appBar: const HeaderBuisness(),
        body: Consumer<BusinessProvider>(
          builder: (context, businessProvider, child) {
            final businesses = businessProvider.businesses;

            if (businessProvider.isLoading && businesses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (businessProvider.errorMessage != null && businesses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      isAr ? 'حدث خطأ في تحميل البيانات' : 'Error loading data',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ButtonApp(
                      onPressed: () => businessProvider.fetchBusinesses(),
                      icon: Icons.refresh,
                      label: isAr ? 'إعادة المحاولة' : 'Retry',
                    ),
                  ],
                ),
              );
            }

            final filteredStores = businesses.where((b) {
              final nameAr = b.localization.name.ar.toLowerCase();
              final nameEn = b.localization.name.en.toLowerCase();
              final q = _searchQuery.toLowerCase();
              final matchesSearch = nameAr.contains(q) || nameEn.contains(q);
              final matchesCategory =
                  _selectedCategory == null ||
                  b.businessType.name == _selectedCategory;
              return matchesSearch && matchesCategory;
            }).toList();

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Page Title and Back Button
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: ButtonApp(
                                    format: FormatButtonApp.icon,
                                    icon: Icons.arrow_back,
                                    label: 'رجوع',
                                    color: Colors.black87,
                                    onPressed: () {
                                      changeScreenReplacement(
                                        context,
                                        const BusinessEntryPage(),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    isAr
                                        ? 'جميع الأعمال والمتاجر'
                                        : 'All Businesses & Stores',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Search Bar
                            TextField(
                              controller: _searchController,
                              onChanged: (value) =>
                                  setState(() => _searchQuery = value),
                              decoration: InputDecoration(
                                hintText: isAr
                                    ? 'ابحث عن متجر أو نشاط تجاري...'
                                    : 'Search for a store or business...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Categories Filter
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: BusinessType.values.length,
                                itemBuilder: (context, index) {
                                  final type = BusinessType.values[index];
                                  final isSelected =
                                      _selectedCategory == type.name;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: isAr ? 0 : 12,
                                      left: isAr ? 12 : 0,
                                    ),
                                    child: ChoiceChip(
                                      label: Row(
                                        children: [
                                          Icon(
                                            type.icon,
                                            size: 18,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(isAr ? type.ar : type.en),
                                        ],
                                      ),
                                      selected: isSelected,
                                      selectedColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      backgroundColor: Colors.grey[100],
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedCategory = selected
                                              ? type.name
                                              : null;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (filteredStores.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 40,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.storefront_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            isAr
                                                ? 'عذراً، لم يتم العثور على أي متجر يطابق بحثك.'
                                                : 'Sorry, no stores found matching your criteria.',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      int crossAxisCount = 1;
                                      if (constraints.maxWidth > 900) {
                                        crossAxisCount = 3;
                                      } else if (constraints.maxWidth > 600) {
                                        crossAxisCount = 2;
                                      }

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              childAspectRatio: 0.85,
                                              crossAxisSpacing: 32,
                                              mainAxisSpacing: 32,
                                            ),
                                        itemCount: filteredStores.length,
                                        itemBuilder: (context, index) {
                                          return StoreCard(
                                            business: filteredStores[index],
                                            isAr: isAr,
                                          );
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const FooterSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class StoreCard extends StatefulWidget {
  final BusinessModel business;
  final bool isAr;

  const StoreCard({super.key, required this.business, required this.isAr});

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  bool _isHovered = false;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final mockRating = (4.0 + (widget.business.id.hashCode % 10) / 10)
        .toStringAsFixed(1);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -10 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 20 : 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () {
              if (widget.business.isInactive) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.isAr
                          ? 'هذا المتجر غير نشط حالياً'
                          : 'This store is currently inactive',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              final businessProvider = Provider.of<BusinessProvider>(
                context,
                listen: false,
              );
              businessProvider.selectBusiness(widget.business.id);
              changeScreen(context, const HomePage());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.store,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: ButtonApp(
                            format: FormatButtonApp.icon,
                            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600],
                            label: 'إعجاب',
                            onPressed: () =>
                                setState(() => _isLiked = !_isLiked),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                mockRating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -1,
                        left: widget.isAr ? null : 20,
                        right: widget.isAr ? 20 : null,
                        child: Transform.translate(
                          offset: const Offset(0, 20),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ClipOval(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          widget.isAr
                              ? widget.business.localization.name.ar
                              : widget.business.localization.name.en,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.business.addAddress.isNotEmpty
                                    ? widget.business.addAddress.first.street
                                    : '',
                                style: TextStyle(color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.store,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.business.businessType.name,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _isHovered ? 48 : 0,
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: _isHovered ? 12 : 0,
                  ),
                  child: ButtonApp(
                    onPressed: () => changeScreen(context, const HomePage()),
                    label: widget.isAr ? 'زيارة المتجر' : 'Visit Store',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
