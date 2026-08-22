import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global/core/constants/app_constants.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/providers/product_filter_provider.dart';
import '../../../data/providers/like_provider.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class CategoriesHeader extends StatefulWidget {
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
  State<CategoriesHeader> createState() => _CategoriesHeaderState();
}

class _CategoriesHeaderState extends State<CategoriesHeader> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final filterProvider = context.read<ProductFilterProvider>();
    _searchController = TextEditingController(text: filterProvider.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer3<ProductProvider, ProductFilterProvider, LikeProvider>(
      builder: (context, productProvider, filterProvider, likeProvider, child) {
        final activeCount = filterProvider.activeFiltersCount;

        // Keep search controller in sync if cleared from sidebar
        if (_searchController.text != filterProvider.searchQuery) {
          _searchController.text = filterProvider.searchQuery;
        }

        final searchField = TextField(
          controller: _searchController,
          onChanged: (val) => filterProvider.setSearchQuery(val),
          decoration: InputDecoration(
            hintText: TranslationKeys.search.tr(context),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      filterProvider.setSearchQuery('');
                    },
                  )
                : null,
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide(color: theme.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        );

        if (widget.isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: widget.onFilterTap,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(
                              AppRadius.input,
                            ),
                          ),
                          child: const Icon(
                            Icons.tune,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        if (activeCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$activeCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return searchField;
      },
    );
  }
}
