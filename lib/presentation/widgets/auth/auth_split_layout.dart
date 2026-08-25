import 'package:z_ecommerce/presentation/widgets/common/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/settings_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/theme/app_colors.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/pages/customer/home_page.dart';

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
    final theme = Theme.of(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final superAdminProvider = context.watch<SuperAdminProvider>();
    final platformPrimary = superAdminProvider.platformTheme.primaryColorValue;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: isMobile
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: _buildFormSection(context, platformPrimary, theme),
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Side - Visual Banner Section
                      Expanded(
                        flex: 5,
                        child: _buildVisualSection(
                          context,
                          theme,
                          platformPrimary,
                        ),
                      ),
                      Container(color: AppColors.cardBorder, width: 1),

                      // Right Side - Form Section
                      Expanded(
                        flex: 6,
                        child: Container(
                          color: theme.scaffoldBackgroundColor,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 500),
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.cardBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadowColor.withOpacity(0.06),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: _buildFormSection(
                                context,
                                platformPrimary,
                                theme,
                              ),
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

  Widget _buildVisualSection(
    BuildContext context,
    ThemeData theme,
    Color primaryColor,
  ) {
    final superAdminProvider = context.watch<SuperAdminProvider>();
    final logoUrl = superAdminProvider.platformTheme.logoUrl ?? '';
    final saName = superAdminProvider.platformLocalization.name.get(context);
    final brandName = saName.isNotEmpty ? saName : 'Z-MATAJER';

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
            theme.scaffoldBackgroundColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Logo & Brand Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: logoUrl.isNotEmpty
                    ? CustomNetworkImage(imageUrl: 
                        logoUrl,
                        width: 32,
                        height: 32,
                        errorBuilder: (_, _, _) =>
                            Icon(Icons.storefront_rounded, color: primaryColor, size: 28),
                      )
                    : Icon(Icons.storefront_rounded, color: primaryColor, size: 28),
              ),
              const SizedBox(width: 14),
              Text(
                brandName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          // Central Hero Illustration / Badge Feature Highlight
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.security_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "تسوق آمن وحماية كاملة للبيانات",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "منصة متكاملة تربط المتاجر بالعملاء بتجربة شحن وتصفح موثوقة.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Quote Card Overlay
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  superAdminProvider.platformLocalization.description.get(context).isNotEmpty
                      ? superAdminProvider.platformLocalization.description.get(context)
                      : 'انضم اليوم لتجربة تسوق سريعة وموثوقة واستكشف آلاف المنتجات والمتاجر الممتازة.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.verified_rounded, color: Colors.amber, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "منصة تجارية موثوقة ومعتمدة",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(
    BuildContext context,
    Color primaryColor,
    ThemeData theme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ButtonApp(
              format: FormatButtonApp.icon,
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  changeScreenUntill(context, const HomePage());
                }
              },
              icon: Icons.arrow_back,
              label: '',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pageTitle.get(context),
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pageSubtitle.get(context),
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }
}
