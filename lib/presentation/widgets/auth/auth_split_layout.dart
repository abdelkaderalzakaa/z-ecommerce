import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global/translate/localized_string.dart';
import '../../../data/providers/business_provider.dart';
import '../../../data/providers/super_admin_provider.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../global/theme/app_theme.dart';
import '../../global/settings_provider.dart';
import '../../global/navigation.dart';
import '../../pages/customer/home_page.dart';

class AuthSplitLayout extends StatelessWidget {
  final LocalizedString pageTitle;
  final LocalizedString pageSubtitle;
  final List<Widget> children;

  const AuthSplitLayout({
    super.key,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final superAdminProvider = context.watch<SuperAdminProvider>();
    final superAdmin = superAdminProvider.currentSuperAdmin;
    final themeAdmin = superAdmin?.themeAdmin;
    final settings = context.watch<SettingsProvider>();

    final bool isDark = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final dynamicTheme = AppTheme.getThemeFromAdmin(themeAdmin, isDark);
    
    final isMobile = ResponsiveLayout.isMobile(context);
    final primaryColor = dynamicTheme.primaryColor;
    final bgCanvasColor = dynamicTheme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgCanvasColor,
      body: SingleChildScrollView(
          child: Center(
            child: isMobile
                ? _buildFormSection(context, primaryColor, dynamicTheme)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          dynamicTheme.scaffoldBackgroundColor,
                          dynamicTheme.cardColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Side - Visual Image & Quote Banner
                        Expanded(
                          flex: 5,
                          child: _buildVisualSection(context, dynamicTheme, primaryColor),
                        ),
                        Container(color: dynamicTheme.dividerColor, width: 1),
                        // Right Side - Form Section
                        Expanded(
                          flex: 6,
                          child: Container(
                            color: dynamicTheme.scaffoldBackgroundColor,
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: Center(
                              child: _buildFormSection(
                                context,
                                primaryColor,
                                dynamicTheme,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
    );
  }

  Widget _buildVisualSection(BuildContext context, ThemeData dynamicTheme, Color primaryColor) {
    final superAdmin = context.watch<SuperAdminProvider>().currentSuperAdmin;
    final logoUrl = superAdmin?.themeAdmin.logoUrl ?? '';
    final brandName = superAdmin?.localizationAdmin.name.get(context) ?? 'z-matajer';
    return Stack(
      children: [
        // Brand Header (Logo / Name)
        Positioned(
          top: 36,
          left: 36,
          right: 36,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: logoUrl.isNotEmpty
                    ? Image.network(
                        logoUrl,
                        width: 28,
                        height: 28,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.hub,
                          color: primaryColor,
                          size: 24,
                        ),
                      )
                    : Icon(
                        Icons.hub_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              Text(
                brandName,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        // Quote Card Overlay at Bottom
        Positioned(
          bottom: 36,
          left: 36,
          right: 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                superAdmin?.localizationAdmin.description.get(context) ?? 'سجل الآن لتجربة تسوق فريدة مع z-matajer. احصل على أفضل العروض والميزات الحصرية.',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'لماذا تسجل معنا؟',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'تسوق آمن، توصيل سريع، ودعم متواصل',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(
    BuildContext context,
    Color primaryColor,
    ThemeData dynamicTheme,
  ) {
    return Theme(
      data: dynamicTheme,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        changeScreenUntill(context, const HomePage());
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'رجوع',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      pageTitle.get(context),
                      style: TextStyle(
                        color: dynamicTheme.textTheme.bodyLarge?.color,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pageSubtitle.get(context),
                      style: TextStyle(
                        color: dynamicTheme.textTheme.bodyMedium?.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),
            // Form Fields and Children
            ...children,
          ],
        ),
      ),
    );
  }
}
