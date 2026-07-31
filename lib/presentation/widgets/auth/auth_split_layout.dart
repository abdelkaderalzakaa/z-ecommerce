import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global/translate/localized_string.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../global/theme/theme_auth.dart';

class AuthSplitLayout extends StatelessWidget {
  final LocalizedString pageTitle;
  final LocalizedString pageSubtitle;
  final List<Widget> children;
  final AuthThemeConfig? customAuthTheme;

  const AuthSplitLayout({
    super.key,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.children,
    this.customAuthTheme,
  });

  @override
  Widget build(BuildContext context) {
    // Light-mode forced Theme Configuration
    final authTheme = customAuthTheme ?? const AuthThemeConfig();
    final isMobile = ResponsiveLayout.isMobile(context);

    final primaryColor = authTheme.primaryColor;
    final cardBgColor = authTheme.cardBackgroundColor;
    final bgCanvasColor = authTheme.backgroundColor;

    return Scaffold(
      backgroundColor: bgCanvasColor,
      body: SingleChildScrollView(
        child: Center(
          child: isMobile
              ? _buildFormSection(context, primaryColor, authTheme)
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Side - Visual Image & Quote Banner
                      Expanded(
                        flex: 5,
                        child: _buildVisualSection(context, authTheme),
                      ),
                      // Right Side - Form Section
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                          color: cardBgColor,
                          child: Center(
                            child: _buildFormSection(
                              context,
                              primaryColor,
                              authTheme,
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
    AuthThemeConfig authTheme,
  ) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.network(
            authTheme.sideImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF1E293B),
              child: const Icon(Icons.image, size: 64, color: Colors.white24),
            ),
          ),
        ),
        // Dark Overlay Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),
        ),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: authTheme.logoUrl.isNotEmpty
                    ? Image.network(
                        authTheme.logoUrl,
                        width: 28,
                        height: 28,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.hub,
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    : const Icon(
                        Icons.hub_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              Text(
                authTheme.brandName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
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
                authTheme.quoteText.get(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                authTheme.quoteAuthor.get(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                authTheme.quoteRole.get(context),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
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
    AuthThemeConfig authTheme,
  ) {
    // Auth UI is strictly Light Mode only
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: primaryColor,
        colorScheme: const ColorScheme.light().copyWith(primary: primaryColor),
        scaffoldBackgroundColor: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Header Page Title
              Text(
                pageTitle.get(context),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle Description
              Text(
                pageSubtitle.get(context),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              // Form Fields and Children
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
