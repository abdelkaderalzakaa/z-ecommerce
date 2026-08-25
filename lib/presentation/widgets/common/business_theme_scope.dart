import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_theme.dart';

/// نطاق خاص لعزل وتطبيق ثيم المتجر الخاص على واجهاته الداخلية فقط
/// دون التأثير على الواجهات العامة أو لوحة السوبر أدمن أو واجهات المصادقة
class BusinessThemeScope extends StatelessWidget {
  final Widget child;
  final BusinessModel? explicitBusiness;

  const BusinessThemeScope({
    super.key,
    required this.child,
    this.explicitBusiness,
  });

  @override
  Widget build(BuildContext context) {
    final business = explicitBusiness ?? context.watch<BusinessProvider>().selectedBusiness;

    if (business.isEmpty) {
      return child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storeTheme = AppTheme.getThemeFromAdmin(business.theme, isDark);

    return Theme(
      data: storeTheme,
      child: child,
    );
  }
}
