import 'package:flutter/material.dart';
import '../translate/app_localizations.dart';
import '../translate/translation_keys.dart';
import 'app_table_column.dart';

/// Helper widget for rendering table empty states.
class TableEmptyState extends StatelessWidget {
  final String? emptyMessage;
  final Widget? emptyWidget;

  const TableEmptyState({super.key, this.emptyMessage, this.emptyWidget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: emptyWidget ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  emptyMessage ?? TranslationKeys.noDataAvailable.tr(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

/// Helper builders for column title headers and data row cells.
class TableRowDataHelper {
  /// Builds the column titles TableRow.
  static TableRow buildHeaderTableRow<T>({
    required ThemeData theme,
    required List<AppTableColumn<T>> columns,
    required bool selectable,
    required bool showIndexColumn,
    required bool allSelected,
    required ValueChanged<bool?> onToggleSelectAll,
    required int? sortColumnIndex,
    required bool sortAscending,
    required void Function(int columnIndex) onSort,
  }) {
    return TableRow(
      decoration: BoxDecoration(color: theme.cardColor),
      children: [
        if (selectable)
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 4,
              top: 12,
              bottom: 12,
            ),
            child: Checkbox(
              value: allSelected,
              onChanged: onToggleSelectAll,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        if (showIndexColumn)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.unfold_more,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ...List.generate(columns.length, (index) {
          final col = columns[index];
          final isSortedColumn = sortColumnIndex == index;

          return InkWell(
            onTap: col.sortable ? () => onSort(index) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
              child: Align(
                alignment: col.alignment,
                child: ClipRect(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          col.title.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: theme.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (col.sortable) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isSortedColumn
                              ? (sortAscending
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded)
                              : Icons.unfold_more_rounded,
                          size: 14,
                          color: isSortedColumn
                              ? theme.primaryColor
                              : theme.textTheme.bodySmall?.color?.withOpacity(
                                  0.5,
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Builds an individual data TableRow.
  static TableRow buildDataTableRow<T>({
    required ThemeData theme,
    required T item,
    required int rowIndex,
    required List<AppTableColumn<T>> columns,
    required bool selectable,
    required bool showIndexColumn,
    required bool isSelected,
    required int displayIndex,
    required ValueChanged<T> onToggleSelectItem,
    required void Function(T item)? onRowTap,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: isSelected ? theme.primaryColor.withOpacity(0.08) : Colors.white,
        border: Border(
          left: isSelected
              ? BorderSide(color: theme.primaryColor, width: 3.5)
              : BorderSide.none,
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      children: [
        if (selectable)
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 4,
              top: 12,
              bottom: 12,
            ),
            child: Checkbox(
              value: isSelected,
              onChanged: (_) => onToggleSelectItem(item),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        if (showIndexColumn)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$displayIndex',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ...List.generate(columns.length, (colIndex) {
          final col = columns[colIndex];
          return InkWell(
            onTap: onRowTap != null ? () => onRowTap(item) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Align(
                alignment: col.alignment,
                child: ClipRect(child: col.cellBuilder(item)),
              ),
            ),
          );
        }),
      ],
    );
  }
}
