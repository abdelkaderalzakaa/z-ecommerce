import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import '../translate/app_localizations.dart';
import '../translate/translation_keys.dart';

/// Top Header Bar Widget (Supports normal state and active selection state)
class TableHeaderBar extends StatelessWidget {
  final bool hasSelection;
  final int selectedCount;
  final VoidCallback? onBulkDelete;
  final Widget? primaryActionButton;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;

  const TableHeaderBar({
    super.key,
    required this.hasSelection,
    required this.selectedCount,
    this.onBulkDelete,
    this.primaryActionButton,
    this.searchController,
    this.onSearchChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: hasSelection
            ? _buildSelectionHeaderBar(context, theme)
            : _buildNormalHeaderBar(context, theme),
      ),
    );
  }

  Widget _buildNormalHeaderBar(BuildContext context, ThemeData theme) {
    return Row(
      key: const ValueKey('normalHeader'),
      children: [
        if (onFilterTap != null) ...[
          OutlinedButton(
            onPressed: onFilterTap,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
            ),
            child: const Icon(Icons.tune_outlined, size: 20),
          ),
          const SizedBox(width: 12),
        ],
        if (onSearchChanged != null && searchController != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Material(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: TranslationKeys.searchPlaceholder.tr(context),
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        if (primaryActionButton != null) ...[primaryActionButton!],
      ],
    );
  }

  Widget _buildSelectionHeaderBar(BuildContext context, ThemeData theme) {
    return Row(
      key: const ValueKey('selectionHeader'),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$selectedCount ${TranslationKeys.selectedCountText.tr(context)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: theme.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ButtonApp(
          format: FormatButtonApp.icon,
          icon: Icons.delete_outline,
          color: Colors.red,
          label: TranslationKeys.deleteSelected.tr(context),
          onPressed: onBulkDelete,
        ),
        const Spacer(),
        if (primaryActionButton != null) ...[primaryActionButton!],
      ],
    );
  }
}

/// Bottom Footer Pagination Bar Widget
class TableFooterPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;
  final List<int> availableRowsPerPage;

  const TableFooterPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    this.onPageChanged,
    this.onItemsPerPageChanged,
    this.availableRowsPerPage = const [5, 10, 15, 20, 30, 40, 50],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Range Info Text
        Text(
          _computeRangeString(context),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const Spacer(),

        // Rows Per Page Selector Dropdown
        Row(
          children: [
            Text(
              TranslationKeys.rowsPerPage.tr(context),
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<int>(
              initialValue: itemsPerPage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '$itemsPerPage',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
              onSelected: (rows) {
                if (onItemsPerPageChanged != null) {
                  onItemsPerPageChanged!(rows);
                }
              },
              itemBuilder: (context) => availableRowsPerPage
                  .map(
                    (rows) => PopupMenuItem<int>(
                      value: rows,
                      height: 32,
                      child: Text(
                        '$rows',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: itemsPerPage == rows
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: itemsPerPage == rows
                              ? theme.primaryColor
                              : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Page Switcher Controls
        Row(
          children: [
            InkWell(
              onTap: (currentPage > 1 && onPageChanged != null)
                  ? () => onPageChanged!(currentPage - 1)
                  : null,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: currentPage > 1
                      ? theme.textTheme.bodyLarge?.color
                      : theme.disabledColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '$currentPage/${totalPages > 0 ? totalPages : 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            InkWell(
              onTap: (currentPage < totalPages && onPageChanged != null)
                  ? () => onPageChanged!(currentPage + 1)
                  : null,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: currentPage < totalPages
                      ? theme.textTheme.bodyLarge?.color
                      : theme.disabledColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _computeRangeString(BuildContext context) {
    final ofStr = TranslationKeys.ofText.tr(context);
    if (totalItems == 0) return '0 $ofStr 0';

    final start = (currentPage - 1) * itemsPerPage + 1;
    final end = (start + itemsPerPage - 1).clamp(1, totalItems);
    return '$start-$end $ofStr $totalItems';
  }
}
