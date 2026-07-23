import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_table_column.dart';
import 'header_footer_table.dart';
import 'row_data_table.dart';

/// A generic, responsive, unified Data Table widget for Flutter applications.
/// Features a pinned header (search & actions bar), pinned column titles row,
/// pinned pagination footer, and an internal vertical scrollable list for data rows.
class AppDataTable<T> extends StatefulWidget {
  /// List of items to display.
  final List<T> items;

  /// Column specifications for the table.
  final List<AppTableColumn<T>> columns;

  /// Flag indicating whether the table is loading data.
  final bool isLoading;

  /// Custom empty state message or widget.
  final String? emptyMessage;
  final Widget? emptyWidget;

  /// Callback when a row is clicked.
  final void Function(T item)? onRowTap;

  /// Enables checkbox selection column.
  final bool selectable;

  /// Shows index column (#) automatically when selectable or requested.
  final bool showIndexColumn;

  /// List of currently selected items.
  final List<T> selectedItems;

  /// Callback when item selection changes.
  final ValueChanged<List<T>>? onSelectionChanged;

  /// Callback when bulk delete is pressed in selection mode.
  final VoidCallback? onBulkDelete;

  /// Primary Action Button Widget on the top right (e.g. '+ Add store').
  final Widget? primaryActionButton;

  /// Custom search query controller / callback for built-in header search.
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;

  /// Pagination parameters.
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;
  final List<int> availableRowsPerPage;

  /// Minimum width constraint for horizontal scrolling on mobile/small screens.
  final double minWidth;

  const AppDataTable({
    super.key,
    required this.items,
    required this.columns,
    this.isLoading = false,
    this.emptyMessage,
    this.emptyWidget,
    this.onRowTap,
    this.selectable = true,
    this.showIndexColumn = true,
    this.selectedItems = const [],
    this.onSelectionChanged,
    this.onBulkDelete,
    this.primaryActionButton,
    this.searchQuery,
    this.onSearchChanged,
    this.onFilterTap,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.itemsPerPage = 10,
    this.onPageChanged,
    this.onItemsPerPageChanged,
    this.availableRowsPerPage = const [5, 10, 15, 20, 30, 40, 50],
    this.minWidth = 750.0,
  });

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<T> _displayedItems;
  late TextEditingController _searchController;
  late ScrollController _headerHorizontalScrollController;
  late ScrollController _bodyHorizontalScrollController;

  @override
  void initState() {
    super.initState();
    _displayedItems = List.from(widget.items);
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
    _headerHorizontalScrollController = ScrollController();
    _bodyHorizontalScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant AppDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _displayedItems = List.from(widget.items);
      if (_sortColumnIndex != null) {
        _applySort();
      }
    }
    if (oldWidget.searchQuery != widget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerHorizontalScrollController.dispose();
    _bodyHorizontalScrollController.dispose();
    super.dispose();
  }

