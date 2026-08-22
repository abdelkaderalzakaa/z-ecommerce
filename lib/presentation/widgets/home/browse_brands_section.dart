import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../../data/providers/brand_provider.dart';
import '../../../data/models/product/brand_model.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../common/product_card.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/categories_page.dart';

class BrowseBrandsSection extends StatelessWidget {
  const BrowseBrandsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Consumer2<BrandProvider, BusinessProvider>(
      builder: (context, brandProvider, businessProvider, child) {
        final businessId = businessProvider.selectedBusiness.id;
        final brands = brandProvider.brands
            .where((b) => b.businessIds.contains(businessId) || b.isGlobal)
            .toList();
        if (brands.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: EdgeInsets.symmetric(horizontal: hPad),
          padding: EdgeInsets.all(isMobile ? 24 : 64),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: TranslationKeys.brands.tr(context)),
              const SizedBox(height: 40),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: brands
                    .map(
                      (brand) => _BrandCard(brand: brand, isMobile: isMobile),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandCard extends StatefulWidget {
  final BrandModel brand;
  final bool isMobile;

  const _BrandCard({required this.brand, required this.isMobile});

  @override
  State<_BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<_BrandCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          changeScreen(context, const CategoriesPage());
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.isMobile
              ? (MediaQuery.of(context).size.width / 2) - 48
              : 220,
          height: widget.isMobile ? 120 : 160,
          decoration: BoxDecoration(
            color: _isHovered
                ? Theme.of(context).primaryColor
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: _isHovered
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor,
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.brand.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.isMobile ? 16 : 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: _isHovered
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}
