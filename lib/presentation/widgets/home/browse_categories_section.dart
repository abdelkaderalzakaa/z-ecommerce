import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/category_model.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/providers/business_provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../pages/customer/categories_page.dart';
import '../common/product_card.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class BrowseCategoriesSection extends StatelessWidget {
  const BrowseCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: hPad),
          padding: EdgeInsets.all(isMobile ? 24 : 64),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            children: [
              SectionHeader(title: TranslationKeys.browseByCategory.tr(context)),
              const SizedBox(height: 40),
              isMobile
                  ? _MobileCategoryGrid(categories: categories)
                  : _DesktopCategoryGrid(categories: categories),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopCategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  const _DesktopCategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: _CategoryCard(data: categories[0], height: 290),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 6,
              child: _CategoryCard(data: categories[1], height: 290),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 6,
              child: _CategoryCard(data: categories[2], height: 290),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: _CategoryCard(data: categories[3], height: 290),
            ),
          ],
        ),
      ],
    );
  }
}

class _MobileCategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  const _MobileCategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _CategoryCard(data: categories[0], height: 190)),
            const SizedBox(width: 12),
            Expanded(child: _CategoryCard(data: categories[1], height: 190)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _CategoryCard(data: categories[2], height: 190)),
            const SizedBox(width: 12),
            Expanded(child: _CategoryCard(data: categories[3], height: 190)),
          ],
        ),
      ],
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final CategoryModel data;
  final double height;

  const _CategoryCard({required this.data, required this.height});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          changeScreen(context, const CategoriesPage());
        },
        child: Card(
          margin: EdgeInsets.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered ? Theme.of(context).primaryColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Icon(
                      widget.data.icon ?? Icons.category_outlined,
                      size: 80,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  left: 24,
                  child: Text(
                    widget.data.label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  bottom: _hovered ? 24 : 20,
                  right: 24,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Theme.of(context).scaffoldBackgroundColor,
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
}
