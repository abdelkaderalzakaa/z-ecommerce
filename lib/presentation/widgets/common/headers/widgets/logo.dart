import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/company_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    final companyData = context.watch<CompanyProvider>().companySettings;

    return Text(
      companyData?.name.get(context) ?? 'Z - Ecommerce',
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
  const Copyright({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final companyData = context.watch<CompanyProvider>().companySettings;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
      child: Center(
        child: Text(
          '©${DateTime.now().year} ${companyData?.name.get(context) ?? "Z - Ecommerce"} ${TranslationKeys.byAlzakaaSimpleSolutionsAllRightsReserved.tr(context)}',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