  void _onSort(int columnIndex) {
    final column = widget.columns[columnIndex];
    if (!column.sortable || column.sortKey == null) return;

    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
      _applySort();
    });
  }

  void _applySort() {
    if (_sortColumnIndex == null) return;
    final column = widget.columns[_sortColumnIndex!];
    final sortKey = column.sortKey;
    if (sortKey == null) return;

    _displayedItems.sort((a, b) {
      final aValue = sortKey(a);
      final bValue = sortKey(b);
      final comparison = aValue.compareTo(bValue);
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _toggleSelectAll(bool? checked) {
    if (widget.onSelectionChanged == null) return;
    if (checked == true) {
      widget.onSelectionChanged!(List.from(_displayedItems));
    } else {
      widget.onSelectionChanged!([]);
    }
  }

  void _toggleSelectItem(T item) {
    if (widget.onSelectionChanged == null) return;
    final currentSelection = List<T>.from(widget.selectedItems);
    if (currentSelection.contains(item)) {
      currentSelection.remove(item);
    } else {
      currentSelection.add(item);
    }
    widget.onSelectionChanged!(currentSelection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = widget.selectedItems.isNotEmpty;
    final allSelected =
        widget.selectable &&
        _displayedItems.isNotEmpty &&
        widget.selectedItems.length == _displayedItems.length;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Pinned Top Header Bar Component
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TableHeaderBar(
              hasSelection: hasSelection,
              selectedCount: widget.selectedItems.length,
              onBulkDelete: widget.onBulkDelete,
              primaryActionButton: widget.primaryActionButton,
              searchController: _searchController,
              onSearchChanged: widget.onSearchChanged,
              onFilterTap: widget.onFilterTap,
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.12)),

          // Loading Progress Indicator
          if (widget.isLoading) const LinearProgressIndicator(minHeight: 3),

          // 2. Pinned Column Titles Header Row (Horizontal Scroll Synced)
          LayoutBuilder(
            builder: (context, constraints) {
              final calculatedWidth = math.max(
                constraints.maxWidth,
                widget.minWidth,
              );

              return SingleChildScrollView(
                controller: _headerHorizontalScrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: calculatedWidth,
                  child: Table(
                    columnWidths: _buildColumnWidths(),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRowDataHelper.buildHeaderTableRow<T>(
                        theme: theme,
                        columns: widget.columns,
                        selectable: widget.selectable,
                        showIndexColumn: widget.showIndexColumn,
                        allSelected: allSelected,
                        onToggleSelectAll: _toggleSelectAll,
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        onSort: _onSort,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.12)),

          // 3. Scrollable Data Rows Area (Internal Vertical Scroll + Synced Horizontal Scroll)
          Expanded(
            child: (!widget.isLoading && _displayedItems.isEmpty)
                ? TableEmptyState(
                    emptyMessage: widget.emptyMessage,
                    emptyWidget: widget.emptyWidget,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final calculatedWidth = math.max(
                        constraints.maxWidth,
                        widget.minWidth,
                      );

                      return NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.axis == Axis.horizontal &&
                              _headerHorizontalScrollController.hasClients) {
                            _headerHorizontalScrollController.jumpTo(
                              notification.metrics.pixels,
                            );
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          child: SingleChildScrollView(
                            controller: _bodyHorizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            child: SizedBox(
                              width: calculatedWidth,
                              child: Table(
                                columnWidths: _buildColumnWidths(),
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: List.generate(
                                  _displayedItems.length,
                                  (rowIndex) {
                                    final item = _displayedItems[rowIndex];
                                    final isSelected = widget.selectedItems
                                        .contains(item);
                                    final displayIndex =
                                        (widget.currentPage - 1) *
                                            widget.itemsPerPage +
                                        (rowIndex + 1);

                                    return TableRowDataHelper.buildDataTableRow<
                                      T
                                    >(
                                      theme: theme,
                                      item: item,
                                      rowIndex: rowIndex,
                                      columns: widget.columns,
                                      selectable: widget.selectable,
                                      showIndexColumn: widget.showIndexColumn,
                                      isSelected: isSelected,
                                      displayIndex: displayIndex,
                                      onToggleSelectItem: _toggleSelectItem,
                                      onRowTap: widget.onRowTap,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // 4. Pinned Bottom Footer Pagination Bar Component
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.12)),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10.0,
            ),
            child: TableFooterPaginationBar(
              currentPage: widget.currentPage,
              totalPages: widget.totalPages,
              totalItems: widget.totalItems > 0
                  ? widget.totalItems
                  : widget.items.length,
              itemsPerPage: widget.itemsPerPage,
              onPageChanged: widget.onPageChanged,
              onItemsPerPageChanged: widget.onItemsPerPageChanged,
              availableRowsPerPage: widget.availableRowsPerPage,
            ),
          ),
        ],
      ),
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths() {
    final map = <int, TableColumnWidth>{};
    int offset = 0;

    if (widget.selectable) {
      map[0] = const FixedColumnWidth(48);
      offset++;
    }
    if (widget.showIndexColumn) {
      map[offset] = const FixedColumnWidth(54);
      offset++;
    }

    for (int i = 0; i < widget.columns.length; i++) {
      final col = widget.columns[i];
      if (col.width != null) {
        map[i + offset] = FixedColumnWidth(col.width!);
      } else {
        map[i + offset] = FlexColumnWidth(col.flex.toDouble());
      }
    }

    return map;
  }
}
