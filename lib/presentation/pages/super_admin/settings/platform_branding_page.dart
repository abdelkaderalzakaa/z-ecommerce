import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import 'package:z_ecommerce/presentation/widgets/common/custom_network_image.dart';
import 'package:z_ecommerce/presentation/widgets/templates/add_edit_template.dart';

class PlatformBrandingPage extends StatefulWidget {
  const PlatformBrandingPage({super.key});

  @override
  State<PlatformBrandingPage> createState() => _PlatformBrandingPageState();
}

class _PlatformBrandingPageState extends State<PlatformBrandingPage> {
  final _formKey = GlobalKey<FormState>();

  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _backgroundColor;
  late Color _surfaceColor;
  late TextEditingController _logoUrlController;
  late String _fontFamily;
  late double _buttonRadius;
  late double _cardRadius;
  late double _inputRadius;

  bool _isSubmitting = false;

  final List<Color> _primaryPresets = const [
    Color(0xFF1E3A8A), // Deep Blue
    Color(0xFF0F766E), // Teal
    Color(0xFF7C3AED), // Violet
    Color(0xFFBE123C), // Rose / Red
    Color(0xFF111827), // Slate Black
    Color(0xFFD97706), // Amber Orange
  ];

  final List<Color> _secondaryPresets = const [
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald Green
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF6366F1), // Indigo
    Color(0xFFEF4444), // Crimson
  ];

  final List<String> _fontOptions = const [
    'Cairo',
    'Tajawal',
    'Almarai',
    'Inter',
    'Roboto',
  ];

  @override
  void initState() {
    super.initState();
    final theme = context.read<SuperAdminProvider>().platformTheme;
    _primaryColor = theme.primaryColorValue;
    _secondaryColor = theme.secondaryColorValue;
    _backgroundColor = theme.backgroundColorValue;
    _surfaceColor = theme.surfaceColorValue;
    _logoUrlController = TextEditingController(text: theme.logoUrl ?? '');
    _fontFamily = theme.fontFamily.isNotEmpty ? theme.fontFamily : 'Cairo';
    _buttonRadius = theme.buttonRadius;
    _cardRadius = theme.cardRadius;
    _inputRadius = theme.inputRadius;
  }

  @override
  void dispose() {
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      final currentTheme = context.read<SuperAdminProvider>().platformTheme;
      final primaryHex = '#${_primaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
      final secondaryHex = '#${_secondaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
      final bgHex = '#${_backgroundColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
      final surfaceHex = '#${_surfaceColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

      final updatedTheme = currentTheme.copyWith(
        primaryColor: primaryHex,
        secondaryColor: secondaryHex,
        darkPrimaryColor: primaryHex,
        darkSecondaryColor: secondaryHex,
        backgroundColor: bgHex,
        surfaceColor: surfaceHex,
        logoUrl: _logoUrlController.text.trim(),
        fontFamily: _fontFamily,
        buttonRadius: _buttonRadius,
        cardRadius: _cardRadius,
        inputRadius: _inputRadius,
      );

      await context.read<SuperAdminProvider>().updatePlatformTheme(updatedTheme);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.palette_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('تم حفظ وتحديث هوية وثيم المنصة بنجاح!'),
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
    final platformName = context.watch<SuperAdminProvider>().platformLocalization.name.get(context);

    return AddEditTemplate(
      title: 'تخصيص الهوية البصرية والثيم',
      subtitle: 'التحكم بالألوان الرئيسية للمنصة، رابط اللوجو، الخطوط، وانحناءات الحواف.',
      isEditMode: true,
      formKey: _formKey,
      isSubmitting: _isSubmitting,
      submitLabel: 'حفظ وتطبيق الثيم',
      onSubmit: _handleSubmit,
      sections: [
        FormSection(
          title: 'اللون الأساسي (Primary Color)',
          subtitle: 'لون الأزرار، الترويسة، والعناصر التفاعلية البارزة',
          icon: Icons.color_lens_rounded,
          fields: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _primaryPresets.map((c) {
                final isSelected = _primaryColor.value == c.value;
                return GestureDetector(
                  onTap: () => setState(() => _primaryColor = c),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        FormSection(
          title: 'اللون الثانوي (Secondary Color)',
          subtitle: 'لون الشارات الترويجية، التقييمات، والتأكيدات',
          icon: Icons.star_half_rounded,
          fields: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _secondaryPresets.map((c) {
                final isSelected = _secondaryColor.value == c.value;
                return GestureDetector(
                  onTap: () => setState(() => _secondaryColor = c),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        FormSection(
          title: 'الشعار والخط (Logo & Typography)',
          subtitle: 'رابط الشعار الرسمي ونوع الخط العربي للمنصة',
          icon: Icons.image_rounded,
          fields: [
            AuthTextField(
              controller: _logoUrlController,
              label: 'رابط صورة اللوجو (Logo URL)',
              hintText: 'https://example.com/logo.png',
              prefixIcon: Icons.link_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text(
              'نوع الخط المعتمد (Font Family):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _fontOptions.map((f) {
                final isSelected = _fontFamily == f;
                return ChoiceChip(
                  label: Text(f),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _fontFamily = f);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        FormSection(
          title: 'انحناء الحواف (Border Radiuses)',
          subtitle: 'درجة استدارة حواف الأزرار والبطاقات والحقول',
          icon: Icons.rounded_corner_rounded,
          fields: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('انحناء الأزرار (${_buttonRadius.toInt()}px):'),
                      Slider(
                        value: _buttonRadius,
                        min: 0,
                        max: 30,
                        divisions: 30,
                        activeColor: _primaryColor,
                        onChanged: (v) => setState(() => _buttonRadius = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('انحناء البطاقات (${_cardRadius.toInt()}px):'),
                      Slider(
                        value: _cardRadius,
                        min: 0,
                        max: 32,
                        divisions: 32,
                        activeColor: _primaryColor,
                        onChanged: (v) => setState(() => _cardRadius = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        FormSection(
          title: 'المعاينة الحية (Live Preview)',
          subtitle: 'شكل الهوية والألوان والأزرار على أرض الواقع',
          icon: Icons.preview_rounded,
          fields: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(_cardRadius),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(_buttonRadius),
                    ),
                    child: _logoUrlController.text.isNotEmpty
                        ? CustomNetworkImage(
                            imageUrl: _logoUrlController.text,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.storefront_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platformName.isNotEmpty ? platformName : 'زد للمتاجر',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: _secondaryColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'الشارة الثانوية باللون المخصص',
                              style: TextStyle(fontSize: 12, color: _secondaryColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_buttonRadius),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('زر أساسي'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
