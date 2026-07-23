import 'package:flutter/material.dart';

/// Class representing a column definition in [AppDataTable] for any data type [T].
class AppTableColumn<T> {
  /// The header title of the column (e.g., 'اسم المتجر', 'السعر', 'الحالة').
  final String title;

  /// Builder function to create the widget for a cell given an item of type [T].
  final Widget Function(T item) cellBuilder;

  /// Optional fixed width for the column. If null, the column uses flex layout or auto sizing.
  final double? width;

  /// Flex value when width is null (default is 1).
  final int flex;

  /// Indicates whether the column can be sorted by clicking the header.
  final bool sortable;

  /// Extractor function that returns a [Comparable] value (e.g. String, num, DateTime) used for sorting.
  final Comparable Function(T item)? sortKey;

  /// Alignment of the header and cell content (defaults to [Alignment.centerRight] for RTL support).
  final Alignment alignment;

  const AppTableColumn({
    required this.title,
    required this.cellBuilder,
    this.width,
    this.flex = 1,
    this.sortable = false,
    this.sortKey,
    this.alignment = Alignment.centerRight,
  });
}
