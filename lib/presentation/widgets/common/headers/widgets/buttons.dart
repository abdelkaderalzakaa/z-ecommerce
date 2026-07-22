import 'package:flutter/material.dart';
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
      return IconButton(
        onPressed: onTap,
        icon: Icon(icon),
      );
    }
    
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label!),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }
}
