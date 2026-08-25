import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/super_admin/platform_settings.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class PlatformFeaturesPage extends StatefulWidget {
  const PlatformFeaturesPage({super.key});

  @override
  State<PlatformFeaturesPage> createState() => _PlatformFeaturesPageState();
}

class _PlatformFeaturesPageState extends State<PlatformFeaturesPage> {
  final _formKey = GlobalKey<FormState>();

  // Feature Flags
  late bool _enableLikes;
  late bool _enableReviews;
  late bool _enableFollows;

  // Section Visibility
  late bool _showCategoriesSection;
  late bool _showFeaturedBusinessesSection;
  late bool _showFeaturedOffersSection;
  late bool _showFeaturedProductsSection;
  late bool _showKpiCardsSection;
  late bool _showJoinFamilyBanner;

  // Allowed Business Types
  late List<String> _allowedBusinessTypes;

  final List<(String, String)> _allBusinessTypes = const [
    ('retail', 'متاجر التجزئة والأزياء'),
    ('restaurant', 'المطاعم والكافيهات'),
    ('grocery', 'السوبرماركت والمواد الغذائية'),
    ('pharmacy', 'الصيدليات والمستلزمات الطبية'),
    ('electronics', 'الإلكترونيات والأجهزة'),
    ('services', 'الخدمات العامة والاستشارات'),
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SuperAdminProvider>().platformSettings;
    _enableLikes = settings.enableLikes;
    _enableReviews = settings.enableReviews;
    _enableFollows = settings.enableFollows;

    _showCategoriesSection = settings.showCategoriesSection;
    _showFeaturedBusinessesSection = settings.showFeaturedBusinessesSection;
    _showFeaturedOffersSection = settings.showFeaturedOffersSection;
    _showFeaturedProductsSection = settings.showFeaturedProductsSection;
    _showKpiCardsSection = settings.showKpiCardsSection;
    _showJoinFamilyBanner = settings.showJoinFamilyBanner;

    _allowedBusinessTypes = List.from(settings.allowedBusinessTypes);
    if (_allowedBusinessTypes.isEmpty) {
      _allowedBusinessTypes = _allBusinessTypes.map((e) => e.$1).toList();
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<SuperAdminProvider>();
      final updatedSettings = provider.platformSettings.copyWith(
        enableLikes: _enableLikes,
        enableReviews: _enableReviews,
        enableFollows: _enableFollows,
        showCategoriesSection: _showCategoriesSection,
        showFeaturedBusinessesSection: _showFeaturedBusinessesSection,
        showFeaturedOffersSection: _showFeaturedOffersSection,
        showFeaturedProductsSection: _showFeaturedProductsSection,
        showKpiCardsSection: _showKpiCardsSection,
        showJoinFamilyBanner: _showJoinFamilyBanner,
        allowedBusinessTypes: _allowedBusinessTypes,
      );

      await provider.updatePlatformSettings(updatedSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.toggle_on_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('تم حفظ إعدادات الميزات والسكاشن بنجاح!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحفظ: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddEditTemplate(
      title: 'التحكم بالسكاشن وميزات المنصة',
      subtitle: 'تفعيل أو تعطيل الأقسام التفاعلية في الواجهة العامة والتحكم بالأنشطة التجارية المسموحة.',
      isEditMode: true,
      formKey: _formKey,
      isSubmitting: _isSubmitting,
      submitLabel: 'حفظ وتطبيق الميزات',
      onSubmit: _handleSubmit,
      sections: [
        FormSection(
          title: 'الميزات التفاعلية العامة (Interactive Features)',
          subtitle: 'السماح للعملاء بالتفاعل مع المتاجر والمنتجات',
          icon: Icons.thumb_up_alt_rounded,
          fields: [
            SwitchListTile(
              title: const Text('تفعيل الإعجابات (Likes)'),
              subtitle: const Text('إتاحة إمكانية إعجاب الزوار بالمنتجات والمتاجر'),
              value: _enableLikes,
              onChanged: (v) => setState(() => _enableLikes = v),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('تفعيل التقييمات والمراجعات (Reviews)'),
              subtitle: const Text('إتاحة كتابة المراجعات والتقييمات للطلبات والمنتجات'),
              value: _enableReviews,
              onChanged: (v) => setState(() => _enableReviews = v),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('تفعيل متابعة المتاجر (Follows)'),
              subtitle: const Text('إتاحة متابعة العملاء لمتاجرهم المفضلة'),
              value: _enableFollows,
              onChanged: (v) => setState(() => _enableFollows = v),
            ),
          ],
        ),
        FormSection(
          title: 'ظهور السكاشن في الواجهة الرئيسية (Home Sections Visibility)',
          subtitle: 'التحكم بظهور الأقسام في واجهة دليل المتاجر والصفحة الرئيسية',
          icon: Icons.view_quilt_rounded,
          fields: [
            SwitchListTile(
              title: const Text('سكشن الفئات والتصنيفات (Categories Section)'),
              value: _showCategoriesSection,
              onChanged: (v) => setState(() => _showCategoriesSection = v),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('سكشن المتاجر المميزة (Featured Businesses)'),
              value: _showFeaturedBusinessesSection,
              onChanged: (v) => setState(() => _showFeaturedBusinessesSection = v),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('سكشن العروض والخصومات (Featured Offers)'),
              value: _showFeaturedOffersSection,
              onChanged: (v) => setState(() => _showFeaturedOffersSection = v),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('سكشن المنتجات المميزة (Featured Products)'),
              value: _showFeaturedProductsSection,
              onChanged: (v) => setState(() => _showFeaturedProductsSection = v),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('سكشن بطاقات الإحصائيات (KPI Cards)'),
              value: _showKpiCardsSection,
              onChanged: (v) => setState(() => _showKpiCardsSection = v),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('بانر انضمام التجار (Join Family Banner)'),
              value: _showJoinFamilyBanner,
              onChanged: (v) => setState(() => _showJoinFamilyBanner = v),
            ),
          ],
        ),
        FormSection(
          title: 'أنواع الأنشطة التجارية المعتمدة في المنصة',
          subtitle: 'تحديد القطاعات التي يمكن للتجار إنشاء متاجرهم تحتها',
          icon: Icons.category_rounded,
          fields: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allBusinessTypes.map((type) {
                final isSelected = _allowedBusinessTypes.contains(type.$1);
                return FilterChip(
                  label: Text(type.$2),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _allowedBusinessTypes.add(type.$1);
                      } else {
                        if (_allowedBusinessTypes.length > 1) {
                          _allowedBusinessTypes.remove(type.$1);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
