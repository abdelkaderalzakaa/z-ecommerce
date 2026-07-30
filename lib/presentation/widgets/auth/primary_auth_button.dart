import 'package:flutter/material.dart';
import '../../global/theme/theme_auth.dart';

class PrimaryAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final AuthThemeConfig? customAuthTheme;

  const PrimaryAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.customAuthTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = customAuthTheme ?? const AuthThemeConfig();

    return Container(
      width: double.infinity,
      height: theme.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.buttonBorderRadius),
        gradient: theme.enableButtonGradient
            ? LinearGradient(
                colors: [theme.primaryColor, theme.buttonGradientEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: theme.enableButtonGradient ? null : theme.primaryColor,
        boxShadow: theme.buttonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(theme.buttonBorderRadius),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    label,
                    style: theme.buttonTextStyle ??
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
