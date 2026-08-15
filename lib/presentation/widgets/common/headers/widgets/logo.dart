import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class Logo extends StatelessWidget {
  final bool isPlatform;
  const Logo({super.key, this.isPlatform = false});

  @override
  Widget build(BuildContext context) {
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final superAdmin = context.watch<SuperAdminProvider>().currentSuperAdmin;
    final saName = superAdmin?.localizationAdmin.name.get(context);
    final platformName = (saName != null && saName.isNotEmpty) ? saName : 'z-matajer';
    
    final bName = isPlatform ? null : selectedBusiness?.localization.name.get(context);
    final displayName = (bName != null && bName.isNotEmpty) ? bName : platformName;

    return Text(
      displayName,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        letterSpacing: -0.5,
      ),
    );
  }
}

class Copyright extends StatelessWidget {
  final bool isPlatform;
  const Copyright({super.key, this.isPlatform = false});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final selectedBusiness = context.watch<BusinessProvider>().selectedBusiness;
    final superAdmin = context.watch<SuperAdminProvider>().currentSuperAdmin;
    final saName = superAdmin?.localizationAdmin.name.get(context);
    final platformName = (saName != null && saName.isNotEmpty) ? saName : 'z-matajer';
    
    final bName = isPlatform ? null : selectedBusiness?.localization.name.get(context);
    final displayName = (bName != null && bName.isNotEmpty) ? bName : platformName;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 10),
      child: Center(
        child: Text(
          '©${DateTime.now().year} $displayName ${TranslationKeys.byAlzakaaSimpleSolutionsAllRightsReserved.tr(context)}',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
