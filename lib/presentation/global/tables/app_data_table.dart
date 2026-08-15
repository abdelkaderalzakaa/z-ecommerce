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

  /// Custom empty state message.
  final String? emptyMessage;

  /// Callback when a row is clicked.
  final void Function(T item)? onRowTap;

  /// Enables checkbox selection column.
  final bool selectable;

  /// Shows index column (#) automatically when selectable or requested.
  final bool showIndexColumn;

  /// Callback when bulk delete is pressed in selection mode. Passes selected items.
  final void Function(List<T> selectedItems)? onBulkDelete;

  /// Primary Action Button Widget on the top right (e.g. '+ Add store').
  final Widget? primaryActionButton;

  /// Matcher function for internal search filtering.
  final bool Function(T item, String query)? searchMatcher;
  final VoidCallback? onFilterTap;

  /// Minimum width constraint for horizontal scrolling on mobile/small screens.
  final double minWidth;

  const AppDataTable({
    super.key,
    required this.items,
    required this.columns,
    this.isLoading = false,
    this.emptyMessage,
    this.onRowTap,
    this.selectable = true,
    this.showIndexColumn = true,
    this.onBulkDelete,
    this.primaryActionButton,
    this.searchMatcher,
    this.onFilterTap,
    this.minWidth = 750.0,
  });

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late TextEditingController _searchController;
  late ScrollController _headerHorizontalScrollController;
  late ScrollController _bodyHorizontalScrollController;

  int _currentPage = 1;
  int _itemsPerPage = 10;
  final List<T> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _headerHorizontalScrollController = ScrollController();
    _bodyHorizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerHorizontalScrollController.dispose();
    _bodyHorizontalScrollController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    List<T> list = List.from(widget.items);

    // Apply sorting if configured
    if (_sortColumnIndex != null) {
      final column = widget.columns[_sortColumnIndex!];
      final sortKey = column.sortKey;
      if (sortKey != null) {
        list.sort((a, b) {
          final aValue = sortKey(a);
          final bValue = sortKey(b);
          final comparison = aValue.compareTo(bValue);
          return _sortAscending ? comparison : -comparison;
        });
      }
    }

    // Apply search filter if query is present
    if (query.isNotEmpty && widget.searchMatcher != null) {
      list = list.where((item) => widget.searchMatcher!(item, query)).toList();
    }
    return list;
  }

  List<T> get _paginatedItems {
    final list = _filteredItems;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= list.length) return [];
    final endIndex = (startIndex + _itemsPerPage).clamp(0, list.length);
    return list.sublist(startIndex, endIndex);
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
    });
  }

  void _toggleSelectAll(bool? checked) {
    setState(() {
      _selectedItems.clear();
      if (checked == true) {
        _selectedItems.addAll(_filteredItems);
      }
    });
  }

  void _toggleSelectItem(T item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredItems;
    final paginated = _paginatedItems;

    final totalItems = filtered.length;
    final totalPages = (totalItems / _itemsPerPage).ceil();

    final hasSelection = _selectedItems.isNotEmpty;
    final allSelected =
        widget.selectable &&
        paginated.isNotEmpty &&
        _selectedItems.length >= filtered.length;

    const tableBackgroundColor = Color(0xFFF8FAFC);

    return Theme(
      data: theme.copyWith(
        cardColor: tableBackgroundColor,
        textTheme: theme.textTheme.apply(
          bodyColor: const Color(0xFF0F172A),
          displayColor: const Color(0xFF0F172A),
        ),
      ),
      child: Material(
        color: tableBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: tableBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Pinned Top Header Bar Component
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: TableHeaderBar(
                  hasSelection: hasSelection,
                  selectedCount: _selectedItems.length,
                  onBulkDelete: widget.onBulkDelete != null
                      ? () {
                          widget.onBulkDelete!(_selectedItems);
                          setState(() {
                            _selectedItems.clear();
                          });
                        }
                      : null,
                  primaryActionButton: widget.primaryActionButton,
                  searchController: _searchController,
                  onSearchChanged: widget.searchMatcher != null
                      ? (val) {
                          setState(() {
                            _currentPage = 1;
                            _selectedItems.clear();
                          });
                        }
                      : null,
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
                child: (!widget.isLoading && paginated.isEmpty)
                    ? TableEmptyState(
                        emptyMessage: widget.emptyMessage,
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
                                      paginated.length,
                                      (rowIndex) {
                                        final item = paginated[rowIndex];
                                        final isSelected = _selectedItems.contains(item);
                                        final displayIndex =
                                            (_currentPage - 1) * _itemsPerPage +
                                                (rowIndex + 1);

                                        return TableRowDataHelper.buildDataTableRow<T>(
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
                  currentPage: _currentPage,
                  totalPages: totalPages > 0 ? totalPages : 1,
                  totalItems: totalItems,
                  itemsPerPage: _itemsPerPage,
                  onPageChanged: (p) {
                    setState(() {
                      _currentPage = p;
                    });
                  },
                  onItemsPerPageChanged: (r) {
                    setState(() {
                      _itemsPerPage = r;
                      _currentPage = 1;
                    });
                  },
                  availableRowsPerPage: const [5, 10, 15, 20, 30, 40, 50],
                ),
              ),
            ],
          ),
        ),
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
