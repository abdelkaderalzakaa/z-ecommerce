import 'package:flutter/material.dart';
import '../../global/core/responsive/responsive_layout.dart';

class AuthCard extends StatelessWidget {
  final String? subtitle;
  final Widget? subtitleWidget;
  final List<Widget> children;
  final double maxWidth;

  const AuthCard({
    super.key,
    this.subtitle,
    this.subtitleWidget,
    required this.children,
    this.maxWidth = 460.0,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Center(
      child: Container(
        width: isMobile ? double.infinity : maxWidth,
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveLayout.horizontalPadding(context),
          vertical: 48,
        ),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 48),
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
            if (subtitleWidget != null) ...[
              if (subtitle == null) const SizedBox(height: 8),
              subtitleWidget!,
            ],
            const SizedBox(height: 32),
            ...children,
          ],
        ),
      ),
      ),
      ),
    );
  }
}
