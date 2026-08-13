import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';

class IconButtonHeader extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;

  const IconButtonHeader({
    super.key,
    required this.icon,
    this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.isEmpty) {
      return ButtonApp(
        format: FormatButtonApp.icon,
        onPressed: onTap,
        icon: icon,
        label: 'أيقونة',
      );
    }

    return ButtonApp(
      format: FormatButtonApp.text,
      onPressed: onTap,
      icon: icon,
      label: label!,
    );
  }
}
