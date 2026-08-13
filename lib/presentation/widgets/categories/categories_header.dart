import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class CategoriesHeader extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onFilterTap;
  final String title;
  final String? categoryLabel;
  final String? brandName;
  final bool onSale;

  const CategoriesHeader({
    super.key,
    required this.isMobile,
    required this.onFilterTap,
    required this.title,
    this.categoryLabel,
    this.brandName,
    this.onSale = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductProvider, CategoryProvider>(
      builder: (context, provider, categoryProvider, child) {
        final totalItems = provider.allProducts.length;
        final showingText = '$totalItems items';

        final searchField = TextField(
          decoration: InputDecoration(
            hintText: TranslationKeys.search.tr(context),
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onFilterTap,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                      ),
                      child: const Icon(
                        Icons.tune,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                showingText,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Expanded(child: searchField)]),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  showingText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
